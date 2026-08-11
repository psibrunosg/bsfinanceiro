import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { extractSelectablePdfText } from "../_shared/pdf-text.ts";
import { parseSantanderStatement } from "../_shared/santander-statement.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Max-Age": "86400",
};
const maxBytes = 5 * 1024 * 1024;

function response(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, "Content-Type": "application/json" } });
}

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
  if (!user) return response({ error: "unauthorized" }, 401);
  const { importId } = await request.json().catch(() => ({}));
  if (typeof importId !== "string") return response({ error: "invalid_request" }, 400);

  const worker = createClient(url, serviceKey);
  const { data: job, error: claimError } = await worker.rpc("claim_credit_card_statement_import", {
    p_import_id: importId,
    p_owner_id: user.id,
  });
  if (claimError || !job) return response({ error: "job_not_available" }, 409);
  if (job.status !== "processing") return response({ status: job.status });
  const storage = worker.storage.from("credit-card-statements");
  const finishFailed = async (errorCode: string) => {
    await worker.rpc("finish_credit_card_statement_import", {
      p_import_id: job.id, p_status: "failed", p_error_code: errorCode, p_purchase_id: null,
    });
    await storage.remove([job.storage_path]);
    return response({ status: "failed", error: errorCode });
  };

  const { data: file, error: downloadError } = await storage.download(job.storage_path);
  if (downloadError || !file || file.size > maxBytes) return finishFailed("unsupported_format");
  const bytes = new Uint8Array(await file.arrayBuffer());
  const sha256 = Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)))
    .map((value) => value.toString(16).padStart(2, "0")).join("");
  if (sha256 !== job.sha256) return finishFailed("checksum_mismatch");

  let statement;
  try {
    const text = job.content_type === "application/pdf"
      ? (await extractSelectablePdfText(bytes)).text
      : new TextDecoder().decode(bytes);
    statement = await parseSantanderStatement(text);
  } catch (error) {
    const code = error instanceof Error && ["invalid_pdf", "pdf_too_large", "pdf_too_many_pages", "pdf_without_selectable_text", "unsupported_layout", "ambiguous_financial_fields"].includes(error.message)
      ? error.message
      : "processing_failed";
    return finishFailed(code);
  }

  const { error: reviewError } = await worker.rpc("finish_credit_card_statement_import_review", {
    p_import_id: job.id,
    p_parser_name: statement.parserName,
    p_parser_version: statement.parserVersion,
    p_closing_date: statement.closingDate,
    p_due_date: statement.dueDate,
    p_declared_total_cents: statement.declaredTotalCents,
    p_items: statement.items,
  });
  if (reviewError) return finishFailed("processing_failed");
  await storage.remove([job.storage_path]);
  return response({ status: "pending_review" });
});
