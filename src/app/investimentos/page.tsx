"use client";

import { useCallback, useEffect, useMemo, useState, useRef } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { SimpleForm } from "../components/SimpleForm";
import { List } from "../components/List";
import { money, parseMoney, dateFmt } from "../components/Money";
import { createClient } from "@/lib/supabase/client";
import {
  WalletCards,
  TrendingUp,
  TrendingDown,
  PiggyBank,
  RefreshCw,
  Sparkles,
} from "lucide-react";
import { InvestmentGrowthWidget } from "../components/InvestmentGrowthWidget";
import { FireDashboardWidget } from "../components/FireDashboardWidget";

const ASSET_TYPES: Record<string, string> = {
  stock: "Ações",
  reit: "FIIs",
  fund: "Fundos / ETFs",
  fixed_income: "Renda fixa",
  real_estate: "Imóveis",
  crypto: "Cripto",
};

type Asset = {
  id: string;
  name: string;
  ticker?: string;
  type: string;
  exchange: string | null;
  broker?: string | null;
  is_shared?: boolean;
  created_at?: string;
};

type Operation = {
  id: string;
  asset_id: string;
  operation_type: "buy" | "sell";
  quantity: number;
  unit_price: number;
  operation_date: string;
  transaction_id?: string | null;
  created_at?: string;
};

type Quote = {
  id: string;
  asset_id: string;
  quote_date: string;
  unit_price: number;
};

type QuoteMeta = {
  ticker: string;
  price: number;
  previous_close: number;
  change_pct: number;
  day_high?: number | null;
  day_low?: number | null;
  quote_date: string;
};

type Benchmarks = {
  selic: number;
  cdi: number;
  ibovespa: number | null;
  ibovespa_change: number | null;
  ifix: number | null;
  ifix_change: number | null;
  updated_at: string;
};

type SearchResult = {
  ticker: string;
  symbol: string;
  name: string;
  type: string;
  exchange: string;
};

type DialogState =
  | { kind: "asset" }
  | { kind: "buy"; assetId: string }
  | { kind: "sell"; assetId: string }
  | { kind: "quote"; assetId: string }
  | null;

