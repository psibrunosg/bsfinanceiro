"use client";

import { useEffect, useMemo, useState, useCallback } from "react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import { monthStart, nextMonthStart } from "./Money";
import {
  monthStartsForSaoPauloDate,
  todayInSaoPaulo,
} from "../../lib/finance/local-date";
import { buildDashboardMoneyModel } from "../../lib/finance/today-adapter";
import type { SpendingPower } from "../../lib/finance/spending-power";
import type {
  Workspace,
  WorkspacePreference,
  Account,
  Category,
  Card,
  Invoice,
  Transaction,
  Budget,
  Goal,
  Commitment,
  Occurrence,
  AlertPreference,
  StatementImport,
} from "./types";

export type FinanceData = {
  ownerId: string | null;
  workspace: Workspace;
  accounts: Account[];
  categories: Category[];
  cards: Card[];
  invoices: Invoice[];
  transactions: Transaction[];
  todayTransactions: Transaction[];
  budgets: Budget[];
  goals: Goal[];
  monthSpent: Record<string, number>;
  commitments: Commitment[];
  occurrences: Occurrence[];
  alertPrefs: AlertPreference | null;
  statementImports: StatementImport[];
  defaultCashAccountId: string | null;
  cashPosition: {
    balanceCents: number;
    accountBalancesCents: Record<string, number>;
  };
  spendingPower: SpendingPower;
  loading: boolean;
  message: string;
  setMessage: (msg: string) => void;
  reload: () => Promise<void>;
};

