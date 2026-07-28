import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (request) => {
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const url = Deno.env.get("SUPABASE_URL");
  if (!serviceKey || !url || request.headers.get("Authorization") !== `Bearer ${serviceKey}`) {
    return new Response("Unauthorized", { status: 401 });
  }
  const supabase = createClient(url, serviceKey);
  const { data: jobs, error } = await supabase
    .from("credit_card_statement_imports")
    .select("id,storage_path")
    .in("status", ["imported", "failed"])
    .lt("expires_at", new Date().toISOString())
    .limit(100);
  if (error) return new Response("Unable to load expired imports", { status: 500 });
  for (const job of jobs || []) {
    await supabase.storage.from("credit-card-statements").remove([job.storage_path]);
    await supabase.from("credit_card_statement_imports").delete().eq("id", job.id);
  }
  return Response.json({ cleaned: jobs?.length || 0 });
});
