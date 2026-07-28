import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

const root = resolve(process.cwd());
const migration = readFileSync(resolve(root, "supabase/migrations/20260728000007_credit_card_statement_imports.sql"), "utf8");
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
    expect(worker).toContain("p_idempotency_key: job.purchase_idempotency_key");
  });

  it("requires complete CORS preflight and verifies the uploaded object checksum before parsing", () => {
    expect(worker).toContain('"Access-Control-Allow-Origin": "*"');
    expect(worker).toContain('"Access-Control-Allow-Methods": "POST, OPTIONS"');
    expect(worker).toContain('"Access-Control-Allow-Headers"');
    expect(worker).toContain('crypto.subtle.digest("SHA-256", bytes)');
    expect(worker).toContain('return fail("checksum_mismatch")');
  });

  it("retries cleanup for every expired state and deletes the record only after storage removal succeeds", () => {
    expect(cleanup).toContain('.in("status", ["pending", "processing", "imported", "failed"])');
    expect(cleanup).toContain("if (removeError) continue");
    expect(cleanup).toContain("if (!deleteError) cleaned += 1");
  });
});