export default function InvestimentosPage() {
  const { workspace, accounts, defaultCashAccountId, loading } =
    useFinance("dashboard");
  const supabase = useMemo(() => createClient(), []);
  const [assets, setAssets] = useState<Asset[]>([]);
  const [operations, setOperations] = useState<Operation[]>([]);
  const [quotes, setQuotes] = useState<Quote[]>([]);
  const [quoteMeta, setQuoteMeta] = useState<Record<string, QuoteMeta>>({});
  const [benchmarks, setBenchmarks] = useState<Benchmarks | null>(null);
  const [syncingQuotes, setSyncingQuotes] = useState(false);
  const [lastSyncedTime, setLastSyncedTime] = useState<string | null>(null);
  const [defaultContextId, setDefaultContextId] = useState<string | null>(null);
  const [dialog, setDialog] = useState<DialogState>(null);
  const [message, setMessage] = useState("");
  const [hubLoading, setHubLoading] = useState(true);

  // Asset search state in modal
  const [tickerQuery, setTickerQuery] = useState("");
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [selectedAssetQuote, setSelectedAssetQuote] = useState<number | null>(null);
  const searchTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const loadHub = useCallback(async () => {
    if (!workspace) return;
    try {
      try {
        const res = await fetch(`/api/bootstrap?workspace_id=${encodeURIComponent(workspace.id)}`);
        if (res.ok) {
          const boot = await res.json();
          if (boot.investments) {
            setAssets(
              boot.investments.map((a: {
                id: string;
                name: string;
                type: string;
                exchange?: string | null;
                ticker?: string;
                broker?: string;
                is_shared?: boolean;
              }) => ({
                id: a.id,
                name: a.name || a.ticker || "",
                ticker: a.ticker || a.name || "",
                type: a.type,
                exchange: a.broker || a.exchange || null,
                broker: a.broker || a.exchange || null,
                is_shared: !!a.is_shared,
              }))
            );
          }
          if (boot.investment_operations) {
            setOperations(
              boot.investment_operations.map((o: {
                id: string;
                asset_id: string;
                operation_type: "buy" | "sell";
                quantity: number | string;
                unit_price: number | string;
                operation_date: string;
                created_at: string;
              }) => ({
                ...o,
                quantity: Number(o.quantity),
                unit_price: Number(o.unit_price),
              }))
            );
          }
          if (boot.investment_quotes) {
            setQuotes(
              boot.investment_quotes.map((q: {
                id: string;
                asset_id: string;
                quote_date: string;
                unit_price: number | string;
              }) => ({
                ...q,
                unit_price: Number(q.unit_price),
              }))
            );
          }
          setHubLoading(false);
          return;
        }
      } catch {
        // Fallback to direct supabase queries
      }

      const [{ data: contextRows }, { data: assetRows }, { data: operationRows }, { data: quoteRows }] =
        await Promise.all([
          supabase
            .from("financial_contexts")
            .select("id")
            .eq("workspace_id", workspace.id)
            .eq("kind", "pessoal")
            .limit(1)
            .maybeSingle(),
          supabase
            .from("investment_assets")
            .select("id,name,ticker,type,is_shared,created_at")
            .eq("workspace_id", workspace.id)
            .eq("active", true)
            .order("name"),
          supabase
            .from("investment_operations")
            .select("id,asset_id,operation_type,quantity,unit_price,operation_date,transaction_id,created_at")
            .eq("workspace_id", workspace.id)
            .order("operation_date", { ascending: false })
            .limit(200),
          supabase
            .from("investment_quotes")
            .select("id,asset_id,quote_date,unit_price")
            .eq("workspace_id", workspace.id)
            .order("quote_date", { ascending: false })
            .limit(500),
        ]);
      setDefaultContextId(contextRows?.id ?? null);
      setAssets(
        (assetRows ?? []).map((a: { id: string; name: string; ticker?: string; type: string; is_shared?: boolean }) => ({
          id: a.id,
          name: a.name || a.ticker || "",
          ticker: a.ticker || a.name || "",
          type: a.type,
          exchange: null,
          is_shared: !!a.is_shared,
        }))
      );
      setOperations(operationRows ?? []);
      setQuotes(quoteRows ?? []);
    } finally {
      setHubLoading(false);
    }
  }, [supabase, workspace]);

  const loadBenchmarks = useCallback(async () => {
    try {
      const res = await fetch("/api/investments/benchmarks");
      if (res.ok) {
        const data = await res.json();
        if (data.benchmarks) {
          setBenchmarks(data.benchmarks);
        }
      }
    } catch {
      // ignore
    }
  }, []);

  const syncMarketQuotes = useCallback(
    async (silent = false) => {
      if (!workspace) return;
      setSyncingQuotes(true);
      try {
        const res = await fetch(
          `/api/investments/sync-quotes?workspace_id=${encodeURIComponent(workspace.id)}`
        );
        if (res.ok) {
          const data = await res.json();
          if (data.quotes) {
            const metaMap: Record<string, QuoteMeta> = {};
            for (const q of data.quotes) {
              metaMap[q.asset_id] = q;
              metaMap[q.ticker] = q;
            }
            setQuoteMeta((prev) => ({ ...prev, ...metaMap }));
          }
          if (data.benchmarks) {
            setBenchmarks(data.benchmarks);
          }
          setLastSyncedTime(
            new Date().toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })
          );
          if (!silent) {
            setMessage(
              `Cotações atualizadas com sucesso via B3 (${data.synced_count ?? data.quotes?.length ?? 0} ativos sincronizados).`
            );
          }
          await loadHub();
        } else {
          if (!silent) setMessage("Não foi possível sincronizar as cotações com o mercado.");
        }
      } catch {
        if (!silent) setMessage("Erro ao conectar à API de cotações.");
      } finally {
        setSyncingQuotes(false);
      }
    },
    [workspace, loadHub]
  );

  const syncSingleAssetQuote = useCallback(
    async (asset: Asset) => {
      if (!workspace) return;
      const ticker = asset.ticker || asset.name;
      setMessage(`Buscando cotação de ${ticker} no mercado...`);
      try {
        const res = await fetch(`/api/investments/quote?ticker=${encodeURIComponent(ticker)}`);
        if (res.ok) {
          const data = await res.json();
          if (data.quote) {
            const price = data.quote.price;
            const today = new Date().toISOString().slice(0, 10);
            await fetch("/api/investments/quotes", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                workspace_id: workspace.id,
                asset_id: asset.id,
                unit_price: price,
                quote_date: today,
              }),
            });
            setQuoteMeta((prev) => ({
              ...prev,
              [asset.id]: {
                ticker,
                price,
                previous_close: data.quote.previous_close,
                change_pct: data.quote.change_pct,
                day_high: data.quote.day_high,
                day_low: data.quote.day_low,
                quote_date: today,
              },
            }));
            setMessage(`Cotação de ${ticker} atualizada para ${money(price)}.`);
            await loadHub();
            return;
          }
        }
        setMessage(`Cotação para ${ticker} não encontrada automaticamente. Digite manualmente.`);
        setDialog({ kind: "quote", assetId: asset.id });
      } catch {
        setMessage("Falha ao consultar cotação. Você pode atualizar manualmente.");
        setDialog({ kind: "quote", assetId: asset.id });
      }
    },
    [workspace, loadHub]
  );

  const handleTickerInputChange = (value: string) => {
    setTickerQuery(value);
    setSelectedAssetQuote(null);
    if (searchTimeoutRef.current) clearTimeout(searchTimeoutRef.current);
    if (value.trim().length >= 2) {
      setSearching(true);
      searchTimeoutRef.current = setTimeout(async () => {
        try {
          const res = await fetch(`/api/investments/search?q=${encodeURIComponent(value.trim())}`);
          if (res.ok) {
            const data = await res.json();
            setSearchResults(data.results || []);
          }
        } catch {
          // ignore
        } finally {
          setSearching(false);
        }
      }, 350);
    } else {
      setSearchResults([]);
      setSearching(false);
    }
  };

  const handleSelectSearchResult = async (result: SearchResult) => {
    setTickerQuery(result.ticker);
    setSearchResults([]);
    try {
      const res = await fetch(`/api/investments/quote?ticker=${encodeURIComponent(result.ticker)}`);
      if (res.ok) {
        const data = await res.json();
        if (data.quote) {
          setSelectedAssetQuote(data.quote.price);
        }
      }
    } catch {
      // ignore
    }
  };

  useEffect(() => {
    void loadHub();
    void loadBenchmarks();
  }, [loadHub, loadBenchmarks]);

  // Auto-sync quotes on initial mount if quotes are empty and assets exist
  const initialSyncTriggered = useRef(false);
  useEffect(() => {
    if (!hubLoading && assets.length > 0 && quotes.length === 0 && !initialSyncTriggered.current) {
      initialSyncTriggered.current = true;
      void syncMarketQuotes(true);
    }
  }, [hubLoading, assets, quotes, syncMarketQuotes]);

  if (loading || !workspace || hubLoading) {
    return (
      <main className="dashboard-shell">
        <p className="muted">Carregando investimentos...</p>
      </main>
    );
  }

  // Posição por ativo: quantidade líquida, custo médio e custo total.
  const positionByAsset: Record<string, { quantity: number; costCents: number; buys: number; sells: number }> = {};
  for (const op of operations) {
    const p = positionByAsset[op.asset_id] ?? { quantity: 0, costCents: 0, buys: 0, sells: 0 };
    const q = Number(op.quantity);
    const unit = Number(op.unit_price);
    if (op.operation_type === "buy") {
      p.quantity += q;
      p.costCents += Math.round(q * unit * 100);
      p.buys += 1;
    } else {
      p.quantity -= q;
      p.sells += 1;
    }
    positionByAsset[op.asset_id] = p;
  }

  // Cotação mais recente por ativo.
  const latestQuote: Record<string, number> = {};
  for (const q of quotes) {
    if (!(q.asset_id in latestQuote)) latestQuote[q.asset_id] = Number(q.unit_price);
  }

  const investedCents = assets.reduce((s, a) => s + (positionByAsset[a.id]?.costCents ?? 0), 0);
  const currentCents = assets.reduce((s, a) => {
    const pos = positionByAsset[a.id];
    if (!pos) return s;
    const price = latestQuote[a.id] ?? (pos.quantity > 0 ? pos.costCents / 100 / pos.quantity : 0);
    return s + Math.round(pos.quantity * price * 100);
  }, 0);
  const gainCents = currentCents - investedCents;
  const gainPct = investedCents > 0 ? (gainCents / investedCents) * 100 : 0;

  const action =
    dialog?.kind === "buy" || dialog?.kind === "sell" || dialog?.kind === "quote"
      ? undefined
      : {
          label: "Cadastrar ativo",
          onClick: () => {
            setTickerQuery("");
            setSearchResults([]);
            setSelectedAssetQuote(null);
            setDialog({ kind: "asset" });
          },
        };

  const dialogTitle =
    dialog?.kind === "asset"
      ? "Cadastrar ativo"
      : dialog?.kind === "buy"
      ? "Registrar compra"
      : dialog?.kind === "sell"
      ? "Registrar venda"
      : dialog?.kind === "quote"
      ? "Atualizar cotação"
      : "";

  async function submitAsset(form: FormData) {
    const ticker = String(form.get("ticker") || tickerQuery || "").toUpperCase().trim();
    const name = String(form.get("name") || ticker || "");
    const type = String(form.get("type") || "stock");
    const broker = String(form.get("broker") || form.get("exchange") || "Rico");
    const isShared = form.get("is_shared") === "on";

    try {
      const res = await fetch("/api/investments/assets", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspace.id,
          ticker: ticker || name,
          name: name || ticker,
          broker,
          exchange: broker,
          type,
          is_shared: isShared,
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setMessage(`Ativo ${ticker || name} cadastrado com sucesso.`);
        setDialog(null);
        await loadHub();
        void syncMarketQuotes(true);
        return;
      }
    } catch {
      // fallback to supabase
    }

    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("investment_assets").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      context_id: defaultContextId,
      ticker: ticker || name,
      name: name || ticker,
      type,
      exchange: broker,
      is_shared: isShared,
    });
    setMessage(error ? "Não foi possível cadastrar o ativo." : "Ativo cadastrado.");
    if (!error) setDialog(null);
    await loadHub();
  }

  async function submitOperation(assetId: string, kind: "buy" | "sell", form: FormData) {
    const accountId = form.get("account_id");
    if (!accountId) {
      setMessage("Escolha uma conta para a operação.");
      return;
    }
    const quantity = Number(String(form.get("quantity")).replace(",", "."));
    const price = parseMoney(form.get("unit_price"));
    const amount = Math.round(quantity * price * 100) / 100;
    const operation_date = String(form.get("operation_date") || "");

    try {
      const res = await fetch("/api/investments/operations", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspace.id,
          asset_id: assetId,
          account_id: accountId,
          operation_type: kind,
          type: kind,
          quantity,
          unit_price: price,
          operation_date,
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setMessage(`${kind === "buy" ? "Compra" : "Venda"} registrada.`);
        setDialog(null);
        await loadHub();
        return;
      }
    } catch {
      // fallback to supabase
    }

    const { error } = await supabase.rpc("record_investment_operation", {
      p_asset_id: assetId,
      p_account_id: accountId,
      p_type: kind,
      p_quantity: quantity,
      p_price: price,
      p_amount: amount,
      p_date: operation_date,
    });
    setMessage(
      error
        ? `Não foi possível registrar a ${kind === "buy" ? "compra" : "venda"}.`
        : `${kind === "buy" ? "Compra" : "Venda"} registrada.`
    );
    if (!error) setDialog(null);
    await loadHub();
  }

  async function submitQuote(assetId: string, form: FormData) {
    const unitPrice = parseMoney(form.get("unit_price"));
    const quoteDate = String(form.get("quote_date") || "");

    try {
      const res = await fetch("/api/investments/quotes", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspace.id,
          asset_id: assetId,
          unit_price: unitPrice,
          quote_date: quoteDate,
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setMessage("Cotação atualizada.");
        setDialog(null);
        await loadHub();
        return;
      }
    } catch {
      // fallback to supabase
    }

    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("investment_quotes").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      context_id: defaultContextId,
      asset_id: assetId,
      quote_date: quoteDate,
      unit_price: unitPrice,
    });
    setMessage(error ? "Não foi possível atualizar a cotação." : "Cotação atualizada.");
    if (!error) setDialog(null);
    await loadHub();
  }

  const buyDialog = dialog?.kind === "buy" ? dialog : null;
  const sellDialog = dialog?.kind === "sell" ? dialog : null;
  const quoteDialog = dialog?.kind === "quote" ? dialog : null;
  const today = new Date().toISOString().slice(0, 10);

  const activeQuoteAsset = quoteDialog ? assets.find((a) => a.id === quoteDialog.assetId) : null;

  return (
    <main className="dashboard-shell">
      <Nav />
      <PageHeader
        title="Investimentos"
        subtitle="Ativos, compras, vendas e cotações em tempo real"
        workspaceName={workspace.name}
        action={action}
      />

      {/* Benchmark Ticker Bar */}
      <div
        className="dashboard-card"
        style={{
          display: "flex",
          gap: "12px",
          flexWrap: "wrap",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "12px 18px",
          marginTop: "-8px",
          marginBottom: "18px",
        }}
      >
        <div style={{ display: "flex", gap: "12px", flexWrap: "wrap", alignItems: "center" }}>
          <span
            style={{
              fontSize: "0.82rem",
              fontWeight: 600,
              color: "var(--muted, #888)",
              display: "flex",
              alignItems: "center",
              gap: "6px",
            }}
          >
            <Sparkles size={15} style={{ color: "#F5A623" }} /> Mercado B3 & BACEN:
          </span>
          <span
            className="badge"
            style={{
              background: "rgba(59,130,246,.12)",
              color: "#60A5FA",
              padding: "4px 10px",
              borderRadius: "8px",
              fontSize: "0.85rem",
              fontWeight: 600,
            }}
          >
            🏛️ Selic Meta: {benchmarks ? `${benchmarks.selic.toFixed(2).replace(".", ",")}% a.a.` : "14,00% a.a."}
          </span>
          <span
            className="badge"
            style={{
              background: "rgba(139,92,246,.12)",
              color: "#A78BFA",
              padding: "4px 10px",
              borderRadius: "8px",
              fontSize: "0.85rem",
              fontWeight: 600,
            }}
          >
            📊 CDI: {benchmarks ? `~${benchmarks.cdi.toFixed(2).replace(".", ",")}% a.a.` : "~13,90% a.a."}
          </span>
          {benchmarks?.ibovespa && (
            <span
              className="badge"
              style={{
                background: "rgba(255,255,255,.05)",
                color: "var(--text-main, #eee)",
                padding: "4px 10px",
                borderRadius: "8px",
                fontSize: "0.85rem",
                fontWeight: 500,
              }}
            >
              📈 IBOV: {benchmarks.ibovespa.toLocaleString("pt-BR")} pts{" "}
              {benchmarks.ibovespa_change != null && (
                <small
                  style={{
                    color: benchmarks.ibovespa_change >= 0 ? "#22C55E" : "#EF4444",
                    marginLeft: "4px",
                    fontWeight: 600,
                  }}
                >
                  {benchmarks.ibovespa_change >= 0 ? "+" : ""}
                  {benchmarks.ibovespa_change.toFixed(2)}%
                </small>
              )}
            </span>
          )}
          {benchmarks?.ifix && (
            <span
              className="badge"
              style={{
                background: "rgba(255,255,255,.05)",
                color: "var(--text-main, #eee)",
                padding: "4px 10px",
                borderRadius: "8px",
                fontSize: "0.85rem",
                fontWeight: 500,
              }}
            >
              🏢 IFIX: {benchmarks.ifix.toLocaleString("pt-BR")} pts{" "}
              {benchmarks.ifix_change != null && (
                <small
                  style={{
                    color: benchmarks.ifix_change >= 0 ? "#22C55E" : "#EF4444",
                    marginLeft: "4px",
                    fontWeight: 600,
                  }}
                >
                  {benchmarks.ifix_change >= 0 ? "+" : ""}
                  {benchmarks.ifix_change.toFixed(2)}%
                </small>
              )}
            </span>
          )}
        </div>

        <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
          {lastSyncedTime && (
            <span className="muted" style={{ fontSize: "0.78rem" }}>
              Atualizado: {lastSyncedTime}
            </span>
          )}
          <button
            type="button"
            className="button-secondary ui-button--sm"
            onClick={() => syncMarketQuotes(false)}
            disabled={syncingQuotes}
            style={{ display: "inline-flex", alignItems: "center", gap: "6px" }}
          >
            <RefreshCw size={13} className={syncingQuotes ? "animate-spin" : ""} />
            {syncingQuotes ? "Sincronizando..." : "Sincronizar Cotações (API)"}
          </button>
        </div>
      </div>

      {message && (
        <p
          className={message.startsWith("Não") || message.startsWith("Erro") ? "form-error" : "form-success"}
          role={message.startsWith("Não") || message.startsWith("Erro") ? "alert" : "status"}
          style={{ marginBottom: "16px" }}
        >
          {message}
        </p>
      )}

      <div className="bento-row" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
        <article className="metric-card metric-card--positive">
          <div className="metric-card__head">
            <span className="muted">Patrimônio investido</span>
            <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6" }}>
              <WalletCards size={18} aria-hidden="true" />
            </span>
          </div>
          <strong>{money(currentCents / 100)}</strong>
        </article>
        <article className="metric-card">
          <div className="metric-card__head">
            <span className="muted">Custo total</span>
            <span className="metric-icon-badge" style={{ background: "rgba(59,130,246,.15)", color: "#3B82F6" }}>
              <PiggyBank size={18} aria-hidden="true" />
            </span>
          </div>
          <strong>{money(investedCents / 100)}</strong>
        </article>
        <article className={`metric-card ${gainCents >= 0 ? "metric-card--positive" : "metric-card--negative"}`}>
          <div className="metric-card__head">
            <span className="muted">{gainCents >= 0 ? "Ganho" : "Perda"}</span>
            <span
              className="metric-icon-badge"
              style={{
                background: gainCents >= 0 ? "rgba(34,197,94,.15)" : "rgba(239,68,68,.15)",
                color: gainCents >= 0 ? "#22C55E" : "#EF4444",
              }}
            >
              {gainCents >= 0 ? <TrendingUp size={18} aria-hidden="true" /> : <TrendingDown size={18} aria-hidden="true" />}
            </span>
          </div>
          <strong>
            {money(Math.abs(gainCents) / 100)} ({gainPct >= 0 ? "+" : ""}
            {gainPct.toFixed(1)}%)
          </strong>
        </article>
      </div>

      <div style={{ marginTop: "24px" }}>
        <InvestmentGrowthWidget
          assets={assets}
          positions={positionByAsset}
          latestQuotes={latestQuote}
          totalInvested={investedCents / 100}
          totalGainPercent={gainPct}
        />
      </div>

      <div style={{ marginTop: "24px" }}>
        <FireDashboardWidget monthlyExpenses={6000} currentNetWorth={investedCents / 100} />
      </div>

      <List title="Ativos em Carteira">
        {assets.length === 0 && (
          <p className="dashboard-empty">
            Nenhum ativo cadastrado.{" "}
            <button
              type="button"
              onClick={() => {
                setTickerQuery("");
                setSearchResults([]);
                setSelectedAssetQuote(null);
                setDialog({ kind: "asset" });
              }}
            >
              Cadastrar primeiro investimento
            </button>
          </p>
        )}
        {assets.map((a) => {
          const pos = positionByAsset[a.id];
          const price = latestQuote[a.id] ?? null;
          const current = pos && price && pos.quantity > 0 ? pos.quantity * price : null;
          const meta = quoteMeta[a.id] || quoteMeta[a.ticker || a.name];
          const tickerDisplay = a.ticker || a.name;

          return (
            <article className="account-row" key={a.id} style={{ flexWrap: "wrap", padding: "14px 16px" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "12px", minWidth: "220px", flex: "1 1 auto" }}>
                <span
                  className="metric-icon-badge"
                  style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6", marginLeft: 0 }}
                >
                  <WalletCards size={18} aria-hidden="true" />
                </span>
                <div className="tx-row__body">
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", flexWrap: "wrap" }}>
                    <span
                      style={{
                        fontFamily: "monospace",
                        fontWeight: 700,
                        fontSize: "0.95rem",
                        background: "rgba(255,255,255,0.08)",
                        padding: "2px 7px",
                        borderRadius: "5px",
                        color: "var(--text-main, #fff)",
                      }}
                    >
                      {tickerDisplay}
                    </span>
                    <strong style={{ fontSize: "0.95rem" }}>{a.name}</strong>
                  </div>
                  <small style={{ display: "flex", gap: "8px", alignItems: "center", marginTop: "3px" }}>
                    <span className="badge-subtle">{ASSET_TYPES[a.type] ?? a.type}</span>
                    {a.exchange && <span>· Custódia: <strong>{a.exchange}</strong></span>}
                  </small>
                </div>
              </div>

              <div style={{ textAlign: "right", minWidth: "170px" }}>
                <div style={{ display: "flex", alignItems: "baseline", justifyContent: "flex-end", gap: "6px" }}>
                  <span style={{ fontSize: "0.82rem", color: "var(--muted, #888)" }}>Cotação:</span>
                  <b style={{ fontSize: "1.05rem" }}>{price != null ? money(price) : "—"}</b>
                  {meta?.change_pct != null && (
                    <span
                      style={{
                        fontSize: "0.75rem",
                        fontWeight: 600,
                        color: meta.change_pct >= 0 ? "#22C55E" : "#EF4444",
                        background: meta.change_pct >= 0 ? "rgba(34,197,94,0.12)" : "rgba(239,68,68,0.12)",
                        padding: "1px 5px",
                        borderRadius: "4px",
                      }}
                    >
                      {meta.change_pct >= 0 ? "+" : ""}
                      {meta.change_pct.toFixed(2)}%
                    </span>
                  )}
                </div>
                <small className="muted" style={{ display: "block", marginTop: "2px" }}>
                  {pos && pos.quantity > 0
                    ? `${pos.quantity} cotas · Posição: ${money(current ?? 0)} · Médio: ${money(
                        pos.costCents / 100 / pos.quantity
                      )}`
                    : "Sem operações (0 cotas)"}
                </small>
              </div>

              <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
                <button
                  type="button"
                  className="button-secondary ui-button--sm"
                  onClick={() => setDialog({ kind: "buy", assetId: a.id })}
                >
                  Comprar
                </button>
                <button
                  type="button"
                  className="ghost-button ui-button--sm"
                  onClick={() => setDialog({ kind: "sell", assetId: a.id })}
                >
                  Vender
                </button>
                <button
                  type="button"
                  className="ghost-button ui-button--sm"
                  title="Atualizar cotação via API do mercado"
                  onClick={() => syncSingleAssetQuote(a)}
                  style={{ display: "inline-flex", alignItems: "center", gap: "4px" }}
                >
                  <RefreshCw size={12} />
                  Cotação
                </button>
              </div>
            </article>
          );
        })}
      </List>

      {operations.length > 0 && (
        <List title="Operações recentes">
          {operations.slice(0, 30).map((op) => {
            const asset = assets.find((x) => x.id === op.asset_id);
            const isBuy = op.operation_type === "buy";
            return (
              <article className="account-row" key={op.id}>
                <span
                  className="metric-icon-badge"
                  style={
                    isBuy
                      ? { background: "rgba(34,197,94,.15)", color: "#22C55E", marginLeft: 0 }
                      : { background: "rgba(245,166,35,.15)", color: "#F5A623", marginLeft: 0 }
                  }
                >
                  {isBuy ? <TrendingUp size={18} aria-hidden="true" /> : <TrendingDown size={18} aria-hidden="true" />}
                </span>
                <div className="tx-row__body">
                  <strong>
                    {isBuy ? "Compra" : "Venda"} · {asset?.ticker || asset?.name || "Ativo"}
                  </strong>
                  <small>{dateFmt.format(new Date(`${op.operation_date}T12:00:00`))}</small>
                </div>
                <b style={{ whiteSpace: "nowrap" }}>{money(op.quantity * op.unit_price)}</b>
              </article>
            );
          })}
        </List>
      )}

      <Dialog
        open={dialog !== null}
        onClose={() => {
          setDialog(null);
          setSearchResults([]);
          setSelectedAssetQuote(null);
        }}
        title={dialogTitle}
      >
        {dialog?.kind === "asset" && (
          <SimpleForm key="asset" onSubmit={submitAsset}>
            <p className="muted" style={{ fontSize: "0.85rem", marginBottom: "8px" }}>
              Digite o código do ticker da B3 ou busque pelo nome da empresa/FII. As cotações serão alimentadas automaticamente via API.
            </p>

            <label htmlFor="asset-ticker">Código / Ticker (ex: MXRF11, PETR4, VALE3, IVVB11)</label>
            <div style={{ position: "relative" }}>
              <input
                id="asset-ticker"
                name="ticker"
                maxLength={30}
                placeholder="Ex.: MXRF11"
                value={tickerQuery}
                onChange={(e) => handleTickerInputChange(e.target.value)}
                required
                autoFocus
                style={{ textTransform: "uppercase", fontFamily: "monospace", fontWeight: 600 }}
              />
              {searching && (
                <div style={{ position: "absolute", right: 10, top: 10 }}>
                  <RefreshCw size={16} className="animate-spin text-muted" />
                </div>
              )}
            </div>

            {searchResults.length > 0 && (
              <div
                style={{
                  maxHeight: "180px",
                  overflowY: "auto",
                  background: "var(--card-bg, rgba(20,20,25,0.95))",
                  border: "1px solid var(--border-color, rgba(255,255,255,0.12))",
                  borderRadius: "8px",
                  marginTop: "4px",
                  marginBottom: "8px",
                }}
              >
                {searchResults.map((sr) => (
                  <div
                    key={sr.symbol}
                    onClick={() => handleSelectSearchResult(sr)}
                    style={{
                      padding: "8px 12px",
                      cursor: "pointer",
                      borderBottom: "1px solid rgba(255,255,255,0.06)",
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                    onMouseEnter={(e) => {
                      e.currentTarget.style.background = "rgba(255,255,255,0.06)";
                    }}
                    onMouseLeave={(e) => {
                      e.currentTarget.style.background = "transparent";
                    }}
                  >
                    <div>
                      <strong style={{ fontFamily: "monospace", color: "#60A5FA", marginRight: 8 }}>{sr.ticker}</strong>
                      <span style={{ fontSize: "0.85rem" }}>{sr.name}</span>
                    </div>
                    <span className="badge-subtle" style={{ fontSize: "0.75rem" }}>
                      {ASSET_TYPES[sr.type] ?? sr.type}
                    </span>
                  </div>
                ))}
              </div>
            )}

            {selectedAssetQuote != null && (
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  background: "rgba(34,197,94,0.12)",
                  border: "1px solid rgba(34,197,94,0.25)",
                  padding: "8px 12px",
                  borderRadius: "8px",
                  marginTop: "8px",
                  marginBottom: "8px",
                  fontSize: "0.85rem",
                  color: "#22C55E",
                }}
              >
                <Sparkles size={16} />
                <span>Cotação atual de mercado encontrada: <strong>{money(selectedAssetQuote)}</strong></span>
              </div>
            )}

            <label htmlFor="asset-name">Nome amigável / Descrição</label>
            <input
              id="asset-name"
              name="name"
              maxLength={120}
              placeholder="Ex.: Maxi Renda FII"
              defaultValue={searchResults.find((s) => s.ticker === tickerQuery.toUpperCase())?.name || ""}
              required
            />

            <label htmlFor="asset-type">Tipo de investimento</label>
            <select
              id="asset-type"
              name="type"
              defaultValue={searchResults.find((s) => s.ticker === tickerQuery.toUpperCase())?.type || "reit"}
              required
            >
              {Object.entries(ASSET_TYPES).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>

            <label htmlFor="asset-broker">Corretora / Custódia</label>
            <input
              id="asset-broker"
              name="broker"
              maxLength={60}
              defaultValue="Rico"
              placeholder="Ex.: Rico, XP, Inter, BTG, Santander"
            />

            <label
              className="account-row"
              style={{ marginTop: "1rem", display: "flex", justifyContent: "space-between", alignItems: "center" }}
            >
              <span>Compartilhar Ativo (visível para família)</span>
              <input type="checkbox" name="is_shared" defaultChecked />
            </label>

            <button style={{ marginTop: "1rem" }}>Cadastrar ativo e sincronizar cotação</button>
          </SimpleForm>
        )}

        {buyDialog && (
          <SimpleForm key="buy" onSubmit={(form) => submitOperation(buyDialog.assetId, "buy", form)}>
            <label htmlFor="buy-account">Conta de saída</label>
            <select id="buy-account" name="account_id" defaultValue={defaultCashAccountId ?? ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.name}
                </option>
              ))}
            </select>
            <label htmlFor="buy-quantity">Quantidade (cotas/ações)</label>
            <input id="buy-quantity" name="quantity" placeholder="0,00" inputMode="decimal" required />
            <label htmlFor="buy-price">Preço unitário</label>
            <input
              id="buy-price"
              name="unit_price"
              placeholder="0,00"
              defaultValue={latestQuote[buyDialog.assetId] ? latestQuote[buyDialog.assetId].toFixed(2).replace(".", ",") : ""}
              required
            />
            <label htmlFor="buy-date">Data da operação</label>
            <input id="buy-date" name="operation_date" type="date" defaultValue={today} required />
            <button>Registrar compra</button>
          </SimpleForm>
        )}

        {sellDialog && (
          <SimpleForm key="sell" onSubmit={(form) => submitOperation(sellDialog.assetId, "sell", form)}>
            <label htmlFor="sell-account">Conta de entrada</label>
            <select id="sell-account" name="account_id" defaultValue={defaultCashAccountId ?? ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.name}
                </option>
              ))}
            </select>
            <label htmlFor="sell-quantity">Quantidade</label>
            <input id="sell-quantity" name="quantity" placeholder="0,00" inputMode="decimal" required />
            <label htmlFor="sell-price">Preço unitário</label>
            <input
              id="sell-price"
              name="unit_price"
              placeholder="0,00"
              defaultValue={latestQuote[sellDialog.assetId] ? latestQuote[sellDialog.assetId].toFixed(2).replace(".", ",") : ""}
              required
            />
            <label htmlFor="sell-date">Data da operação</label>
            <input id="sell-date" name="operation_date" type="date" defaultValue={today} required />
            <button>Registrar venda</button>
          </SimpleForm>
        )}

        {quoteDialog && activeQuoteAsset && (
          <SimpleForm key="quote" onSubmit={(form) => submitQuote(quoteDialog.assetId, form)}>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                marginBottom: "14px",
                padding: "10px 14px",
                background: "rgba(255,255,255,0.05)",
                borderRadius: "8px",
              }}
            >
              <div>
                <strong style={{ fontFamily: "monospace", fontSize: "1rem" }}>
                  {activeQuoteAsset.ticker || activeQuoteAsset.name}
                </strong>
                <span className="muted" style={{ display: "block", fontSize: "0.82rem" }}>
                  {activeQuoteAsset.name}
                </span>
              </div>
              <button
                type="button"
                className="button-secondary ui-button--sm"
                onClick={() => {
                  setDialog(null);
                  void syncSingleAssetQuote(activeQuoteAsset);
                }}
              >
                <RefreshCw size={12} style={{ marginRight: 4 }} />
                Buscar cotação na B3
              </button>
            </div>

            <p className="muted" style={{ fontSize: "0.85rem" }}>
              Ou digite o valor unitário manualmente:
            </p>
            <label htmlFor="quote-date">Data da cotação</label>
            <input id="quote-date" name="quote_date" type="date" defaultValue={today} required />
            <label htmlFor="quote-price">Preço unitário</label>
            <input
              id="quote-price"
              name="unit_price"
              placeholder="0,00"
              defaultValue={latestQuote[activeQuoteAsset.id] ? latestQuote[activeQuoteAsset.id].toFixed(2).replace(".", ",") : ""}
              required
            />
            <button>Salvar cotação</button>
          </SimpleForm>
        )}
      </Dialog>
    </main>
  );
}
