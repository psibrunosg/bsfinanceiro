"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { SimpleForm } from "../components/SimpleForm";
import { List } from "../components/List";
import { money, parseMoney, dateFmt } from "../components/Money";
import { createClient } from "@/lib/supabase/client";
import { WalletCards, TrendingUp, TrendingDown, PiggyBank } from "lucide-react";
import { InvestmentGrowthWidget } from "../components/InvestmentGrowthWidget";
import { FireDashboardWidget } from "../components/FireDashboardWidget";

const ASSET_TYPES: Record<string, string> = {
  stock: "Ações",
  reit: "FIIs",
  fund: "Fundos",
  fixed_income: "Renda fixa",
  real_estate: "Imóveis",
};

type Asset = {
  id: string;
  name: string;
  type: string;
  exchange: string | null;
  created_at: string;
};
type Operation = {
  id: string;
  asset_id: string;
  operation_type: "buy" | "sell";
  quantity: number;
  unit_price: number;
  operation_date: string;
  transaction_id: string | null;
};
type Quote = {
  id: string;
  asset_id: string;
  quote_date: string;
  unit_price: number;
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
  const [defaultContextId, setDefaultContextId] = useState<string | null>(null);
  const [dialog, setDialog] = useState<DialogState>(null);
  const [message, setMessage] = useState("");
  const [hubLoading, setHubLoading] = useState(true);

  const loadHub = useCallback(async () => {
    if (!workspace) return;
    try {
      const { data: userData } = await supabase.auth.getUser();
      const ownerId = userData.user?.id;
      if (!ownerId) return;
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
            .select("id,name,type,exchange,created_at")
            .eq("workspace_id", workspace.id)
            .eq("active", true)
            .order("name"),
          supabase
            .from("investment_operations")
            .select("id,asset_id,operation_type,quantity,unit_price,operation_date,transaction_id")
            .eq("workspace_id", workspace.id)
            .order("operation_date", { ascending: false })
            .limit(500),
          supabase
            .from("investment_quotes")
            .select("id,asset_id,quote_date,unit_price")
            .eq("workspace_id", workspace.id)
            .order("quote_date", { ascending: false })
            .limit(500),
        ]);
      setDefaultContextId(contextRows?.id ?? null);
      setAssets(assetRows ?? []);
      setOperations(operationRows ?? []);
      setQuotes(quoteRows ?? []);
    } finally {
      setHubLoading(false);
    }
  }, [supabase, workspace]);

  useEffect(() => {
    void loadHub();
  }, [loadHub]);

  if (loading || !workspace || hubLoading) {
    return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;
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
      : { label: "Cadastrar ativo", onClick: () => setDialog({ kind: "asset" }) };

  const dialogTitle =
    dialog?.kind === "asset" ? "Cadastrar ativo"
      : dialog?.kind === "buy" ? "Registrar compra"
        : dialog?.kind === "sell" ? "Registrar venda"
          : dialog?.kind === "quote" ? "Atualizar cotação" : "";

  async function submitAsset(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("investment_assets").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      context_id: defaultContextId,
      name: form.get("name"),
      type: form.get("type"),
      exchange: form.get("exchange") || null,
      is_shared: form.get("is_shared") === "on",
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
    const { error } = await supabase.rpc("record_investment_operation", {
      p_asset_id: assetId,
      p_account_id: accountId,
      p_type: kind,
      p_quantity: quantity,
      p_price: price,
      p_amount: amount,
      p_date: form.get("operation_date"),
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
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("investment_quotes").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      context_id: defaultContextId,
      asset_id: assetId,
      quote_date: form.get("quote_date"),
      unit_price: parseMoney(form.get("unit_price")),
    });
    setMessage(error ? "Não foi possível atualizar a cotação." : "Cotação atualizada.");
    if (!error) setDialog(null);
    await loadHub();
  }

  const buyDialog = dialog?.kind === "buy" ? dialog : null;
  const sellDialog = dialog?.kind === "sell" ? dialog : null;
  const quoteDialog = dialog?.kind === "quote" ? dialog : null;
  const today = new Date().toISOString().slice(0, 10);

  return (
    <main className="dashboard-shell">
      <Nav />
      <PageHeader
        title="Investimentos"
        subtitle="Ativos, compras, vendas e cotações"
        workspaceName={workspace.name}
        action={action}
      />
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}

      <div className="bento-row" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
        <article className="metric-card metric-card--positive">
          <div className="metric-card__head">
            <span className="muted">Patrimônio investido</span>
            <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6" }}><WalletCards size={18} aria-hidden="true" /></span>
          </div>
          <strong>{money(currentCents / 100)}</strong>
        </article>
        <article className="metric-card">
          <div className="metric-card__head">
            <span className="muted">Custo total</span>
            <span className="metric-icon-badge" style={{ background: "rgba(59,130,246,.15)", color: "#3B82F6" }}><PiggyBank size={18} aria-hidden="true" /></span>
          </div>
          <strong>{money(investedCents / 100)}</strong>
        </article>
        <article className={`metric-card ${gainCents >= 0 ? "metric-card--positive" : "metric-card--negative"}`}>
          <div className="metric-card__head">
            <span className="muted">{gainCents >= 0 ? "Ganho" : "Perda"}</span>
            <span className="metric-icon-badge" style={{ background: gainCents >= 0 ? "rgba(34,197,94,.15)" : "rgba(239,68,68,.15)", color: gainCents >= 0 ? "#22C55E" : "#EF4444" }}>
              {gainCents >= 0 ? <TrendingUp size={18} aria-hidden="true" /> : <TrendingDown size={18} aria-hidden="true" />}
            </span>
          </div>
          <strong>{money(Math.abs(gainCents) / 100)} ({gainPct >= 0 ? "+" : ""}{gainPct.toFixed(1)}%)</strong>
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
        <FireDashboardWidget
          monthlyExpenses={6000}
          currentNetWorth={investedCents / 100}
        />
      </div>

      <List title="Ativos">
        {assets.length === 0 && (
          <p className="dashboard-empty">Nenhum ativo cadastrado.{" "}
            <button type="button" onClick={() => setDialog({ kind: "asset" })}>Cadastrar primeiro investimento</button>
          </p>
        )}
        {assets.map((a) => {
          const pos = positionByAsset[a.id];
          const price = latestQuote[a.id] ?? null;
          const current = pos && price ? pos.quantity * price : null;
          return (
            <article className="account-row" key={a.id} style={{ flexWrap: "wrap" }}>
              <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6", marginLeft: 0 }}>
                <WalletCards size={18} aria-hidden="true" />
              </span>
              <div className="tx-row__body">
                <strong>{a.name}</strong>
                <small>
                  {ASSET_TYPES[a.type] ?? a.type}
                  {a.exchange ? ` · ${a.exchange}` : ""}
                </small>
              </div>
              <div style={{ textAlign: "right" }}>
                <b>{current != null ? money(current) : money(pos?.costCents ? pos.costCents / 100 : 0)}</b>
                <small className="muted" style={{ display: "block" }}>
                  {pos ? `${pos.quantity} · custo médio ${money(pos.quantity > 0 ? pos.costCents / 100 / pos.quantity : 0)}` : "Sem operações"}
                </small>
              </div>
              <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                <button type="button" onClick={() => setDialog({ kind: "buy", assetId: a.id })}>Comprar</button>
                <button type="button" onClick={() => setDialog({ kind: "sell", assetId: a.id })}>Vender</button>
                <button type="button" onClick={() => setDialog({ kind: "quote", assetId: a.id })}>Cotação</button>
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
                  style={isBuy
                    ? { background: "rgba(34,197,94,.15)", color: "#22C55E", marginLeft: 0 }
                    : { background: "rgba(245,166,35,.15)", color: "#F5A623", marginLeft: 0 }}
                >
                  {isBuy ? <TrendingUp size={18} aria-hidden="true" /> : <TrendingDown size={18} aria-hidden="true" />}
                </span>
                <div className="tx-row__body">
                  <strong>{isBuy ? "Compra" : "Venda"} · {asset?.name ?? "Ativo"}</strong>
                  <small>{dateFmt.format(new Date(`${op.operation_date}T12:00:00`))}</small>
                </div>
                <b style={{ whiteSpace: "nowrap" }}>{money(op.quantity * op.unit_price)}</b>
              </article>
            );
          })}
        </List>
      )}

      <Dialog open={dialog !== null} onClose={() => setDialog(null)} title={dialogTitle}>
        {dialog?.kind === "asset" && (
            <SimpleForm key="asset" onSubmit={submitAsset}>
              <label htmlFor="asset-name">Nome do ativo</label>
              <input id="asset-name" name="name" maxLength={120} placeholder="Ex.: Tesouro Selic 2029" required autoFocus />
              <label htmlFor="asset-type">Tipo</label>
              <select id="asset-type" name="type" defaultValue="fixed_income" required>
                {Object.entries(ASSET_TYPES).map(([value, label]) => (
                  <option key={value} value={value}>{label}</option>
                ))}
              </select>
              <label htmlFor="asset-exchange">Corretora</label>
              <input id="asset-exchange" name="exchange" maxLength={60} placeholder="Corretora (opcional)" />
              
              <label className="account-row" style={{ marginTop: "1rem", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <span>Compartilhar Ativo (visível para família)</span>
                <input type="checkbox" name="is_shared" defaultChecked />
              </label>

              <button style={{ marginTop: "1rem" }}>Cadastrar ativo</button>
            </SimpleForm>
        )}
        {buyDialog && (
          <SimpleForm key="buy" onSubmit={(form) => submitOperation(buyDialog.assetId, "buy", form)}>
            <label htmlFor="buy-account">Conta de saída</label>
            <select id="buy-account" name="account_id" defaultValue={defaultCashAccountId ?? ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="buy-quantity">Quantidade</label>
            <input id="buy-quantity" name="quantity" placeholder="0,00" inputMode="decimal" required />
            <label htmlFor="buy-price">Preço unitário</label>
            <input id="buy-price" name="unit_price" placeholder="0,00" required />
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
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="sell-quantity">Quantidade</label>
            <input id="sell-quantity" name="quantity" placeholder="0,00" inputMode="decimal" required />
            <label htmlFor="sell-price">Preço unitário</label>
            <input id="sell-price" name="unit_price" placeholder="0,00" required />
            <label htmlFor="sell-date">Data da operação</label>
            <input id="sell-date" name="operation_date" type="date" defaultValue={today} required />
            <button>Registrar venda</button>
          </SimpleForm>
        )}
        {quoteDialog && (
          <SimpleForm key="quote" onSubmit={(form) => submitQuote(quoteDialog.assetId, form)}>
            <p className="muted">Atualizar a cotação manualmente. Cotação desatualizada dispara alerta.</p>
            <label htmlFor="quote-date">Data da cotação</label>
            <input id="quote-date" name="quote_date" type="date" defaultValue={today} required />
            <label htmlFor="quote-price">Preço unitário</label>
            <input id="quote-price" name="unit_price" placeholder="0,00" required />
            <button>Atualizar cotação</button>
          </SimpleForm>
        )}
      </Dialog>
    </main>
  );
}
