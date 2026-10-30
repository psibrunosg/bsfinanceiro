"use client";

import { apiFetch } from "@/lib/api-client";

import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { appPath } from "@/lib/app-path";
import { todayInSaoPaulo } from "../../lib/finance/local-date";
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
  TransactionImportBatch,
  TransactionCategoryRule,
} from "./types";

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

export type FinancialContext = {
  id: string;
  workspace_id: string;
  owner_id: string;
  kind: string;
  name: string;
  color: string;
  active: boolean;
  created_at: string;
};

export type FinanceData = {
  ownerId: string | null;
  workspace: Workspace;
  accounts: Account[];
  categoryRules: TransactionCategoryRule[];
  debts: import("./types").Debt[];
  investmentAssets: import("./types").InvestmentAsset[];
  investmentOperations: import("./types").InvestmentOperation[];
  investmentQuotes: import("./types").InvestmentQuote[];
  workspaceUsers: import("./types").WorkspaceUser[];
  workspaceInvites: import("./types").WorkspaceInvite[];
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
  workspacePrefs: WorkspacePreference | null;
  contexts: FinancialContext[];
  statementImports: StatementImport[];
  transactionImportBatches: TransactionImportBatch[];
  defaultCashAccountId: string | null;
  cashPosition: {
    balanceCents: number;
    accountBalancesCents: Record<string, number>;
  };
  spendingPower: SpendingPower;
  payslips: import("./types").Payslip[];
  loading: boolean;
  message: string;
  setMessage: (msg: string) => void;
  reload: () => Promise<void>;
};

const isTestEnv =
  typeof process !== "undefined" &&
  (process.env?.VITEST === "true" ||
    process.env?.NODE_ENV === "test" ||
    Boolean(process.env?.VITEST));

interface BootstrapResponseData {
  accounts?: Account[];
  categories?: Category[];
  cards?: Card[];
  budgets?: Budget[];
  goals?: Goal[];
  debts?: import("./types").Debt[];
  investments?: import("./types").InvestmentAsset[];
  workspace_users?: import("./types").WorkspaceUser[];
  alert_preferences?: AlertPreference;
  workspace_preferences?: WorkspacePreference;
  commitments?: Commitment[];
  occurrences?: Occurrence[];
  transactions?: Transaction[];
  invoices?: Invoice[];
  payslips?: import("./types").Payslip[];
  investment_operations?: import("./types").InvestmentOperation[];
  investment_quotes?: import("./types").InvestmentQuote[];
  workspace_invites?: import("./types").WorkspaceInvite[];
  category_rules?: TransactionCategoryRule[];
  contexts?: FinancialContext[];
  transaction_import_batches?: TransactionImportBatch[];
}

interface BootstrapCache {
  workspaceId: string;
  data: BootstrapResponseData;
  timestamp: number;
}

let memoryBootstrapCache: BootstrapCache | null = null;

export function clearFinanceCache() {
  memoryBootstrapCache = null;
}

