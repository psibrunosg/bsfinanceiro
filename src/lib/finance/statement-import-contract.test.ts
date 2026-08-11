import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

const root = resolve(process.cwd());
const migration = readFileSync(resolve(root, "supabase/migrations/20260728000007_credit_card_statement_imports.sql"), "utf8");
const reviewMigrationPath = resolve(root, "supabase/migrations/20260811000000_review_credit_card_statement_imports.sql");
const reviewMigration = existsSync(reviewMigrationPath) ? readFileSync(reviewMigrationPath, "utf8") : "";
const worker = readFileSync(resolve(root, "supabase/functions/process-credit-card-statement-import/index.ts"), "utf8");
const cleanup = readFileSync(resolve(root, "supabase/functions/cleanup-credit-card-statement-imports/index.ts"), "utf8");

describe("statement import deployment contracts", () => {
  it("keeps the bucket private and limits client access to its own pending job", () => {
    expect(migration).toContain("'credit-card-statements'");
    expect(migration).toContain("false,");
    expect(migration).toContain("file_size_limit");
    expect(migration).toContain('create policy "credit_card_statement_upload_own"');
    expect(migration).toContain("i.owner_id = (select auth.uid())");
    expect(migration).toContain("and i.status = 'pending'");
  });

  it("deduplicates uploads and reclaims only stale processing jobs with stable purchase idempotency", () => {
    expect(migration).toContain("unique (owner_id, credit_card_id, sha256)");
    expect(migration).toContain("purchase_idempotency_key uuid not null default gen_random_uuid()");
    expect(migration).toContain("started_at < now() - interval '10 minutes'");
    expect(migration).toContain("for update skip locked");
    expect(reviewMigration).toContain("md5('credit-card-statement:'");
  });

  it("requires complete CORS preflight and verifies the uploaded object checksum before parsing", () => {
    expect(worker).toContain('"Access-Control-Allow-Origin": "*"');
    expect(worker).toContain('"Access-Control-Allow-Methods": "POST, OPTIONS"');
    expect(worker).toContain('"Access-Control-Allow-Headers"');
    expect(worker).toContain('crypto.subtle.digest("SHA-256", bytes)');
    expect(worker).toContain('return finishFailed("checksum_mismatch")');
  });

  it("retries cleanup for every expired state and deletes the record only after storage removal succeeds", () => {
    expect(cleanup).toContain('"pending_review"');
    expect(cleanup).toContain("if (removeError) continue");
    expect(cleanup).toContain("if (!deleteError) cleaned += 1");
  });

  it("adds a protected structured review table and the pending_review state", () => {
    expect(reviewMigration).toContain("add value if not exists 'pending_review'");
    expect(reviewMigration).toContain("create table public.credit_card_statement_import_items");
    expect(reviewMigration).toContain("references public.credit_card_statement_imports(id, workspace_id, owner_id)");
    expect(reviewMigration).toContain("unique (import_id, ordinal)");
    expect(reviewMigration).toContain("enable row level security");
    expect(reviewMigration).toContain("grant select on table public.credit_card_statement_import_items to authenticated");
    expect(reviewMigration).not.toMatch(/grant\s+(?:insert|update|delete|all)[^;]*credit_card_statement_import_items\s+to\s+authenticated/i);
    expect(reviewMigration).not.toMatch(/\b(raw_text|extracted_text|pdf_text)\b/i);
  });

  it("applies one owner-scoped, locked batch of at most 500 corrected items", () => {
    expect(reviewMigration).toContain("function public.apply_credit_card_statement_import");
    expect(reviewMigration).toContain("v_user_id uuid := (select auth.uid())");
    expect(reviewMigration).toContain("for update");
    expect(reviewMigration).toContain("jsonb_array_length(p_items) > 500");
    expect(reviewMigration).toContain("totalAmountCents");
    expect(reviewMigration).toContain("corrected total amount required");
    expect(reviewMigration).toContain("md5('credit-card-statement:'");
  });

  it("preserves card semantics: observed installments and invoices, never cash or payment", () => {
    expect(reviewMigration).toContain("insert into public.credit_card_purchases");
    expect(reviewMigration).toContain("insert into public.credit_card_installments");
    expect(reviewMigration).toContain("insert into public.credit_card_invoices");
    expect(reviewMigration).not.toContain("insert into public.transactions");
    expect(reviewMigration).not.toContain("pay_credit_card_invoice");
    expect(worker).not.toContain("create_installment_purchase");
    expect(worker).not.toContain("pay_credit_card_invoice");
  });

  it("extracts and parses PDF text in memory, persists candidates once, then removes the PDF", () => {
    expect(worker).toContain("extractSelectablePdfText");
    expect(worker).toContain("parseSantanderStatement");
    expect(worker).toContain('worker.rpc("finish_credit_card_statement_import_review"');
    expect(worker).toContain('.remove([job.storage_path])');
    expect(worker).toContain('status: "pending_review"');
    expect(worker).not.toContain("NAO_PERSISTIR_TEXTO_BRUTO_9f3a");
  });

});
