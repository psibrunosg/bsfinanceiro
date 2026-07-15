import { createBrowserClient } from "@supabase/ssr";

const fallbackUrl = "https://wgntlhzjyriwhncumjsv.supabase.co";
const fallbackKey = "sb_publishable_vFa47pDTRu189gOyTLORfg_2QGcr6Qx";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || fallbackUrl,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || fallbackKey,
  );
}
