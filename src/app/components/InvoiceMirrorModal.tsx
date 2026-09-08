"use client";

import { useMemo, useState } from "react";
import {
  CheckCircle2,
  Clock,
  FileText,
  Printer,
  Receipt,
  X,
} from "lucide-react";
import { BrandLogo } from "../brand-logo";
import { Card, Invoice } from "./types";
import { money, dateFmt } from "./Money";

type InvoiceMirrorModalProps = {
  card?: Card | null;
  invoice: Invoice;
  allInvoices?: Invoice[];
  onClose: () => void;
  onSelectInvoice?: (invoice: Invoice) => void;
};

export function InvoiceMirrorModal({
  card,
  invoice: initialInvoice,
  allInvoices = [],
  onClose,
  onSelectInvoice,
}: InvoiceMirrorModalProps) {
  const [selectedInvoiceId, setSelectedInvoiceId] = useState(initialInvoice.id);

  const activeInvoice = useMemo(() => {
    return allInvoices.find((inv) => inv.id === selectedInvoiceId) || initialInvoice;
  }, [allInvoices, selectedInvoiceId, initialInvoice]);

  const items = activeInvoice.credit_card_installments || [];
  const installmentsTotal = items.reduce((s, i) => s + Number(i.amount), 0);
  const totalAmount = installmentsTotal > 0 ? installmentsTotal : Number(activeInvoice.total_amount || 0);

  const isPaid = activeInvoice.status === "paid";

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
              }}
            >
              <X size={22} />
            </button>
          </div>
        </div>

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
                  (inv.credit_card_installments && inv.credit_card_installments.length > 0)
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

            <div>
              {isPaid ? (
                <span
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "6px",
                    padding: "4px 10px",
                    borderRadius: "20px",
                    background: "rgba(34,197,94,0.15)",
                    color: "#22C55E",
                    fontSize: "0.8rem",
                    fontWeight: 700,
                    border: "1px solid rgba(34,197,94,0.3)",
                  }}
                >
                  <CheckCircle2 size={14} /> Fatura Paga
                </span>
              ) : (
                <span
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "6px",
                    padding: "4px 10px",
                    borderRadius: "20px",
                    background: "rgba(245,158,11,0.15)",
                    color: "#F59E0B",
                    fontSize: "0.8rem",
                    fontWeight: 700,
                    border: "1px solid rgba(245,158,11,0.3)",
                  }}
                >
                  <Clock size={14} /> Fatura em Aberto
                </span>
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

            {isPaid && activeInvoice.paid_at && (
              <div>
                <span className="muted" style={{ fontSize: "0.75rem", display: "block" }}>
                  Pago em
                </span>
                <strong style={{ fontSize: "0.95rem", color: "#22C55E" }}>
                  {dateFmt.format(new Date(`${activeInvoice.paid_at}T12:00:00`))}
                </strong>
              </div>
            )}
          </div>
        </div>

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
                        <strong style={{ fontSize: "0.9rem", display: "block" }}>
                          {p?.description || "Compra no cartão"}
                        </strong>
                        <span className="muted" style={{ fontSize: "0.75rem" }}>
                          Parcela {item.installment_number} de {p?.installment_count || 1}
                        </span>
                      </div>
                      <b style={{ fontSize: "0.95rem" }}>{money(item.amount)}</b>
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

        {/* Close Button */}
        <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px" }}>
          <button
            type="button"
            onClick={onClose}
            style={{
              padding: "10px 20px",
              borderRadius: "10px",
              background: "var(--primary, #8B5CF6)",
              color: "#fff",
              border: "none",
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