export function useFinance(
  route: string,
  _cardId?: string,
  options: UseFinanceOptions = {},
): FinanceData {
  const initialCache = !isTestEnv && memoryBootstrapCache ? memoryBootstrapCache.data : null;
  const [loading, setLoading] = useState(!initialCache);
  const [ownerId, setOwnerId] = useState<string | null>(() => {
    if (typeof window === "undefined") return null;
    try {
      const u = localStorage.getItem("bsfinanceiro_user");
      return u ? JSON.parse(u).id : null;
    } catch {
      return null;
    }
  });
  const [workspace, setWorkspace] = useState<Workspace | null>(() => {
    if (typeof window === "undefined") return null;
    try {
      const w = localStorage.getItem("bsfinanceiro_workspace");
      return w ? JSON.parse(w) : null;
    } catch {
      return null;
    }
  });
  const [accounts, setAccounts] = useState<Account[]>(initialCache?.accounts || []);
  const [categories, setCategories] = useState<Category[]>(initialCache?.categories || []);
  const [categoryRules, setCategoryRules] = useState<TransactionCategoryRule[]>(initialCache?.category_rules || []);
  const [debts, setDebts] = useState<import("./types").Debt[]>(initialCache?.debts || []);
  const [investmentAssets, setInvestmentAssets] = useState<import("./types").InvestmentAsset[]>(initialCache?.investments || []);
  const [investmentOperations, setInvestmentOperations] = useState<import("./types").InvestmentOperation[]>(initialCache?.investment_operations || []);
  const [investmentQuotes, setInvestmentQuotes] = useState<import("./types").InvestmentQuote[]>(initialCache?.investment_quotes || []);
  const [cards, setCards] = useState<Card[]>(initialCache?.cards || []);
  const [invoices, setInvoices] = useState<Invoice[]>(initialCache?.invoices || []);
  const [payslips, setPayslips] = useState<import("./types").Payslip[]>(initialCache?.payslips || []);
  const [workspaceUsers, setWorkspaceUsers] = useState<import("./types").WorkspaceUser[]>(initialCache?.workspace_users || []);
  const [workspaceInvites, setWorkspaceInvites] = useState<import("./types").WorkspaceInvite[]>(initialCache?.workspace_invites || []);
  const [transactions, setTransactions] = useState<Transaction[]>(initialCache?.transactions || []);
  const [dashboardTransactions, setDashboardTransactions] = useState<
    Transaction[]
  >(initialCache?.transactions || []);
  const [transactionTotal, setTransactionTotal] = useState(initialCache?.transactions?.length || 0);
  const [todayTransactions, setTodayTransactions] = useState<Transaction[]>(() => {
    if (!initialCache?.transactions) return [];
    const today = todayInSaoPaulo();
    return initialCache.transactions.filter((t: Transaction) => t.competence_date === today && t.status === "paid");
  });
  const [budgets, setBudgets] = useState<Budget[]>(initialCache?.budgets || []);
  const [goals, setGoals] = useState<Goal[]>(initialCache?.goals || []);
  const [monthSpent, setMonthSpent] = useState<Record<string, number>>(() => {
    if (!initialCache?.transactions) return {};
    const today = todayInSaoPaulo();
    const currentMonthPrefix = today.slice(0, 7);
    const spentByCat: Record<string, number> = {};
    for (const tx of initialCache.transactions) {
      if (tx.type === "expense" && tx.status === "paid" && tx.competence_date?.startsWith(currentMonthPrefix) && tx.category_id) {
        spentByCat[tx.category_id] = (spentByCat[tx.category_id] || 0) + Number(tx.amount);
      }
    }
    return spentByCat;
  });
  const [commitments, setCommitments] = useState<Commitment[]>(initialCache?.commitments || []);
  const [occurrences, setOccurrences] = useState<Occurrence[]>(initialCache?.occurrences || []);
  const [alertPrefs, setAlertPrefs] = useState<AlertPreference | null>(initialCache?.alert_preferences || null);
  const [statementImports] = useState<StatementImport[]>([]);
  const [transactionImportBatches, setTransactionImportBatches] = useState<TransactionImportBatch[]>(
    initialCache?.transaction_import_batches || [],
  );
  const [workspacePrefs, setWorkspacePrefs] = useState<WorkspacePreference | null>(initialCache?.workspace_preferences || null);
  const [contexts, setContexts] = useState<FinancialContext[]>(initialCache?.contexts || []);
  const [defaultCashAccountId, setDefaultCashAccountId] = useState<string | null>(
    initialCache?.workspace_preferences?.default_cash_account_id || null,
  );
  const [message, setMessage] = useState("");
  const hasLoaded = useRef(!!initialCache);
  const requestSequence = useRef(0);

  const historyQuery = options.transactionFilters?.query?.trim() ?? "";
  const historyType = options.transactionFilters?.type ?? "";
  const historyFrom = options.transactionFilters?.from ?? "";
  const historyTo = options.transactionFilters?.to ?? "";
  const historyPage = Math.max(0, options.transactionPage ?? 0);

  const load = useCallback(async () => {
    const requestId = ++requestSequence.current;
    if (!hasLoaded.current) setLoading(true);

    let user: { id: string; email?: string } | null = null;
    let ws: import("./types").Workspace | null = null;

    if (typeof window !== "undefined") {
      const storedUser = localStorage.getItem("bsfinanceiro_user");
      const storedWs = localStorage.getItem("bsfinanceiro_workspace");
      if (storedUser) {
        try {
          user = JSON.parse(storedUser);
          ws = storedWs ? JSON.parse(storedWs) : null;
        } catch {}
      }
    }

    if (!user || !ws) {
      window.location.replace(appPath("/entrar"));
      return;
    }

    setOwnerId(user.id);

    setWorkspace(ws);

    const today = todayInSaoPaulo();

    const applyBootstrapPayload = (boot: BootstrapResponseData, currentDay: string) => {
      setAccounts(boot.accounts || []);
      setCategories(boot.categories || []);
      setCards(boot.cards || []);
      setInvoices(boot.invoices || []);
      setBudgets(boot.budgets || []);
      setGoals(boot.goals || []);
      setDebts(boot.debts || []);
      setInvestmentAssets(boot.investments || []);
      setInvestmentOperations(boot.investment_operations || []);
      setInvestmentQuotes(boot.investment_quotes || []);
      setWorkspaceUsers(boot.workspace_users || []);
      setWorkspaceInvites(boot.workspace_invites || []);
      setCategoryRules(boot.category_rules || []);
      setContexts(boot.contexts || []);
      setTransactionImportBatches(boot.transaction_import_batches || []);
      if (boot.alert_preferences) setAlertPrefs(boot.alert_preferences);
      if (boot.workspace_preferences) {
        setWorkspacePrefs(boot.workspace_preferences);
        if (boot.workspace_preferences.default_cash_account_id) {
          setDefaultCashAccountId(boot.workspace_preferences.default_cash_account_id);
        }
      }
      if (boot.commitments) setCommitments(boot.commitments);
      if (boot.occurrences) setOccurrences(boot.occurrences);
      if (boot.payslips && Array.isArray(boot.payslips)) {
        setPayslips(boot.payslips.map((ps: import("./types").Payslip) => ({
          ...ps,
          gross_amount: Number(ps.gross_amount || 0),
          discounts_amount: Number(ps.discounts_amount || 0),
          net_amount: Number(ps.net_amount || 0),
        })));
      }

      const allTx: Transaction[] = boot.transactions || [];
      const filteredTransactions =
        route === "transactions"
          ? allTx.filter((tx) => {
              const normalizedQuery = historyQuery.toLocaleLowerCase("pt-BR");
              const matchesQuery =
                !normalizedQuery ||
                tx.description.toLocaleLowerCase("pt-BR").includes(normalizedQuery);
              const matchesType = !historyType || tx.type === historyType;
              const matchesFrom = !historyFrom || tx.competence_date >= historyFrom;
              const matchesTo = !historyTo || tx.competence_date <= historyTo;
              return matchesQuery && matchesType && matchesFrom && matchesTo;
            })
          : allTx;
      const pageStart = historyPage * TRANSACTION_HISTORY_PAGE_SIZE;
      const visibleTransactions =
        route === "transactions"
          ? filteredTransactions.slice(
              pageStart,
              pageStart + TRANSACTION_HISTORY_PAGE_SIZE,
            )
          : filteredTransactions;

      setTransactions(visibleTransactions);
      setDashboardTransactions(allTx);
      setTransactionTotal(filteredTransactions.length);
      setTodayTransactions(
        allTx.filter(
          (t: Transaction) =>
            t.competence_date === currentDay && t.status === "paid",
        ),
      );

      const spentByCat: Record<string, number> = {};
      const currentMonthPrefix = currentDay.slice(0, 7);
      for (const tx of allTx) {
        if (tx.type === "expense" && tx.status === "paid" && tx.competence_date.startsWith(currentMonthPrefix) && tx.category_id) {
          spentByCat[tx.category_id] = (spentByCat[tx.category_id] || 0) + Number(tx.amount);
        }
      }
      setMonthSpent(spentByCat);
    };

    // 0. Cache em memória fresco (< 60s): resposta instantânea (0ms) ao trocar de tela
    if (
      !isTestEnv &&
      memoryBootstrapCache &&
      memoryBootstrapCache.workspaceId === ws.id &&
      Date.now() - memoryBootstrapCache.timestamp < 60_000 &&
      Array.isArray(memoryBootstrapCache.data?.accounts)
    ) {
      applyBootstrapPayload(memoryBootstrapCache.data, today);
      setLoading(false);
      hasLoaded.current = true;
      return;
    }

    // 1. Carrega exclusivamente via API REST da VPS (PostgreSQL dedicado).
    try {
      const apiRes = await apiFetch(`/api/bootstrap?workspace_id=${encodeURIComponent(ws.id)}`);

      if (apiRes.status === 401) {
        try {
          localStorage.removeItem("bsfinanceiro_user");
          localStorage.removeItem("bsfinanceiro_workspace");
          localStorage.removeItem("bsfinanceiro_token");
        } catch {}
        window.location.replace(appPath("/entrar"));
        return;
      }

      if (!apiRes.ok) {
        let detail = "";
        try {
          const payload = await apiRes.json();
          detail = typeof payload?.error === "string" ? payload.error : "";
        } catch {}
        throw new Error(detail || `Falha ao carregar dados (HTTP ${apiRes.status}).`);
      }

      const boot = await apiRes.json();
      if (!boot || !Array.isArray(boot.accounts)) {
        throw new Error("A API retornou um bootstrap inválido.");
      }

      if (requestId !== requestSequence.current) return;
      applyBootstrapPayload(boot, today);
      if (!isTestEnv) {
        memoryBootstrapCache = {
          workspaceId: ws.id,
          data: boot,
          timestamp: Date.now(),
        };
      }
      setMessage("");
      setLoading(false);
      hasLoaded.current = true;
      return;
    } catch (error) {
      if (requestId !== requestSequence.current) return;
      const detail = error instanceof Error ? error.message : "";
      setMessage(
        detail
          ? `Não foi possível carregar seus dados. ${detail}`
          : "Não foi possível carregar seus dados. Tente novamente.",
      );
      setLoading(false);
      hasLoaded.current = true;
      return;
    }

  }, [
    route,
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
    debts,
    investmentAssets,
    investmentOperations,
    investmentQuotes,
    workspaceUsers,
    workspaceInvites,
    categoryRules,
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
    payslips,
    alertPrefs,
    statementImports,
    transactionImportBatches,
    defaultCashAccountId,
    workspacePrefs,
    contexts,
    cashPosition: dashboardMoneyModel.cashPosition,
    spendingPower: dashboardMoneyModel.spendingPower,
    loading,
    message,
    setMessage,
    reload: load,
  };
}
