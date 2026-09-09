"use client";

import { useMemo, useState } from "react";
import {
  AlertCircle,
  CheckCircle2,
  Clock,
  CreditCard as CreditCardIcon,
  FileText,
  Printer,
  Receipt,
  X,
  Zap,
} from "lucide-react";
import { BrandLogo } from "../brand-logo";
import { Account, Card, Invoice } from "./types";
import { money, dateFmt } from "./Money";

type InvoiceMirrorModalProps = {
  card?: Card | null;
  invoice: Invoice;
  allInvoices?: Invoice[];
  accounts?: Account[];
  workspaceId?: string;
  onClose: () => void;
  onSelectInvoice?: (invoice: Invoice) => void;
  onPaid?: () => Promise<void>;
};

export function InvoiceMirrorModal({
  card,
  invoice: initialInvoice,
  allInvoices = [],
  accounts = [],
  workspaceId,
  onClose,
  onSelectInvoice,
  onPaid,
}: InvoiceMirrorModalProps) {
  const [selectedInvoiceId, setSelectedInvoiceId] = useState(initialInvoice.id);

  // Estados para pagamento de fatura
  const [showPayModal, setShowPayModal] = useState(false);
  const [payAccountId, setPayAccountId] = useState(
    () => accounts.find((a) => a.type !== "credit_card")?.id || accounts[0]?.id || ""
  );
  const [payDate, setPayDate] = useState(() => new Date().toISOString().slice(0, 10));
  const [paying, setPaying] = useState(false);
  const [payError, setPayError] = useState("");
  const [paySuccessMsg, setPaySuccessMsg] = useState("");

  const activeInvoice = useMemo(() => {
    return allInvoices.find((inv) => inv.id === selectedInvoiceId) || initialInvoice;
  }, [allInvoices, selectedInvoiceId, initialInvoice]);

  const items = useMemo(() => activeInvoice.credit_card_installments || [], [activeInvoice.credit_card_installments]);
  const installmentsTotal = items.reduce((s, i) => s + Number(i.amount), 0);
  const totalAmount = installmentsTotal > 0 ? installmentsTotal : Number(activeInvoice.total_amount || 0);

  const isPaid = activeInvoice.status === "paid" || !!paySuccessMsg;

  // Análise de itens "Pula Compra" e encargos
  const pulaCompraStats = useMemo(() => {
    let financedCount = 0;
    let financedTotal = 0;
    let creditTotal = 0;
    let iofTotal = 0;

    items.forEach((item) => {
      const p = Array.isArray(item.credit_card_purchases)
        ? item.credit_card_purchases[0]
        : item.credit_card_purchases;
      const desc = (p?.description || "").toUpperCase().trim();
      const amt = Number(item.amount || 0);

      if (desc.includes("CREDITO PULA COMPRA") || desc.includes("CRÉDITO PULA COMPRA")) {
        creditTotal += amt;
      } else if (desc.startsWith("FIN ") || desc.includes("FIN ") || desc.includes("PULA COMPRA")) {
        financedCount++;
        financedTotal += amt;
      } else if (desc.includes("IOF")) {
        iofTotal += amt;
      }
    });

    const hasPulaCompra = financedCount > 0 || creditTotal > 0 || iofTotal > 0;
    return {
      hasPulaCompra,
      financedCount,
      financedTotal,
      creditTotal,
      iofTotal,
    };
  }, [items]);

  function formatInvoiceMonth(dueDateStr: string) {
    try {
      const d = new Date(`${dueDateStr}T12:00:00`);
      return d.toLocaleDateString("pt-BR", { month: "long", year: "numeric" });
    } catch {
      return dueDateStr;
    }
  }

  function handlePrint() {
    if (typeof window !== "undefined") {
      window.print();
    }
  }

  async function handlePayInvoice(e?: React.FormEvent) {
    if (e) e.preventDefault();
    if (!payAccountId) {
      setPayError("Selecione uma conta bancária para débito do pagamento.");
      return;
    }
    setPaying(true);
    setPayError("");
    setPaySuccessMsg("");

    try {
      const res = await fetch("/api/cards/pay-invoice", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          invoice_id: activeInvoice.id,
          account_id: payAccountId,
          paid_at: payDate,
          amount: totalAmount,
          workspace_id: workspaceId,
        }),
      });

      const data = await res.json();
      if (!res.ok || data.error) {
        throw new Error(data.error || "Falha ao registrar pagamento da fatura.");
      }

      setPaySuccessMsg("Fatura quitada com sucesso!");
      setShowPayModal(false);
      if (onPaid) {
        await onPaid();
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro inesperado ao pagar fatura.";
      setPayError(msg);
    } finally {
      setPaying(false);
    }
  }

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="invoice-mirror-title"
      style={{
        position: "fixed",
        inset: 0,
        backgroundColor: "rgba(0, 0, 0, 0.75)",
        backdropFilter: "blur(4px)",
        zIndex: 9999,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "1rem",
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className="dashboard-card"
        style={{
          width: "100%",
          maxWidth: "680px",
          maxHeight: "90vh",
          overflowY: "auto",
          background: "var(--surface, #11151F)",
          border: "1px solid var(--border, rgba(255,255,255,0.1))",
          borderRadius: "20px",
          padding: "2rem",
          boxShadow: "0 20px 40px rgba(0,0,0,0.5)",
          color: "var(--text, #F8FAFC)",
        }}
      >
        {/* Top bar with Print & Close */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "1.5rem",
            borderBottom: "1px solid var(--border, rgba(255,255,255,0.08))",
            paddingBottom: "1rem",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
            <span
              style={{
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                width: "40px",
                height: "40px",
                borderRadius: "10px",
                background: "rgba(139, 92, 246, 0.15)",
                color: "#8B5CF6",
              }}
            >
              <FileText size={22} />
            </span>
            <div>
              <h2
                id="invoice-mirror-title"
                style={{ fontSize: "1.25rem", margin: 0, fontWeight: 700 }}
              >
                Espelho da Fatura
              </h2>
              <span className="muted" style={{ fontSize: "0.85rem" }}>
                Extrato detalhado do cartão
              </span>
            </div>
          </div>

          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <button
              type="button"
              onClick={handlePrint}
              title="Imprimir ou Salvar PDF"
              aria-label="Imprimir espelho"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                padding: "6px 12px",
                borderRadius: "8px",
                fontSize: "0.85rem",
                background: "var(--surface-2, rgba(255,255,255,0.05))",
                border: "1px solid var(--border, rgba(255,255,255,0.1))",
                color: "var(--text, #F8FAFC)",
                cursor: "pointer",
              }}
            >
              <Printer size={16} />
              <span>Imprimir</span>
            </button>
            <button
              type="button"
              onClick={onClose}
              aria-label="Fechar espelho"
              style={{
                background: "none",
                border: "none",
                color: "var(--muted, #94A3B8)",
                padding: "6px",
                borderRadius: "8px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
              }}
            >
              <X size={22} />
            </button>
          </div>
        </div>

        {/* Feedback message */}
        {paySuccessMsg && (
          <div
            role="status"
            style={{
              padding: "12px 16px",
              marginBottom: "1rem",
              borderRadius: "10px",
              background: "rgba(34, 197, 94, 0.15)",
              border: "1px solid rgba(34, 197, 94, 0.3)",
              color: "#22C55E",
              fontSize: "0.9rem",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              fontWeight: 600,
            }}
          >
            <CheckCircle2 size={18} />
            <span>{paySuccessMsg}</span>
          </div>
        )}

        {/* Invoice Selector if multiple invoices */}
        {allInvoices.length > 1 && (
          <div style={{ marginBottom: "1.5rem" }}>
            <label
              htmlFor="invoice-selector"
              style={{
                display: "block",
                fontSize: "0.8rem",
                fontWeight: 600,
                color: "var(--muted, #94A3B8)",
                marginBottom: "6px",
              }}
            >
              Selecionar mês da fatura:
            </label>
            <select
              id="invoice-selector"
              value={activeInvoice.id}
              onChange={(e) => {
                setSelectedInvoiceId(e.target.value);
                const found = allInvoices.find((i) => i.id === e.target.value);
                if (found && onSelectInvoice) onSelectInvoice(found);
              }}
              style={{
                width: "100%",
                padding: "8px 12px",
                borderRadius: "10px",
                background: "var(--surface-2, rgba(255,255,255,0.05))",
                border: "1px solid var(--border, rgba(255,255,255,0.1))",
                color: "var(--text, #F8FAFC)",
                fontSize: "0.9rem",
              }}
            >
              {allInvoices.map((inv) => {
                const invTotal =
                  inv.credit_card_installments && inv.credit_card_installments.length > 0
                    ? inv.credit_card_installments.reduce((s, i) => s + Number(i.amount), 0)
                    : Number(inv.total_amount || 0);
                return (
                  <option key={inv.id} value={inv.id}>
                    {formatInvoiceMonth(inv.due_date)} — Vence {dateFmt.format(new Date(`${inv.due_date}T12:00:00`))} — {money(invTotal)} ({inv.status === "paid" ? "Paga" : "Aberta"})
                  </option>
                );
              })}
            </select>
          </div>
        )}

        {/* Card Header Statement Banner */}
        <div
          style={{
            background: "linear-gradient(135deg, rgba(139,92,246,0.15) 0%, rgba(59,130,246,0.1) 100%)",
            border: "1px solid rgba(139,92,246,0.25)",
            borderRadius: "16px",
            padding: "1.25rem",
            marginBottom: "1.5rem",
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "flex-start",
              flexWrap: "wrap",
              gap: "12px",
              marginBottom: "1rem",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <span className="brand-badge">
                <BrandLogo brand={card?.brand} />
              </span>
              <div>
                <strong style={{ fontSize: "1.1rem", display: "block" }}>
                  {card?.name || "Cartão de Crédito"}
                </strong>
                <span className="muted" style={{ fontSize: "0.85rem" }}>
                  {card?.last_four ? `Final •••• ${card.last_four}` : "Cartão ativo"}
                </span>
              </div>
            </div>

            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              {isPaid ? (
                <span
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "6px",
                    padding: "6px 12px",
                    borderRadius: "20px",
                    background: "rgba(34,197,94,0.15)",
                    color: "#22C55E",
                    fontSize: "0.85rem",
                    fontWeight: 700,
                    border: "1px solid rgba(34,197,94,0.3)",
                  }}
                >
                  <CheckCircle2 size={16} /> Fatura Paga
                </span>
              ) : (
                <>
                  <span
                    style={{
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "6px",
                      padding: "6px 12px",
                      borderRadius: "20px",
                      background: "rgba(245,158,11,0.15)",
                      color: "#F59E0B",
                      fontSize: "0.85rem",
                      fontWeight: 700,
                      border: "1px solid rgba(245,158,11,0.3)",
                    }}
                  >
                    <Clock size={16} /> Fatura em Aberto
                  </span>
                  <button
                    type="button"
                    onClick={() => setShowPayModal(!showPayModal)}
                    style={{
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "6px",
                      padding: "6px 14px",
                      borderRadius: "20px",
                      background: "var(--accent, #10B981)",
                      color: "#fff",
                      border: "none",
                      fontSize: "0.85rem",
                      fontWeight: 600,
                      cursor: "pointer",
                      boxShadow: "0 2px 8px rgba(16, 185, 129, 0.3)",
                    }}
                  >
                    <CreditCardIcon size={15} />
                    {showPayModal ? "Cancelar" : "Pagar Fatura"}
                  </button>
                </>
              )}
            </div>
          </div>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
              gap: "1rem",
              borderTop: "1px solid rgba(255,255,255,0.08)",
              paddingTop: "1rem",
            }}
          >
            <div>
              <span className="muted" style={{ fontSize: "0.75rem", display: "block" }}>
                Total da Fatura
              </span>
              <strong style={{ fontSize: "1.5rem", color: isPaid ? "var(--text)" : "#EF4444" }}>
                {money(totalAmount)}
              </strong>
            </div>

            <div>
              <span className="muted" style={{ fontSize: "0.75rem", display: "block" }}>
                Vencimento
              </span>
              <strong style={{ fontSize: "0.95rem" }}>
                {dateFmt.format(new Date(`${activeInvoice.due_date}T12:00:00`))}
              </strong>
            </div>

            {activeInvoice.closing_date && (
              <div>
                <span className="muted" style={{ fontSize: "0.75rem", display: "block" }}>
                  Fechamento
                </span>
                <strong style={{ fontSize: "0.95rem" }}>
                  {dateFmt.format(new Date(`${activeInvoice.closing_date}T12:00:00`))}
                </strong>
              </div>
            )}

            {isPaid && (activeInvoice.paid_at || payDate) && (
              <div>
                <span className="muted" style={{ fontSize: "0.75rem", display: "block" }}>
                  Pago em
                </span>
                <strong style={{ fontSize: "0.95rem", color: "#22C55E" }}>
                  {dateFmt.format(new Date(`${activeInvoice.paid_at || payDate}T12:00:00`))}
                </strong>
              </div>
            )}
          </div>
        </div>

        {/* Form para Pagamento da Fatura */}
        {showPayModal && !isPaid && (
          <form
            onSubmit={handlePayInvoice}
            style={{
              background: "rgba(16, 185, 129, 0.08)",
              border: "1px solid rgba(16, 185, 129, 0.25)",
              borderRadius: "16px",
              padding: "1.25rem",
              marginBottom: "1.5rem",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "1rem", color: "#10B981" }}>
              <CreditCardIcon size={20} />
              <strong style={{ fontSize: "1rem" }}>Registrar Pagamento de Fatura</strong>
            </div>

            {payError && (
              <div
                role="alert"
                style={{
                  padding: "8px 12px",
                  borderRadius: "8px",
                  background: "rgba(239, 68, 68, 0.15)",
                  color: "#EF4444",
                  fontSize: "0.85rem",
                  marginBottom: "1rem",
                  display: "flex",
                  alignItems: "center",
                  gap: "6px",
                }}
              >
                <AlertCircle size={16} />
                <span>{payError}</span>
              </div>
            )}

            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: "1rem", marginBottom: "1rem" }}>
              <div>
                <label
                  htmlFor="pay-account"
                  style={{ display: "block", fontSize: "0.8rem", fontWeight: 600, color: "var(--muted)", marginBottom: "4px" }}
                >
                  Debitar da Conta:
                </label>
                <select
                  id="pay-account"
                  value={payAccountId}
                  onChange={(e) => setPayAccountId(e.target.value)}
                  style={{
                    width: "100%",
                    padding: "8px 12px",
                    borderRadius: "10px",
                    background: "var(--surface-2, rgba(255,255,255,0.05))",
                    border: "1px solid var(--border, rgba(255,255,255,0.15))",
                    color: "var(--text, #F8FAFC)",
                    fontSize: "0.9rem",
                  }}
                  required
                >
                  {accounts
                    .filter((a) => a.type !== "credit_card")
                    .map((a) => (
                      <option key={a.id} value={a.id}>
                        {a.name} ({a.type === "checking" ? "Conta bancária" : a.type})
                      </option>
                    ))}
                </select>
              </div>

              <div>
                <label
                  htmlFor="pay-date"
                  style={{ display: "block", fontSize: "0.8rem", fontWeight: 600, color: "var(--muted)", marginBottom: "4px" }}
                >
                  Data do Pagamento:
                </label>
                <input
                  id="pay-date"
                  type="date"
                  value={payDate}
                  onChange={(e) => setPayDate(e.target.value)}
                  style={{
                    width: "100%",
                    padding: "8px 12px",
                    borderRadius: "10px",
                    background: "var(--surface-2, rgba(255,255,255,0.05))",
                    border: "1px solid var(--border, rgba(255,255,255,0.15))",
                    color: "var(--text, #F8FAFC)",
                    fontSize: "0.9rem",
                  }}
                  required
                />
              </div>
            </div>

            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", borderTop: "1px solid rgba(255,255,255,0.08)", paddingTop: "1rem" }}>
              <span style={{ fontSize: "0.9rem" }}>
                Valor debitado: <strong style={{ color: "#10B981" }}>{money(totalAmount)}</strong>
              </span>
              <div style={{ display: "flex", gap: "8px" }}>
                <button
                  type="button"
                  onClick={() => setShowPayModal(false)}
                  style={{
                    padding: "8px 14px",
                    borderRadius: "8px",
                    background: "var(--surface-2, rgba(255,255,255,0.05))",
                    border: "1px solid var(--border, rgba(255,255,255,0.1))",
                    color: "var(--text)",
                    fontSize: "0.85rem",
                    cursor: "pointer",
                  }}
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  disabled={paying}
                  style={{
                    padding: "8px 16px",
                    borderRadius: "8px",
                    background: "var(--accent, #10B981)",
                    color: "#fff",
                    border: "none",
                    fontWeight: 600,
                    fontSize: "0.85rem",
                    cursor: paying ? "not-allowed" : "pointer",
                    opacity: paying ? 0.7 : 1,
                  }}
                >
                  {paying ? "Registrando..." : "Confirmar Quitação"}
                </button>
              </div>
            </div>
          </form>
        )}

        {/* Pula Compra & Radar de Custos Ocultos Alert Banner */}
        {pulaCompraStats.hasPulaCompra && (
          <div
            style={{
              background: "rgba(245, 158, 11, 0.08)",
              border: "1px solid rgba(245, 158, 11, 0.3)",
              borderRadius: "14px",
              padding: "1rem 1.25rem",
              marginBottom: "1.5rem",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#F59E0B", fontWeight: 700, marginBottom: "4px" }}>
              <Zap size={18} />
              <span>Radar Pula Compra: Financiamentos e Custos Embutidos</span>
            </div>
            <p style={{ margin: "0 0 10px 0", fontSize: "0.85rem", color: "var(--muted, #94A3B8)" }}>
              Esta fatura possui lançamentos de parcelamento postergado (Pula Compra) e tributos incidentes:
            </p>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "16px", fontSize: "0.85rem" }}>
              {pulaCompraStats.financedCount > 0 && (
                <div style={{ background: "rgba(0,0,0,0.2)", padding: "6px 12px", borderRadius: "8px" }}>
                  <span className="muted" style={{ display: "block", fontSize: "0.75rem" }}>Itens Refinanciados</span>
                  <strong style={{ color: "#F59E0B" }}>{pulaCompraStats.financedCount}x ({money(pulaCompraStats.financedTotal)})</strong>
                </div>
              )}
              {pulaCompraStats.creditTotal > 0 && (
                <div style={{ background: "rgba(0,0,0,0.2)", padding: "6px 12px", borderRadius: "8px" }}>
                  <span className="muted" style={{ display: "block", fontSize: "0.75rem" }}>Créditos de Adiamento</span>
                  <strong style={{ color: "#10B981" }}>{money(pulaCompraStats.creditTotal)}</strong>
                </div>
              )}
              {pulaCompraStats.iofTotal > 0 && (
                <div style={{ background: "rgba(0,0,0,0.2)", padding: "6px 12px", borderRadius: "8px" }}>
                  <span className="muted" style={{ display: "block", fontSize: "0.75rem" }}>IOF / Encargos</span>
                  <strong style={{ color: "#EF4444" }}>{money(pulaCompraStats.iofTotal)}</strong>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Statement Items Breakdown */}
        <div style={{ marginBottom: "1.5rem" }}>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "12px",
            }}
          >
            <h3 style={{ fontSize: "1rem", margin: 0, display: "flex", alignItems: "center", gap: "8px" }}>
              <Receipt size={18} className="muted" /> Lançamentos da Fatura
            </h3>
            <span className="muted" style={{ fontSize: "0.8rem" }}>
              {items.length > 0 ? `${items.length} item(ns)` : "Total consolidado"}
            </span>
          </div>

          <div
            style={{
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border, rgba(255,255,255,0.08))",
              borderRadius: "12px",
              overflow: "hidden",
            }}
          >
            {items.length > 0 ? (
              <ul className="list" style={{ margin: 0, padding: 0 }}>
                {items.map((item, idx) => {
                  const p = Array.isArray(item.credit_card_purchases)
                    ? item.credit_card_purchases[0]
                    : item.credit_card_purchases;
                  const desc = (p?.description || "Compra no cartão").trim();
                  const upperDesc = desc.toUpperCase();

                  const isPulaFinanced =
                    upperDesc.startsWith("FIN ") ||
                    upperDesc.includes("FIN ") ||
                    (upperDesc.includes("PULA COMPRA") && !upperDesc.includes("CREDITO"));
                  const isPulaCredit =
                    upperDesc.includes("CREDITO PULA COMPRA") ||
                    upperDesc.includes("CRÉDITO PULA COMPRA");
                  const isIof = upperDesc.includes("IOF");

                  return (
                    <li
                      key={idx}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        padding: "12px 16px",
                        borderBottom:
                          idx < items.length - 1
                            ? "1px solid var(--border, rgba(255,255,255,0.05))"
                            : "none",
                      }}
                    >
                      <div>
                        <div style={{ display: "flex", alignItems: "center", flexWrap: "wrap", gap: "6px" }}>
                          <strong style={{ fontSize: "0.9rem" }}>{desc}</strong>
                          {isPulaFinanced && (
                            <span
                              style={{
                                display: "inline-flex",
                                alignItems: "center",
                                gap: "3px",
                                background: "rgba(245, 158, 11, 0.18)",
                                color: "#F59E0B",
                                padding: "2px 6px",
                                borderRadius: "6px",
                                fontSize: "0.7rem",
                                fontWeight: 700,
                              }}
                            >
                              <Zap size={11} /> Pula Compra (Financiado)
                            </span>
                          )}
                          {isPulaCredit && (
                            <span
                              style={{
                                display: "inline-flex",
                                alignItems: "center",
                                gap: "3px",
                                background: "rgba(16, 185, 129, 0.18)",
                                color: "#10B981",
                                padding: "2px 6px",
                                borderRadius: "6px",
                                fontSize: "0.7rem",
                                fontWeight: 700,
                              }}
                            >
                              🔄 Compra Adiada
                            </span>
                          )}
                          {isIof && (
                            <span
                              style={{
                                display: "inline-flex",
                                alignItems: "center",
                                gap: "3px",
                                background: "rgba(239, 68, 68, 0.18)",
                                color: "#EF4444",
                                padding: "2px 6px",
                                borderRadius: "6px",
                                fontSize: "0.7rem",
                                fontWeight: 700,
                              }}
                            >
                              🏛️ Encargos / IOF
                            </span>
                          )}
                        </div>
                        <span className="muted" style={{ fontSize: "0.75rem" }}>
                          Parcela {item.installment_number} de {p?.installment_count || 1}
                        </span>
                      </div>
                      <b style={{ fontSize: "0.95rem", color: isPulaCredit ? "#10B981" : undefined }}>
                        {isPulaCredit ? `- ${money(Math.abs(item.amount))}` : money(item.amount)}
                      </b>
                    </li>
                  );
                })}
              </ul>
            ) : (
              <div
                style={{
                  padding: "1.25rem 1rem",
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                }}
              >
                <div>
                  <strong style={{ fontSize: "0.95rem", display: "block" }}>
                    Total Consolidado da Fatura
                  </strong>
                  <span className="muted" style={{ fontSize: "0.8rem" }}>
                    Fatura importada com saldo consolidado
                  </span>
                </div>
                <b style={{ fontSize: "1.1rem" }}>{money(totalAmount)}</b>
              </div>
            )}
          </div>
        </div>

        {/* Card Limits Summary Footer */}
        {card && (
          <div
            style={{
              background: "var(--surface-2, rgba(255,255,255,0.02))",
              border: "1px solid var(--border, rgba(255,255,255,0.06))",
              borderRadius: "12px",
              padding: "12px 16px",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "12px",
              marginBottom: "1.5rem",
              fontSize: "0.85rem",
            }}
          >
            <div>
              <span className="muted">Limite Total: </span>
              <strong>{money(card.credit_limit)}</strong>
            </div>
            <div>
              <span className="muted">Fechamento Mensal: </span>
              <strong>Dia {card.closing_day}</strong>
            </div>
            <div>
              <span className="muted">Vencimento Mensal: </span>
              <strong>Dia {card.due_day}</strong>
            </div>
          </div>
        )}

        {/* Footer Actions */}
        <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px" }}>
          {!isPaid && !showPayModal && (
            <button
              type="button"
              onClick={() => setShowPayModal(true)}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                padding: "10px 18px",
                borderRadius: "10px",
                background: "var(--accent, #10B981)",
                color: "#fff",
                border: "none",
                fontWeight: 600,
                fontSize: "0.9rem",
                cursor: "pointer",
              }}
            >
              <CreditCardIcon size={16} />
              Pagar Fatura
            </button>
          )}
          <button
            type="button"
            onClick={onClose}
            style={{
              padding: "10px 20px",
              borderRadius: "10px",
              background: "var(--surface-2, rgba(255,255,255,0.1))",
              color: "var(--text, #F8FAFC)",
              border: "1px solid var(--border, rgba(255,255,255,0.15))",
              fontWeight: 600,
              fontSize: "0.9rem",
              cursor: "pointer",
            }}
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  );
}
