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

    const { data: userData } = await supabase.auth.getUser();
    const user = userData.user;
    if (!user) {
      window.location.replace(appPath("/entrar"));
      return;
    }

    const { data: ws } = await supabase
      .from("workspaces")
      .select("id,name")
      .eq("owner_id", user.id)
      .eq("kind", "personal")
      .order("created_at")
      .limit(1)
      .maybeSingle();
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