export function useFinance(route: string, cardId?: string): FinanceData {
  const supabase = useMemo(() => createClient(), []);
  const [loading, setLoading] = useState(true);
  const [ownerId, setOwnerId] = useState<string | null>(null);
  const [workspace, setWorkspace] = useState<Workspace | null>(null);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [cards, setCards] = useState<Card[]>([]);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [todayTransactions, setTodayTransactions] = useState<Transaction[]>([]);
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [goals, setGoals] = useState<Goal[]>([]);
  const [monthSpent, setMonthSpent] = useState<Record<string, number>>({});
  const [commitments, setCommitments] = useState<Commitment[]>([]);
  const [occurrences, setOccurrences] = useState<Occurrence[]>([]);
  const [alertPrefs, setAlertPrefs] = useState<AlertPreference | null>(null);
  const [statementImports, setStatementImports] = useState<StatementImport[]>([]);
  const [defaultCashAccountId, setDefaultCashAccountId] = useState<string | null>(null);
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    const { data: userData } = await supabase.auth.getUser();
    const user = userData.user;
    if (!user) {
      window.location.replace(appPath("/entrar"));
      return;
    }
    setOwnerId(user.id);
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
    setWorkspace(ws);

    const today = todayInSaoPaulo();
    const [currentOccurrenceMonth, nextOccurrenceMonth] = monthStartsForSaoPauloDate(today);
    const transactionQuery =
      route === "dashboard"
        ? supabase
          .from("transactions")
          .select(
            "id,account_id,destination_account_id,type,status,description,amount,competence_date"
          )
          .eq("workspace_id", ws.id)
          .or(`status.eq.paid,and(status.eq.planned,competence_date.gte.${today})`)
          .order("competence_date", { ascending: false })
        : supabase
          .from("transactions")
          .select(
            "id,account_id,destination_account_id,type,status,description,amount,competence_date"
          )
          .eq("workspace_id", ws.id)
          .order("competence_date", { ascending: false });
    const transactionRowsQuery =
      route === "transactions"
        ? transactionQuery
        : transactionQuery.limit(30);
    const [
      { data: accountRows },
      { data: categoryRows },
      { data: cardRows },
      { data: txRows },
      { data: preferenceRows },
      { data: dashboardGoalRows },
      { data: workspacePreferenceRows },
      { data: currentOccurrenceRows },
      { data: nextOccurrenceRows },
    ] = await Promise.all([
      supabase
        .from("accounts")
        .select("id,name,type,initial_balance")
        .eq("workspace_id", ws.id)
        .eq("active", true)
        .order("created_at"),
      supabase
        .from("categories")
        .select("id,name,kind,color")
        .eq("workspace_id", ws.id)
        .eq("active", true)
        .order("name"),
      supabase
        .from("credit_cards")
        .select(
          "id,name,brand,last_four,credit_limit,closing_day,due_day"
        )
        .eq("workspace_id", ws.id)
        .eq("active", true)
        .order("created_at"),
      transactionRowsQuery,
      route === "dashboard" || route === "settings"
        ? supabase
          .from("alert_preferences")
          .select("*")
          .eq("workspace_id", ws.id)
          .maybeSingle()
        : Promise.resolve({ data: null }),
      route === "dashboard"
        ? supabase
          .from("financial_goals")
          .select("id,name,target_amount,current_amount,deadline,status")
          .eq("workspace_id", ws.id)
          .eq("status", "active")
          .order("created_at")
        : Promise.resolve({ data: [] }),
      route === "dashboard"
        ? supabase
          .from("workspace_preferences")
          .select("default_cash_account_id")
          .eq("workspace_id", ws.id)
          .maybeSingle()
        : Promise.resolve({ data: null }),
      route === "dashboard"
        ? supabase.rpc(
          "materialize_fixed_commitment_occurrences",
          { p_workspace_id: ws.id, p_month: currentOccurrenceMonth }
        )
        : Promise.resolve({ data: [] }),
      route === "dashboard"
        ? supabase.rpc(
          "materialize_fixed_commitment_occurrences",
          { p_workspace_id: ws.id, p_month: nextOccurrenceMonth }
        )
        : Promise.resolve({ data: [] }),
    ]);

    setAccounts(accountRows || []);
    setCategories(categoryRows || []);
    setCards(cardRows || []);
    setTransactions(txRows || []);
    setTodayTransactions(
      route === "dashboard"
        ? (txRows || []).filter((transaction) => transaction.competence_date >= today)
        : []
    );
    setAlertPrefs(preferenceRows || null);
    if (route === "dashboard") {
      const workspacePreference = workspacePreferenceRows as WorkspacePreference | null;
      const preferredAccountId = workspacePreference?.default_cash_account_id ?? null;
      const isActiveCashAccount = (accountRows || []).some(
        (account) =>
          account.id === preferredAccountId &&
          (account.type === "checking" || account.type === "cash" || account.type === "savings")
      );

      setDefaultCashAccountId(isActiveCashAccount ? preferredAccountId : null);
      setGoals(dashboardGoalRows || []);
      setOccurrences([...(currentOccurrenceRows || []), ...(nextOccurrenceRows || [])]);
    }

    if (route === "card" && cardId) {
      const [{ data }, { data: importRows }] = await Promise.all([
        supabase
        .from("credit_card_invoices")
        .select(
          "id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))"
        )
        .eq("credit_card_id", cardId)
        .order("due_date", { ascending: false })
        .limit(12),
        supabase
          .from("credit_card_statement_imports")
          .select("id,file_name,status,error_code,created_at")
          .eq("credit_card_id", cardId)
          .order("created_at", { ascending: false })
          .limit(5),
      ]);
      setInvoices(data || []);
      setStatementImports(importRows || []);
    } else if (route === "cards") {
      const { data } = await supabase
        .from("credit_card_invoices")
        .select(
          "id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))"
        )
        .eq("workspace_id", ws.id)
        .order("due_date", { ascending: false })
        .limit(24);
      setInvoices(data || []);
    } else if (route === "planning") {
      const [{ data: budgetRows }, { data: goalRows }, { data: spentRows }] =
        await Promise.all([
          supabase
            .from("monthly_budgets")
            .select("id,category_id,amount")
            .eq("workspace_id", ws.id)
            .eq("month", monthStart()),
          supabase
            .from("financial_goals")
            .select(
              "id,name,target_amount,current_amount,deadline,status"
            )
            .eq("workspace_id", ws.id)
            .neq("status", "cancelled")
            .order("created_at"),
          supabase
            .from("transactions")
            .select("category_id,amount")
            .eq("workspace_id", ws.id)
            .eq("type", "expense")
            .gte("competence_date", monthStart())
            .lt("competence_date", nextMonthStart()),
        ]);
      setBudgets(budgetRows || []);
      setGoals(goalRows || []);
      const spent: Record<string, number> = {};
      for (const row of spentRows || []) {
        if (row.category_id)
          spent[row.category_id] =
            (spent[row.category_id] || 0) + Number(row.amount);
      }
      setMonthSpent(spent);
    } else if (route === "commitments") {
      const { data } = await supabase
        .from("fixed_commitments")
        .select("id,description,amount,due_day,account_id,category_id")
        .eq("workspace_id", ws.id)
        .eq("active", true)
        .order("due_day");
      setCommitments(data || []);
      const { data: occ } = await supabase.rpc(
        "materialize_fixed_commitment_occurrences",
        { p_workspace_id: ws.id, p_month: monthStart() }
      );
      setOccurrences(occ || []);
    }

    setLoading(false);
  }, [supabase, route, cardId]);

  useEffect(() => {
    void load();
  }, [load]);

  const dashboardMoneyModel = useMemo(
    () => buildDashboardMoneyModel({
      accounts,
      transactions,
      occurrences,
      today: todayInSaoPaulo(),
    }),
    [accounts, transactions, occurrences]
  );

  return {
    ownerId,
    workspace: workspace!,
    accounts,
    categories,
    cards,
    invoices,
    transactions,
    todayTransactions,
    budgets,
    goals,
    monthSpent,
    commitments,
    occurrences,
    alertPrefs,
    statementImports,
    defaultCashAccountId,
    cashPosition: dashboardMoneyModel.cashPosition,
    spendingPower: dashboardMoneyModel.spendingPower,
    loading,
    message,
    setMessage,
    reload: load,
  };
}
