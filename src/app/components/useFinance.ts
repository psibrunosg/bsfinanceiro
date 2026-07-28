"use client";

import { useEffect, useMemo, useState, useCallback } from "react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import { monthStart, nextMonthStart } from "./Money";
import { todayInSaoPaulo } from "../../lib/finance/local-date";
import type {
  Workspace,
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
} from "./types";

export type FinanceData = {
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
  loading: boolean;
  message: string;
  setMessage: (msg: string) => void;
  reload: () => Promise<void>;
};

export function useFinance(route: string, cardId?: string): FinanceData {
  const supabase = useMemo(() => createClient(), []);
  const [loading, setLoading] = useState(true);
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
  const [message, setMessage] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
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
    setWorkspace(ws);

    const today = todayInSaoPaulo();
    const [
      { data: accountRows },
      { data: categoryRows },
      { data: cardRows },
      { data: txRows },
      { data: todayTransactionRows },
      { data: preferenceRows },
      { data: dashboardGoalRows },
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
      supabase
        .from("transactions")
        .select("id,type,description,amount,competence_date")
        .eq("workspace_id", ws.id)
        .order("competence_date", { ascending: false })
        .limit(30),
      route === "dashboard"
        ? supabase
          .from("transactions")
          .select("id,type,description,amount,competence_date")
          .eq("workspace_id", ws.id)
          .gte("competence_date", today)
          .order("competence_date")
        : Promise.resolve({ data: [] }),
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
    ]);

    setAccounts(accountRows || []);
    setCategories(categoryRows || []);
    setCards(cardRows || []);
    setTransactions(txRows || []);
    setTodayTransactions(todayTransactionRows || []);
    setAlertPrefs(preferenceRows || null);
    if (route === "dashboard") setGoals(dashboardGoalRows || []);

    if (route === "card" && cardId) {
      const { data } = await supabase
        .from("credit_card_invoices")
        .select(
          "id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))"
        )
        .eq("credit_card_id", cardId)
        .order("due_date", { ascending: false })
        .limit(12);
      setInvoices(data || []);
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

  return {
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
    loading,
    message,
    setMessage,
    reload: load,
  };
}
