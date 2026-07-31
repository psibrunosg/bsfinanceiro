"use client";

import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import { monthStart, nextMonthStart } from "./Money";
import {
  monthStartsThroughDate,
  todayInSaoPaulo,
} from "../../lib/finance/local-date";
import { buildDashboardMoneyModel } from "../../lib/finance/today-adapter";
import {
  decisionWindowCutoff,
  type SpendingPower,
} from "../../lib/finance/spending-power";
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
  TransactionImportBatch,
} from "./types";

const TRANSACTION_SELECT =
  "id,account_id,destination_account_id,type,status,description,amount,competence_date";
const DASHBOARD_QUERY_BATCH_SIZE = 500;
export const TRANSACTION_HISTORY_PAGE_SIZE = 25;

export type TransactionHistoryFilters = {
  query?: string;
  type?: string;
  from?: string;
  to?: string;
};

export type UseFinanceOptions = {
  transactionFilters?: TransactionHistoryFilters;
  transactionPage?: number;
};

export type FinanceData = {
  ownerId: string | null;
  workspace: Workspace;
  accounts: Account[];
  categories: Category[];
  cards: Card[];
  invoices: Invoice[];
  transactions: Transaction[];
  transactionTotal: number;
  transactionPageSize: number;
  todayTransactions: Transaction[];
  budgets: Budget[];
  goals: Goal[];
  monthSpent: Record<string, number>;
  commitments: Commitment[];
  occurrences: Occurrence[];
  alertPrefs: AlertPreference | null;
  statementImports: StatementImport[];
  transactionImportBatches: TransactionImportBatch[];
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

export function useFinance(
  route: string,
  cardId?: string,
  options: UseFinanceOptions = {},
): FinanceData {
  const supabase = useMemo(() => createClient(), []);
  const [loading, setLoading] = useState(true);
  const [ownerId, setOwnerId] = useState<string | null>(null);
  const [workspace, setWorkspace] = useState<Workspace | null>(null);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [cards, setCards] = useState<Card[]>([]);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [dashboardTransactions, setDashboardTransactions] = useState<
    Transaction[]
  >([]);
  const [transactionTotal, setTransactionTotal] = useState(0);
  const [todayTransactions, setTodayTransactions] = useState<Transaction[]>([]);
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [goals, setGoals] = useState<Goal[]>([]);
  const [monthSpent, setMonthSpent] = useState<Record<string, number>>({});
  const [commitments, setCommitments] = useState<Commitment[]>([]);
  const [occurrences, setOccurrences] = useState<Occurrence[]>([]);
  const [alertPrefs, setAlertPrefs] = useState<AlertPreference | null>(null);
  const [statementImports, setStatementImports] = useState<StatementImport[]>([]);
  const [transactionImportBatches, setTransactionImportBatches] = useState<
    TransactionImportBatch[]
  >([]);
  const [defaultCashAccountId, setDefaultCashAccountId] = useState<string | null>(
    null,
  );
  const [message, setMessage] = useState("");
  const hasLoaded = useRef(false);
  const requestSequence = useRef(0);

  const historyQuery = options.transactionFilters?.query?.trim() ?? "";
  const historyType = options.transactionFilters?.type ?? "";
  const historyFrom = options.transactionFilters?.from ?? "";
  const historyTo = options.transactionFilters?.to ?? "";
  const historyPage = Math.max(0, options.transactionPage ?? 0);

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

    const today = todayInSaoPaulo();
    const [
      { data: accountRows },
      { data: categoryRows },
      { data: cardRows },
      { data: preferenceRows },
      { data: dashboardGoalRows },
      { data: workspacePreferenceRows },
    ] = await Promise.all([
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
        .from("credit_cards")
        .select("id,account_id,name,brand,last_four,credit_limit,closing_day,due_day")
        .eq("workspace_id", ws.id)
        .eq("active", true)
        .order("created_at"),
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
    ]);

    let visibleTransactionRows: Transaction[] = [];
    let calculationTransactionRows: Transaction[] = [];
    let upcomingTransactionRows: Transaction[] = [];
    let occurrenceRows: Occurrence[] = [];
    let historyTotal = 0;
    let importBatchRows: TransactionImportBatch[] = [];

    if (route === "dashboard") {
      const { data: nextIncomeData } = await supabase
        .from("transactions")
        .select(TRANSACTION_SELECT)
        .eq("workspace_id", ws.id)
        .eq("status", "planned")
        .eq("type", "income")
        .gte("competence_date", today)
        .order("competence_date", { ascending: true })
        .order("id", { ascending: true })
        .limit(1)
        .maybeSingle();
      const nextIncome = nextIncomeData as Transaction | null;
      const cutoff = decisionWindowCutoff(
        today,
        nextIncome?.competence_date ?? null,
      );

      const loadDashboardTransactionBatch = async (
        status: "paid" | "planned",
        from: number,
        to: number,
      ) => {
        let query = supabase
          .from("transactions")
          .select(TRANSACTION_SELECT)
          .eq("workspace_id", ws.id)
          .eq("status", status)
          .order("competence_date", { ascending: true })
          .order("id", { ascending: true });
        if (status === "planned") {
          query = query
            .eq("type", "expense")
            .gte("competence_date", today)
            .lte("competence_date", cutoff);
        }
        const { data } = await query.range(from, to);
        return (data ?? []) as Transaction[];
      };

      const loadAllDashboardTransactions = async (
        status: "paid" | "planned",
      ) => {
        const rows: Transaction[] = [];
        for (let from = 0; ; from += DASHBOARD_QUERY_BATCH_SIZE) {
          const batch = await loadDashboardTransactionBatch(
            status,
            from,
            from + DASHBOARD_QUERY_BATCH_SIZE - 1,
          );
          rows.push(...batch);
          if (batch.length < DASHBOARD_QUERY_BATCH_SIZE) break;
        }
        return rows;
      };

      const [paidRows, plannedExpenseRows, recentResult, materializedResults] =
        await Promise.all([
          loadAllDashboardTransactions("paid"),
          loadAllDashboardTransactions("planned"),
          supabase
            .from("transactions")
            .select(TRANSACTION_SELECT)
            .eq("workspace_id", ws.id)
            .order("competence_date", { ascending: false })
            .order("id", { ascending: false })
            .limit(30),
          Promise.all(
            monthStartsThroughDate(today, cutoff).map((month) =>
              supabase.rpc("materialize_fixed_commitment_occurrences", {
                p_workspace_id: ws.id,
                p_month: month,
              }),
            ),
          ),
        ]);

      visibleTransactionRows = (recentResult.data ?? []) as Transaction[];
      upcomingTransactionRows = [
        ...plannedExpenseRows,
        ...(nextIncome ? [nextIncome] : []),
      ];
      calculationTransactionRows = [...paidRows, ...upcomingTransactionRows];
      occurrenceRows = materializedResults.flatMap(
        (result) => (result.data ?? []) as Occurrence[],
      );
    } else if (route === "transactions") {
      let query = supabase
        .from("transactions")
        .select(TRANSACTION_SELECT, { count: "exact" })
        .eq("workspace_id", ws.id);
      if (historyQuery) query = query.ilike("description", `%${historyQuery}%`);
      if (historyType) query = query.eq("type", historyType);
      if (historyFrom) query = query.gte("competence_date", historyFrom);
      if (historyTo) query = query.lte("competence_date", historyTo);

      const from = historyPage * TRANSACTION_HISTORY_PAGE_SIZE;
      const [{ data, count }, { data: batches }] = await Promise.all([
        query
          .order("competence_date", { ascending: false })
          .order("id", { ascending: false })
          .range(from, from + TRANSACTION_HISTORY_PAGE_SIZE - 1),
        supabase
          .from("transaction_import_batches")
          .select(
            "id,account_id,file_name,status,created_at,applied_at,discarded_at,transaction_import_items(id,batch_id,row_number,competence_date,description,amount_cents,type,status,reason,fingerprint,transaction_id,created_at)",
          )
          .eq("workspace_id", ws.id)
          .order("created_at", { ascending: false })
          .limit(10),
      ]);
      visibleTransactionRows = (data ?? []) as Transaction[];
      historyTotal = count ?? 0;
      importBatchRows = (batches ?? []) as TransactionImportBatch[];
    } else {
      const { data } = await supabase
        .from("transactions")
        .select(TRANSACTION_SELECT)
        .eq("workspace_id", ws.id)
        .order("competence_date", { ascending: false })
        .order("id", { ascending: false })
        .limit(30);
      visibleTransactionRows = (data ?? []) as Transaction[];
    }

    if (requestId !== requestSequence.current) return;

    setOwnerId(user.id);
    setWorkspace(ws);
    setAccounts(accountRows || []);
    setCategories(categoryRows || []);
    setCards(cardRows || []);
    setTransactions(visibleTransactionRows);
    setDashboardTransactions(calculationTransactionRows);
    setTodayTransactions(upcomingTransactionRows);
    setTransactionTotal(historyTotal);
    setAlertPrefs(preferenceRows || null);
    setTransactionImportBatches(importBatchRows);
    if (route === "dashboard") {
      const workspacePreference =
        workspacePreferenceRows as WorkspacePreference | null;
      const preferredAccountId =
        workspacePreference?.default_cash_account_id ?? null;
      const isActiveCashAccount = (accountRows || []).some(
        (account) =>
          account.id === preferredAccountId &&
          (account.type === "checking" ||
            account.type === "cash" ||
            account.type === "savings"),
      );

      setDefaultCashAccountId(
        isActiveCashAccount ? preferredAccountId : null,
      );
      setGoals(dashboardGoalRows || []);
      setOccurrences(occurrenceRows);
    }

    if (route === "card" && cardId) {
      const [{ data }, { data: importRows }] = await Promise.all([
        supabase
          .from("credit_card_invoices")
          .select(
            "id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))",
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
          "id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))",
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
            .select("id,name,target_amount,current_amount,deadline,status")
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
        if (row.category_id) {
          spent[row.category_id] =
            (spent[row.category_id] || 0) + Number(row.amount);
        }
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
      const { data: occurrenceData } = await supabase.rpc(
        "materialize_fixed_commitment_occurrences",
        { p_workspace_id: ws.id, p_month: monthStart() },
      );
      setOccurrences(occurrenceData || []);
    }

    hasLoaded.current = true;
    setLoading(false);
  }, [
    supabase,
    route,
    cardId,
    historyQuery,
    historyType,
    historyFrom,
    historyTo,
    historyPage,
  ]);

  useEffect(() => {
    void load();
  }, [load]);

  const dashboardMoneyModel = useMemo(
    () =>
      buildDashboardMoneyModel({
        accounts,
        transactions: dashboardTransactions,
        occurrences,
        today: todayInSaoPaulo(),
      }),
    [accounts, dashboardTransactions, occurrences],
  );

  return {
    ownerId,
    workspace: workspace!,
    accounts,
    categories,
    cards,
    invoices,
    transactions,
    transactionTotal,
    transactionPageSize: TRANSACTION_HISTORY_PAGE_SIZE,
    todayTransactions,
    budgets,
    goals,
    monthSpent,
    commitments,
    occurrences,
    alertPrefs,
    statementImports,
    transactionImportBatches,
    defaultCashAccountId,
    cashPosition: dashboardMoneyModel.cashPosition,
    spendingPower: dashboardMoneyModel.spendingPower,
    loading,
    message,
    setMessage,
    reload: load,
  };
}
