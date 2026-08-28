"use client";

import { createClient } from "@/lib/supabase/client";
import { appPath } from "@/lib/app-path";
import { useCurrentUser } from "./useCurrentUser";

/** Avatar do usuário no cabeçalho — clique faz logout. */
export function UserMenu() {
  const { displayName, initials } = useCurrentUser();

  async function signOut() {
    try {
      await createClient().auth.signOut();
    } catch {}
    if (typeof window !== "undefined") {
      localStorage.removeItem("bsfinanceiro_user");
      localStorage.removeItem("bsfinanceiro_workspace");
      localStorage.removeItem("bsfinanceiro_token");
    }
    window.location.replace(appPath("/entrar"));
  }

  return (
    <button type="button" className="user-menu" onClick={() => void signOut()} title="Sair da conta">
      <span className="user-menu__text">
        <strong>{displayName}</strong>
        <small>Perfil Pessoal</small>
      </span>
      <span className="user-menu__avatar" aria-hidden="true">{initials}</span>
    </button>
  );
}
