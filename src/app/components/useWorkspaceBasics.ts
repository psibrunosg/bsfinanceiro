"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import type { Account, Category, Workspace } from "./types";

export type WorkspaceBasics = {
  ownerId: string | null;
  workspace: Workspace | null;
  accounts: Account[];
  categories: Category[];
  defaultCashAccountId: string | null;
  loading: boolean;
  reload: () => Promise<void>;
};

const CASH_ACCOUNT_TYPES = ["checking", "cash", "savings"];

/**
 * Carga mínima do workspace para páginas que só precisam de conta/categoria.
 * Evita o custo total do `useFinance("dashboard")` (transações, metas, faturas).
 */
export function useWorkspaceBasics(): WorkspaceBasics {
  const supabase = useMemo(() => createClient(), []);
  const [loading, setLoading] = useState(true);
  const [ownerId, setOwnerId] = useState<string | null>(null);
  const [workspace, setWorkspace] = useState<Workspace | null>(null);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [defaultCashAccountId, setDefaultCashAccountId] = useState<
    string | null
  >(null);
  const hasLoaded = useRef(false);
  const requestSequence = useRef(0);

  const load = useCallback(async () => {
    const requestId = ++requestSequence.current;
    if (!hasLoaded.current) setLoading(true);

    let user: { id: string; email?: string } | null = null;
    let ws: { id: string; name: string } | null = null;

    try {
      const { data: userData } = await supabase.auth.getUser();
      user = userData?.user;
    } catch {}

    if (!user && typeof window !== "undefined") {
      const storedUser = localStorage.getItem("bsfinanceiro_user");
      const storedWs = localStorage.getItem("bsfinanceiro_workspace");
      if (storedUser) {
        try {
          user = JSON.parse(storedUser);
          ws = storedWs ? JSON.parse(storedWs) : null;
        } catch {}
      }
    }

    if (!user) {
      window.location.replace(appPath("/entrar"));
      return;
    }

    if (!ws) {
      try {
        const { data: profile } = await supabase
          .from("profiles")
          .select("active_workspace_id")
          .eq("id", user.id)
          .maybeSingle();
        const activeWorkspaceId = profile?.active_workspace_id;
        const { data: wsData } = await supabase
          .from("workspaces")
          .select("id,name")
          .eq("owner_id", user.id)
          .eq("kind", "personal")
          .eq("id", activeWorkspaceId ?? "00000000-0000-0000-0000-000000000000")
          .maybeSingle();
        ws = wsData;
      } catch {}
    }

    if (!ws) {
      window.location.replace(appPath("/onboarding"));
      return;
    }

    const [{ data: accountRows }, { data: categoryRows }, { data: preferenceRow }] =
      await Promise.all([
        supabase
          .from("accounts")
          .select("id,name,type,initial_balance")
          .eq("workspace_id", ws.id)
          .eq("active", true)
          .eq("is_system", false)
          .order("created_at"),
        supabase
          .from("categories")
          .select("id,name,kind,color")
          .eq("workspace_id", ws.id)
          .eq("active", true)
          .order("name"),
        supabase
          .from("workspace_preferences")
          .select("default_cash_account_id")
          .eq("workspace_id", ws.id)
          .maybeSingle(),
      ]);

    if (requestId !== requestSequence.current) return;

    const loadedAccounts = (accountRows ?? []) as Account[];
    const preferredAccountId = preferenceRow?.default_cash_account_id ?? null;
    const isActiveCashAccount = loadedAccounts.some(
      (account) =>
        account.id === preferredAccountId &&
        CASH_ACCOUNT_TYPES.includes(account.type),
    );

    setOwnerId(user.id);
    setWorkspace(ws);
    setAccounts(loadedAccounts);
    setCategories((categoryRows ?? []) as Category[]);
    setDefaultCashAccountId(isActiveCashAccount ? preferredAccountId : null);

    hasLoaded.current = true;
    setLoading(false);
  }, [supabase]);

  useEffect(() => {
    void load();
  }, [load]);

  return {
    ownerId,
    workspace,
    accounts,
    categories,
    defaultCashAccountId,
    loading,
    reload: load,
  };
}
