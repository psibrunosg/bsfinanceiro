"use client";

import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";

/** Deriva nome de exibição e iniciais a partir do e-mail (sem coluna de perfil dedicada). */
export function useCurrentUser() {
  const supabase = useMemo(() => createClient(), []);
  const [email, setEmail] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    // Promise.resolve: alguns mocks de teste retornam `vi.fn()` sem implementação
    // (undefined) em vez de uma Promise real.
    Promise.resolve(supabase.auth.getUser())
      .then((result) => {
        if (active) {
          const userEmail = result?.data?.user?.email;
          if (userEmail) {
            setEmail(userEmail);
          } else if (typeof window !== "undefined") {
            const stored = localStorage.getItem("bsfinanceiro_user");
            if (stored) {
              try {
                const u = JSON.parse(stored);
                if (u?.email) setEmail(u.email);
              } catch {}
            }
          }
        }
      })
      .catch(() => {
        if (active && typeof window !== "undefined") {
          const stored = localStorage.getItem("bsfinanceiro_user");
          if (stored) {
            try {
              const u = JSON.parse(stored);
              if (u?.email) setEmail(u.email);
            } catch {}
          }
        }
      });
    return () => {
      active = false;
    };
  }, [supabase]);

  const localPart = email?.split("@")[0] ?? "";
  const displayName = localPart
    ? localPart.charAt(0).toUpperCase() + localPart.slice(1)
    : "Usuário";
  const initials = localPart ? localPart.charAt(0).toUpperCase() : "U";

  return { email, displayName, initials };
}
