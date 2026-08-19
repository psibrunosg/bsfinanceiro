import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { extractSelectablePdfText } from "../_shared/pdf-text.ts";
import { parsePayslip } from "../_shared/payslip.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Max-Age": "86400",
};
const response = (body: Record<string, unknown>, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, "Content-Type": "application/json" } });
const errorCode = (error: unknown) => error instanceof Error && ["invalid_pdf", "pdf_too_large", "pdf_too_many_pages", "pdf_without_selectable_text", "unsupported_layout", "ambiguous_financial_fields"].includes(error.message) ? error.message : "processing_failed";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return response({ error: "method_not_allowed" }, 405);
  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authorization = request.headers.get("Authorization");
  if (!url || !anonKey || !serviceKey || !authorization) return response({ error: "unauthorized" }, 401);
  const userClient = createClient(url, anonKey, { global: { headers: { Authorization: authorization } } });
  const { data: { user } } = await userClient.auth.getUser();
  const { importId } = await request.json().catch(() => ({}));
  if (!user) return response({ error: "unauthorized" }, 401);
  if (typeof importId !== "string") return response({ error: "invalid_request" }, 400);
  const worker = createClient(url, serviceKey);
  const { data: job, error: claimError } = await worker.rpc("claim_payslip_document_import", { p_import_id: importId, p_owner_id: user.id });
  if (claimError || !job) return response({ error: "job_not_available" }, 409);
  if (job.status !== "processing") return response({ status: job.status });
  const storage = worker.storage.from("payslip-document-imports");
  const finishFailed = async (code: string) => {
    const { error } = await worker.rpc("finish_payslip_document_import_failed", { p_import_id: job.id, p_error_code: code });
    if (error) return response({ error: "state_persistence_failed" }, 503);
    const { error: cleanupError } = await storage.remove([job.storage_path]);
    return cleanupError ? response({ status: "failed", error: code, cleanup_failed: true }, 202) : response({ status: "failed", error: code });
  };
  const { data: file, error: downloadError } = await storage.download(job.storage_path);
  if (downloadError || !file) return finishFailed("processing_failed");
  const bytes = new Uint8Array(await file.arrayBuffer());
  const hash = Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)), (value) => value.toString(16).padStart(2, "0")).join("");
  if (hash !== job.sha256) return finishFailed("checksum_mismatch");
  let candidate;
  try { candidate = await parsePayslip((await extractSelectablePdfText(bytes)).text); }
  catch (error) { return finishFailed(errorCode(error)); }
  const { error: reviewError } = await worker.rpc("finish_payslip_document_import_review", {
    p_import_id: job.id, p_employer: candidate.employer, p_competence: candidate.competence,
    p_gross_amount_cents: candidate.grossAmountCents, p_discounts_amount_cents: candidate.discountsAmountCents,
    p_net_amount_cents: candidate.netAmountCents, p_parser_name: candidate.parserName,
    p_parser_version: candidate.parserVersion, p_source_fingerprint: candidate.sourceFingerprint,
  });
  if (reviewError) return finishFailed("processing_failed");
  const { error: cleanupError } = await storage.remove([job.storage_path]);
  return cleanupError ? response({ status: "pending_review", cleanup_failed: true }, 202) : response({ status: "pending_review" });
});
