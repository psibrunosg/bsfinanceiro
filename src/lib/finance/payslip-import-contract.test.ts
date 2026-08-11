import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

const root = resolve(process.cwd());
const migration = readFileSync(resolve(root, "supabase/migrations/20260811000003_payslip_document_imports.sql"), "utf8");
const worker = readFileSync(resolve(root, "supabase/functions/process-payslip-document-import/index.ts"), "utf8");
const cleanup = readFileSync(resolve(root, "supabase/functions/cleanup-payslip-document-imports/index.ts"), "utf8");
const smoke = readFileSync(resolve(root, "supabase/rls-smoke-test.sql"), "utf8");
const hardening = readFileSync(resolve(root, "supabase/migrations/20260811000004_harden_payslip_document_imports.sql"), "utf8");
const terminality = readFileSync(resolve(root, "supabase/migrations/20260811000005_preserve_imported_payslip_results.sql"), "utf8");

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
});
