import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

const root = resolve(process.cwd());
const migration = readFileSync(resolve(root, "supabase/migrations/20260811000003_payslip_document_imports.sql"), "utf8");
const worker = readFileSync(resolve(root, "supabase/functions/process-payslip-document-import/index.ts"), "utf8");
const cleanup = readFileSync(resolve(root, "supabase/functions/cleanup-payslip-document-imports/index.ts"), "utf8");
const smoke = readFileSync(resolve(root, "supabase/rls-smoke-test.sql"), "utf8");
const hardening = readFileSync(resolve(root, "supabase/migrations/20260811000004_harden_payslip_document_imports.sql"), "utf8");
const terminality = readFileSync(resolve(root, "supabase/migrations/20260811000005_preserve_imported_payslip_results.sql"), "utf8");
const releaseHardeningPath = resolve(root, "supabase/migrations/20260811000006_release_import_hardening.sql");
const releaseHardening = existsSync(releaseHardeningPath) ? readFileSync(releaseHardeningPath, "utf8") : "";
const createImportFixPath = resolve(root, "supabase/migrations/20260811000009_fix_payslip_import_ambiguity.sql");
const createImportFix = existsSync(createImportFixPath) ? readFileSync(createImportFixPath, "utf8") : "";

describe("payslip document import contracts", () => {
  it("keeps the temporary bucket private, owner-scoped and distinct from manual attachments", () => {
    expect(migration).toContain("'payslip-document-imports'");
    expect(migration).toContain('create policy "payslip_document_import_upload_own"');
    expect(migration).toContain("i.owner_id = (select auth.uid())");
    expect(migration).not.toContain("alter table public.payslips");
  });

  it("persists only structured candidates and provides owner-locked, idempotent apply", () => {
    expect(migration).toContain("unique (owner_id, sha256)");
    expect(migration).toContain("function public.apply_payslip_document_import");
    expect(migration).toContain("security definer set search_path = ''");
    expect(migration).toContain("for update");
    expect(migration).toContain("duplicate_payslip");
    expect(migration).toContain("applied_candidate_hash");
    expect(migration).not.toMatch(/raw_text|extracted_text|pdf_text/i);
  });

  it("processes PDF text in memory and persists terminal state before cleanup", () => {
    expect(worker).toContain("extractSelectablePdfText");
    expect(worker).toContain("parsePayslip");
    expect(worker).toContain('worker.rpc("finish_payslip_document_import_review"');
    expect(worker).toContain("state_persistence_failed");
    expect(worker).toContain("cleanup_failed");
    expect(cleanup).not.toContain('.from("payslip_document_imports").delete()');
    expect(migration).toContain("status = 'processing' or (status = 'pending' and expires_at <= now())");
  });

  it("marks stale work failed before attempting temporary-object cleanup", () => {
    const transition = cleanup.indexOf("finish_payslip_document_import_failed");
    const remove = cleanup.indexOf('storage.from("payslip-document-imports").remove');
    expect(transition).toBeGreaterThan(-1);
    expect(remove).toBeGreaterThan(transition);
  });

  it("exercises cross-owner denial, replay and optional cash creation in SQL smoke", () => {
    expect(smoke).toContain("claim_payslip_document_import");
    expect(smoke).toContain("finish_payslip_document_import_review");
    expect(smoke).toContain("user B can apply user A payslip import");
    expect(smoke).toContain("payslip replay without cash");
    expect(smoke).toContain("payslip with account and date must create one income transaction");
  });

  it("uses a canonical employer key and one atomic delete path for manual and imported payslips", () => {
    expect(hardening).toContain("normalize_payslip_employer");
    expect(hardening).toContain("unique (workspace_id, owner_id, employer_key, competence)");
    expect(hardening).toContain("function public.delete_payslip");
    expect(hardening).toContain("status = 'discarded'");
    expect(hardening).toContain("delete from public.transactions");
  });

  it("keeps imported results terminal when a payslip is deleted", () => {
    expect(terminality).toContain("imported payslip cannot be deleted");
    expect(terminality).toContain("if found and v_import.status = 'imported'");
    expect(terminality).toContain("before any delete");
  });

  it("hardens manual payslip registration to the active owner workspace", () => {
    expect(releaseHardening).toContain("function public.register_payslip");
    expect(releaseHardening).toContain("security definer set search_path = ''");
    expect(releaseHardening).toContain("v_user_id uuid := (select auth.uid())");
    expect(releaseHardening).toContain("p.active_workspace_id");
    expect(releaseHardening).toContain("c.owner_id = v_user_id");
    expect(releaseHardening).toContain("a.owner_id = v_user_id");
    expect(releaseHardening).toContain("revoke all on function public.register_payslip");
    expect(releaseHardening).toContain("grant execute on function public.register_payslip");
    expect(smoke).toContain("manual register_payslip owner path failed");
    expect(smoke).toContain("anonymous register_payslip unexpectedly succeeded");
    expect(smoke).toContain("invalid_authorization_specification or insufficient_privilege");
    expect(smoke).toContain("user B can register a payslip for user A");
  });

  it("recreates payslip import creation without RETURNS TABLE id ambiguity", () => {
    expect(createImportFix).toContain("function public.create_payslip_document_import(");
    expect(createImportFix).toContain("from public.workspaces as w");
    expect(createImportFix).toContain("from public.payslip_document_imports as i");
    expect(createImportFix).toContain("where i.id = v_existing.id");
    expect(createImportFix).toContain("returning i.id, i.storage_path, i.status into id, storage_path, status");
    expect(createImportFix).toContain("v_existing.status = 'failed'");
  });
});
