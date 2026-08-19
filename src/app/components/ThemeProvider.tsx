"use client";

import { createContext, useContext, useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";

export type ThemePreference = "system" | "light" | "dark" | "cyberpunk" | "corporate" | "neumorphism";
type ThemeContextValue = { preference: ThemePreference; updateThemePreference: (value: ThemePreference) => Promise<void> };
const ThemeContext = createContext<ThemeContextValue>({
  preference: "system",
  updateThemePreference: async () => {},
});

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [preference, setPreference] = useState<ThemePreference>("system");

  useEffect(() => {
    const media = window.matchMedia("(prefers-color-scheme: dark)");
    const apply = (value: ThemePreference) => {
      document.documentElement.dataset.theme =
        value === "system" ? (media.matches ? "dark" : "light") : value;
    };
    const sync = () => apply(preference);
    sync();
    media.addEventListener("change", sync);
    return () => media.removeEventListener("change", sync);
  }, [preference]);

  useEffect(() => {
    const supabase = createClient();
    void supabase.auth.getUser().then(async ({ data }) => {
      if (!data.user) return;
      const { data: profile } = await supabase
        .from("profiles")
        .select("theme_preference")
        .eq("id", data.user.id)
        .maybeSingle();
      if (profile?.theme_preference) setPreference(profile.theme_preference);
    });
  }, []);

  
  async function updateThemePreference(value: ThemePreference) {
    setPreference(value);
    const media = window.matchMedia("(prefers-color-scheme: dark)");
    document.documentElement.dataset.theme =
      value === "system" ? (media.matches ? "dark" : "light") : value;
    const supabase = createClient();
    const { data } = await supabase.auth.getUser();
    if (data.user)
      await supabase
        .from("profiles")
        .update({ theme_preference: value })
        .eq("id", data.user.id);
  }

  return <ThemeContext.Provider value={{ preference, updateThemePreference }}>{children}</ThemeContext.Provider>;
}

export function useThemePreference() {
  return useContext(ThemeContext);
}
