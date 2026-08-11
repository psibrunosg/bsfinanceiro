import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (request) => {
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const url = Deno.env.get("SUPABASE_URL");
  if (!serviceKey || !url || request.headers.get("Authorization") !== `Bearer ${serviceKey}`) {
    return new Response("Unauthorized", { status: 401 });
  }
  const worker = createClient(url, serviceKey);
  const { data: jobs, error } = await worker
    .from("credit_card_statement_imports")
    .select("id,storage_path,status,started_at")
    .in("status", ["pending", "processing", "pending_review", "imported", "failed"])
    .lt("expires_at", new Date().toISOString())
    .limit(100);
  if (error) return new Response("Unable to load expired imports", { status: 500 });
  let cleaned = 0;
  for (const job of jobs || []) {
    const requiresPreparation = job.status === "pending" || job.status === "processing" || job.status === "failed";
    if (requiresPreparation) {
      const { error: prepareError } = await worker.rpc("prepare_credit_card_statement_import_cleanup", { p_import_id: job.id });
      if (prepareError) continue;
    }
    const { error: removeError } = await worker.storage.from("credit-card-statements").remove([job.storage_path]);
    if (removeError) continue;
    if (requiresPreparation) {
      const { error: finishError } = await worker.rpc("finish_credit_card_statement_import_cleanup", { p_import_id: job.id });
      if (finishError) continue;
    }
    cleaned += 1;
  }
  return Response.json({ cleaned, attempted: jobs?.length || 0 });
});
