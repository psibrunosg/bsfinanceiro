import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { parseStatementFixture } from "../_shared/statement-fixture.ts";

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

  const fail = async (errorCode: string) => {
    await worker.rpc("finish_credit_card_statement_import", {
      p_import_id: job.id,
      p_status: "failed",
      p_error_code: errorCode,
      p_purchase_id: null,
    });
    await worker.storage.from("credit-card-statements").remove([job.storage_path]);
    return response({ status: "failed", error: errorCode });
  };

  const { data: file, error: downloadError } = await worker.storage.from("credit-card-statements").download(job.storage_path);
  if (downloadError || !file || file.size > maxBytes) return fail("unsupported_format");
  if (job.content_type !== "text/plain") return fail("unsupported_format");

  const bytes = await file.arrayBuffer();
  const sha256 = Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)))
    .map((value) => value.toString(16).padStart(2, "0"))
    .join("");
  if (sha256 !== job.sha256) return fail("checksum_mismatch");

  let purchase;
  try {
    purchase = parseStatementFixture(new TextDecoder().decode(bytes));
  } catch {
    return fail("unsupported_format");
  }

  const { data: purchaseId, error: purchaseError } = await userClient.rpc("create_installment_purchase", {
    p_credit_card_id: job.credit_card_id,
    p_description: purchase.description,
    p_total_amount: purchase.totalAmount,
    p_purchased_on: purchase.purchasedOn,
    p_installment_count: purchase.installmentCount,
    p_category_id: purchase.categoryId,
    p_notes: purchase.notes,
    p_idempotency_key: job.purchase_idempotency_key,
  });
  if (purchaseError || !purchaseId) return fail("purchase_creation_failed");

  const { error: finishError } = await worker.rpc("finish_credit_card_statement_import", {
    p_import_id: job.id,
    p_status: "imported",
    p_error_code: null,
    p_purchase_id: purchaseId,
  });
  if (finishError) return fail("processing_failed");
  await worker.storage.from("credit-card-statements").remove([job.storage_path]);
  return response({ status: "imported", purchaseId });
});
