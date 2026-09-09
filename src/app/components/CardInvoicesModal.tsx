"use client";

import React, { useState, useMemo, useEffect } from "react";
import {
  X,
  FileText,
  PlusCircle,
  UploadCloud,
  CheckCircle2,
  Clock,
} from "lucide-react";
import { BrandLogo } from "../brand-logo";
import { money, dateFmt } from "./Money";
import { Card, Category, Invoice, StatementImport, Transaction } from "./types";
import { calculateCardLimitUsage } from "@/lib/finance/card";
import { createClient } from "@/lib/supabase/client";

interface CardInvoicesModalProps {
  card: Card;
  allInvoices: Invoice[];
  categories: Category[];
  workspaceId: string;
  transactions?: Transaction[];
  onClose: () => void;
  onReload: () => Promise<void>;
  onOpenMirrorInvoice: (invoice: Invoice) => void;
  statementImports?: StatementImport[];
  submitStatementImport?: (form: FormData) => Promise<void>;
  importingStatement?: boolean;
  statementImportFeedback?: string;
  statementImportFailed?: boolean;
  statementImportDescribedBy?: string;
}

export function CardInvoicesModal({
  card,
  allInvoices,
  categories,
  workspaceId,
  transactions = [],
  onClose,
  onReload,
  onOpenMirrorInvoice,
  statementImports = [],
  submitStatementImport,
  importingStatement = false,
  statementImportFeedback = "",
  statementImportFailed = false,
  statementImportDescribedBy = "statement-import-help",
}: CardInvoicesModalProps) {
  const [activeTab, setActiveTab] = useState<"invoices" | "new-purchase" | "import">("invoices");
  const [statusFilter, setStatusFilter] = useState<"all" | "open" | "paid">("all");
  const [purchaseSubmitting, setPurchaseSubmitting] = useState(false);
  const [purchaseMessage, setPurchaseMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

  const supabase = useMemo(() => createClient(), []);
  const currentMonthRef = useMemo(() => new Date().toISOString().slice(0, 7), []);

  // FILTRAGEM ESTRITA: Garante que apenas as faturas DESTE cartão sejam consideradas
  const cardInvoices = useMemo(() => {
    return allInvoices
      .filter((inv) => inv.credit_card_id === card.id || inv.account_id === card.account_id)
      .sort((a, b) => (b.due_date || "").localeCompare(a.due_date || ""));
  }, [allInvoices, card]);

  const cardTransactions = useMemo(() => {
    return transactions.filter((t) => t.account_id === card.account_id);
  }, [transactions, card.account_id]);

  // Cálculo real do limite
  const limitUsage = useMemo(() => {
    return calculateCardLimitUsage(
      Number(card.credit_limit || 0),
      cardInvoices,
      cardTransactions,
      currentMonthRef
    );
  }, [card.credit_limit, cardInvoices, cardTransactions, currentMonthRef]);

  // Faturas filtradas por status
  const filteredInvoices = useMemo(() => {
    if (statusFilter === "open") return cardInvoices.filter((i) => i.status !== "paid");
    if (statusFilter === "paid") return cardInvoices.filter((i) => i.status === "paid");
    return cardInvoices;
  }, [cardInvoices, statusFilter]);

  // Fechamento com tecla Escape
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [onClose]);

  const invoiceTotal = (inv: Invoice) => {
    const installmentsSum = (inv.credit_card_installments || []).reduce(
      (s, i) => s + Number(i.amount || 0),
      0
    );
    if (installmentsSum > 0) return installmentsSum;
    return Number(inv.total_amount || 0);
  };

  const openCount = cardInvoices.filter((i) => i.status !== "paid").length;
  const paidCount = cardInvoices.filter((i) => i.status === "paid").length;

  // Registrar nova compra
  async function handlePurchaseSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setPurchaseSubmitting(true);
    setPurchaseMessage(null);

    const form = new FormData(e.currentTarget);
    const description = String(form.get("description") || "").trim();
    const totalAmount = parseFloat(String(form.get("total_amount") || "0").replace(/\./g, "").replace(",", "."));
    const purchasedOn = String(form.get("purchased_on") || new Date().toISOString().slice(0, 10));
    const installmentCount = Math.max(1, parseInt(String(form.get("installment_count") || "1"), 10) || 1);
    const categoryId = form.get("category_id") ? String(form.get("category_id")) : null;
    const notes = form.get("notes") ? String(form.get("notes")) : null;

    if (!description || totalAmount <= 0) {
      setPurchaseMessage({ type: "error", text: "Preencha a descrição e um valor válido." });
      setPurchaseSubmitting(false);
      return;
    }

    try {
      const res = await fetch("/api/cards/purchase", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspaceId,
          credit_card_id: card.id,
          description,
          total_amount: totalAmount,
          purchased_on: purchasedOn,
          installment_count: installmentCount,
          category_id: categoryId,
          notes,
        }),
      });
      const data = await res.json().catch(() => ({}));
      if (res.ok && data.success) {
        setPurchaseMessage({
          type: "success",
          text: `Compra registrada com sucesso! ${installmentCount > 1 ? `${installmentCount} parcelas geradas nas faturas.` : "Lançamento adicionado."}`,
        });
        (e.target as HTMLFormElement).reset();
        await onReload();
        setActiveTab("invoices");
        return;
      }
    } catch {
      // fallback to Supabase RPC
    }

    const { error } = await supabase.rpc("create_installment_purchase", {
      p_credit_card_id: card.id,
      p_description: description,
      p_total_amount: totalAmount,
      p_purchased_on: purchasedOn,
      p_installment_count: installmentCount,
      p_category_id: categoryId,
      p_notes: notes,
      p_idempotency_key: crypto.randomUUID(),
    });

    if (error) {
      setPurchaseMessage({ type: "error", text: "Não foi possível registrar a compra." });
    } else {
      setPurchaseMessage({
        type: "success",
        text: `Compra registrada com sucesso! ${installmentCount > 1 ? `${installmentCount} parcelas geradas nas faturas.` : "Lançamento adicionado."}`,
      });
      (e.target as HTMLFormElement).reset();
      await onReload();
      setActiveTab("invoices");
    }
    setPurchaseSubmitting(false);
  }

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="card-invoices-modal-title"
      style={{
        position: "fixed",
        inset: 0,
        backgroundColor: "rgba(0, 0, 0, 0.78)",
        backdropFilter: "blur(6px)",
        zIndex: 9998,
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
          maxWidth: "980px",
          maxHeight: "90vh",
          display: "flex",
          flexDirection: "column",
          background: "var(--surface, #11151F)",
          border: "1px solid var(--border, rgba(255,255,255,0.12))",
          borderRadius: "20px",
          boxShadow: "0 24px 60px rgba(0,0,0,0.65)",
          color: "var(--text, #F8FAFC)",
          padding: 0,
          overflow: "hidden",
        }}
      >
        {/* Header do Cartão Retangular */}
        <div
          style={{
            padding: "1.5rem 1.75rem",
            background: "linear-gradient(135deg, rgba(139,92,246,0.15) 0%, rgba(30,41,59,0.5) 100%)",
            borderBottom: "1px solid var(--border, rgba(255,255,255,0.1))",
          }}
        >
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: "1rem" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "14px" }}>
              <span className="brand-badge" style={{ padding: "8px", borderRadius: "12px", background: "rgba(255,255,255,0.06)" }}>
                <BrandLogo brand={card.brand} />
              </span>
              <div>
                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <h2 id="card-invoices-modal-title" style={{ margin: 0, fontSize: "1.35rem", fontWeight: 700 }}>
                    {card.name}
                  </h2>
                  {card.last_four && (
                    <span
                      style={{
                        background: "rgba(255,255,255,0.08)",
                        padding: "2px 8px",
                        borderRadius: "6px",
                        fontSize: "0.8rem",
                        color: "var(--muted, #94A3B8)",
                        fontWeight: 600,
                      }}
                    >
                      •••• {card.last_four}
                    </span>
                  )}
                </div>
                <span className="muted" style={{ fontSize: "0.85rem" }}>
                  Fechamento todo dia {card.closing_day || 15} · Vencimento todo dia {card.due_day || 22}
                </span>
              </div>
            </div>

            <button
              type="button"
              onClick={onClose}
              aria-label="Fechar"
              style={{
                background: "rgba(255,255,255,0.06)",
                border: "1px solid rgba(255,255,255,0.1)",
                color: "var(--muted, #94A3B8)",
                padding: "8px",
                borderRadius: "10px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
                transition: "all 0.2s",
              }}
            >
              <X size={20} />
            </button>
          </div>

          {/* Grid Retangular de Métricas do Limite */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
              gap: "10px",
              marginTop: "1.25rem",
            }}
          >
            <div style={{ background: "rgba(255,255,255,0.04)", padding: "10px 14px", borderRadius: "12px", border: "1px solid rgba(255,255,255,0.06)" }}>
              <span className="muted" style={{ fontSize: "0.75rem", display: "block" }}>Limite Total</span>
              <strong style={{ fontSize: "1.1rem" }}>{money(card.credit_limit)}</strong>
            </div>

            <div style={{ background: "rgba(239,68,68,0.08)", padding: "10px 14px", borderRadius: "12px", border: "1px solid rgba(239,68,68,0.15)" }}>
              <span className="muted" style={{ fontSize: "0.75rem", display: "block", color: "#FCA5A5" }}>Total Comprometido</span>
              <strong style={{ fontSize: "1.1rem", color: "#EF4444" }}>{money(limitUsage.totalUsedLimit)}</strong>
            </div>

            <div style={{ background: "rgba(34,197,94,0.08)", padding: "10px 14px", borderRadius: "12px", border: "1px solid rgba(34,197,94,0.15)" }}>
              <span className="muted" style={{ fontSize: "0.75rem", display: "block", color: "#86EFAC" }}>Disponível</span>
              <strong style={{ fontSize: "1.1rem", color: "#22C55E" }}>{money(limitUsage.availableLimit)}</strong>
            </div>

            {limitUsage.futureInstallmentsCommitted > 0 && (
              <div style={{ background: "rgba(245,158,11,0.08)", padding: "10px 14px", borderRadius: "12px", border: "1px solid rgba(245,158,11,0.15)" }}>
                <span className="muted" style={{ fontSize: "0.75rem", display: "block", color: "#FCD34D" }}>Parcelas a Vencer</span>
                <strong style={{ fontSize: "1.1rem", color: "#F59E0B" }}>{money(limitUsage.futureInstallmentsCommitted)}</strong>
              </div>
            )}
          </div>

          {/* Barra de Progresso do Limite */}
          <div style={{ marginTop: "12px" }}>
            <div
              className={`progress-bar${limitUsage.utilizationPercent >= 90 ? " progress-bar--danger" : limitUsage.utilizationPercent >= 70 ? " progress-bar--warning" : ""}`}
              style={{ height: "6px" }}
            >
              <span style={{ width: `${limitUsage.utilizationPercent}%` }} />
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", marginTop: "4px", fontSize: "0.75rem", color: "var(--muted, #94A3B8)" }}>
              <span>{limitUsage.utilizationPercent}% do limite utilizado</span>
              <span>{cardInvoices.length} faturas registradas</span>
            </div>
          </div>
        </div>

        {/* Barra de Abas de Navegação */}
        <div
          style={{
            display: "flex",
            gap: "8px",
            padding: "0.75rem 1.75rem",
            background: "var(--surface-2, rgba(255,255,255,0.02))",
            borderBottom: "1px solid var(--border, rgba(255,255,255,0.08))",
          }}
        >
          <button
            type="button"
            onClick={() => setActiveTab("invoices")}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "6px",
              padding: "8px 16px",
              borderRadius: "10px",
              fontSize: "0.9rem",
              fontWeight: 600,
              border: "none",
              cursor: "pointer",
              background: activeTab === "invoices" ? "var(--primary, #8B5CF6)" : "transparent",
              color: activeTab === "invoices" ? "#fff" : "var(--muted, #94A3B8)",
              transition: "all 0.2s",
            }}
          >
            <FileText size={16} />
            Faturas ({cardInvoices.length})
          </button>

          <button
            type="button"
            onClick={() => setActiveTab("new-purchase")}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "6px",
              padding: "8px 16px",
              borderRadius: "10px",
              fontSize: "0.9rem",
              fontWeight: 600,
              border: "none",
              cursor: "pointer",
              background: activeTab === "new-purchase" ? "var(--primary, #8B5CF6)" : "transparent",
              color: activeTab === "new-purchase" ? "#fff" : "var(--muted, #94A3B8)",
              transition: "all 0.2s",
            }}
          >
            <PlusCircle size={16} />
            Nova Compra Parcelada
          </button>

          {submitStatementImport && (
            <button
              type="button"
              onClick={() => setActiveTab("import")}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                padding: "8px 16px",
                borderRadius: "10px",
                fontSize: "0.9rem",
                fontWeight: 600,
                border: "none",
                cursor: "pointer",
                background: activeTab === "import" ? "var(--primary, #8B5CF6)" : "transparent",
                color: activeTab === "import" ? "#fff" : "var(--muted, #94A3B8)",
                transition: "all 0.2s",
              }}
            >
              <UploadCloud size={16} />
              Importar Fatura
            </button>
          )}
        </div>

        {/* Conteúdo com Scroll */}
        <div style={{ flex: 1, overflowY: "auto", padding: "1.5rem 1.75rem" }}>
          {/* ABA 1: LISTA DE FATURAS EXCLUSIVAS DESTE CARTÃO */}
          <div style={{ display: activeTab === "invoices" ? "block" : "none" }}>
            <div>
              {/* Filtros de Status */}
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "1.25rem", flexWrap: "wrap", gap: "8px" }}>
                <div style={{ display: "flex", gap: "6px" }}>
                  <button
                    type="button"
                    onClick={() => setStatusFilter("all")}
                    style={{
                      padding: "4px 12px",
                      borderRadius: "8px",
                      fontSize: "0.8rem",
                      fontWeight: 600,
                      cursor: "pointer",
                      border: "1px solid var(--border, rgba(255,255,255,0.1))",
                      background: statusFilter === "all" ? "rgba(255,255,255,0.15)" : "transparent",
                      color: statusFilter === "all" ? "#fff" : "var(--muted, #94A3B8)",
                    }}
                  >
                    Todas ({cardInvoices.length})
                  </button>
                  <button
                    type="button"
                    onClick={() => setStatusFilter("open")}
                    style={{
                      padding: "4px 12px",
                      borderRadius: "8px",
                      fontSize: "0.8rem",
                      fontWeight: 600,
                      cursor: "pointer",
                      border: "1px solid rgba(245,158,11,0.2)",
                      background: statusFilter === "open" ? "rgba(245,158,11,0.2)" : "transparent",
                      color: statusFilter === "open" ? "#F59E0B" : "var(--muted, #94A3B8)",
                    }}
                  >
                    Em aberto ({openCount})
                  </button>
                  <button
                    type="button"
                    onClick={() => setStatusFilter("paid")}
                    style={{
                      padding: "4px 12px",
                      borderRadius: "8px",
                      fontSize: "0.8rem",
                      fontWeight: 600,
                      cursor: "pointer",
                      border: "1px solid rgba(34,197,94,0.2)",
                      background: statusFilter === "paid" ? "rgba(34,197,94,0.2)" : "transparent",
                      color: statusFilter === "paid" ? "#22C55E" : "var(--muted, #94A3B8)",
                    }}
                  >
                    Pagas ({paidCount})
                  </button>
                </div>
              </div>

              {filteredInvoices.length === 0 ? (
                <div style={{ textAlign: "center", padding: "3rem 1rem", color: "var(--muted, #94A3B8)" }}>
                  <FileText size={36} style={{ margin: "0 auto 12px", opacity: 0.4 }} />
                  <p style={{ margin: 0, fontWeight: 500 }}>Nenhuma fatura encontrada para este filtro.</p>
                </div>
              ) : (
                <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
                  {filteredInvoices.map((inv) => {
                    const total = invoiceTotal(inv);
                    const isPaid = inv.status === "paid";
                    const itemsCount = inv.credit_card_installments?.length || 0;

                    return (
                      <div
                        key={inv.id}
                        style={{
                          display: "flex",
                          justifyContent: "space-between",
                          alignItems: "center",
                          padding: "14px 18px",
                          borderRadius: "14px",
                          background: isPaid ? "rgba(255,255,255,0.02)" : "rgba(245,158,11,0.04)",
                          border: isPaid ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(245,158,11,0.2)",
                          transition: "all 0.2s",
                        }}
                      >
                        <div style={{ flex: 1, minWidth: 0 }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "10px", flexWrap: "wrap", marginBottom: "4px" }}>
                            <strong style={{ fontSize: "1rem" }}>
                              Vence {dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}
                            </strong>
                            <span
                              style={{
                                display: "inline-flex",
                                alignItems: "center",
                                gap: "4px",
                                padding: "2px 8px",
                                borderRadius: "6px",
                                fontSize: "0.75rem",
                                fontWeight: 700,
                                background: isPaid ? "rgba(34,197,94,0.15)" : "rgba(245,158,11,0.15)",
                                color: isPaid ? "#22C55E" : "#F59E0B",
                              }}
                            >
                              {isPaid ? <CheckCircle2 size={12} /> : <Clock size={12} />}
                              {isPaid ? "Paga" : "Em aberto"}
                            </span>
                          </div>

                          <div style={{ display: "flex", gap: "14px", fontSize: "0.8rem", color: "var(--muted, #94A3B8)" }}>
                            {inv.closing_date && (
                              <span>Fechamento: {dateFmt.format(new Date(`${inv.closing_date}T12:00:00`))}</span>
                            )}
                            {itemsCount > 0 && <span>· {itemsCount} lançamento(s)</span>}
                            {inv.paid_at && <span>· Paga em {dateFmt.format(new Date(`${inv.paid_at}T12:00:00`))}</span>}
                          </div>
                        </div>

                        <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
                          <div style={{ textAlign: "right" }}>
                            <strong style={{ fontSize: "1.15rem", display: "block", color: isPaid ? "inherit" : "#EF4444" }}>
                              {money(total)}
                            </strong>
                          </div>

                          <button
                            type="button"
                            className="button-secondary ui-button--sm"
                            onClick={() => onOpenMirrorInvoice(inv)}
                            style={{
                              display: "inline-flex",
                              alignItems: "center",
                              gap: "6px",
                              padding: "7px 14px",
                              borderRadius: "8px",
                              fontSize: "0.85rem",
                              fontWeight: 600,
                            }}
                          >
                            <FileText size={14} />
                            Espelho
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>

          {/* ABA 2: NOVA COMPRA PARCELADA */}
          <div style={{ display: activeTab === "new-purchase" ? "block" : "none" }}>
            <div style={{ maxWidth: "600px", margin: "0 auto" }}>
              <h3 style={{ fontSize: "1.15rem", marginBottom: "0.5rem" }}>
                Registrar compra no {card.name}
              </h3>
              <p className="muted" style={{ fontSize: "0.85rem", marginBottom: "1.5rem" }}>
                Ao registrar com parcelamento, as parcelas serão distribuídas mês a mês nas faturas seguintes automaticamente.
              </p>

              {purchaseMessage && (
                <div
                  role="status"
                  style={{
                    padding: "10px 14px",
                    borderRadius: "8px",
                    marginBottom: "1.25rem",
                    fontSize: "0.9rem",
                    background: purchaseMessage.type === "success" ? "rgba(34,197,94,0.15)" : "rgba(239,68,68,0.15)",
                    border: `1px solid ${purchaseMessage.type === "success" ? "rgba(34,197,94,0.3)" : "rgba(239,68,68,0.3)"}`,
                    color: purchaseMessage.type === "success" ? "#22C55E" : "#EF4444",
                  }}
                >
                  {purchaseMessage.text}
                </div>
              )}

              <form onSubmit={handlePurchaseSubmit} className="simple-form" style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
                <div>
                  <label htmlFor="modal-purchase-description" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                    Descrição da compra
                  </label>
                  <input
                    id="modal-purchase-description"
                    name="description"
                    placeholder="Ex: Supermercado, Passagem aérea, Notebook"
                    required
                    style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                  />
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
                  <div>
                    <label htmlFor="modal-purchase-total" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                      Valor total (R$)
                    </label>
                    <input
                      id="modal-purchase-total"
                      name="total_amount"
                      placeholder="0,00"
                      required
                      style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                    />
                  </div>

                  <div>
                    <label htmlFor="modal-purchase-installments" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                      Parcelas
                    </label>
                    <input
                      id="modal-purchase-installments"
                      name="installment_count"
                      type="number"
                      min="1"
                      max="120"
                      defaultValue="1"
                      required
                      style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                    />
                  </div>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
                  <div>
                    <label htmlFor="modal-purchase-date" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                      Data da compra
                    </label>
                    <input
                      id="modal-purchase-date"
                      name="purchased_on"
                      type="date"
                      defaultValue={new Date().toISOString().slice(0, 10)}
                      required
                      style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                    />
                  </div>

                  <div>
                    <label htmlFor="modal-purchase-category" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                      Categoria
                    </label>
                    <select
                      id="modal-purchase-category"
                      name="category_id"
                      style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                    >
                      <option value="">Sem categoria</option>
                      {categories
                        .filter((c) => c.kind === "expense")
                        .map((c) => (
                          <option key={c.id} value={c.id}>
                            {c.name}
                          </option>
                        ))}
                    </select>
                  </div>
                </div>

                <div>
                  <label htmlFor="modal-purchase-notes" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                    Observações (opcional)
                  </label>
                  <input
                    id="modal-purchase-notes"
                    name="notes"
                    placeholder="Ex: Compra parcelada em 10x sem juros"
                    style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                  />
                </div>

                <button
                  type="submit"
                  disabled={purchaseSubmitting}
                  className="button-primary"
                  style={{
                    padding: "12px",
                    borderRadius: "10px",
                    fontWeight: 700,
                    marginTop: "0.5rem",
                    cursor: "pointer",
                  }}
                >
                  {purchaseSubmitting ? "Registrando..." : "Confirmar Compra"}
                </button>
              </form>
            </div>
          </div>

          {/* ABA 3: IMPORTAR FATURA */}
          <div style={{ display: activeTab === "import" && submitStatementImport ? "block" : "none" }}>
            <div style={{ maxWidth: "600px", margin: "0 auto" }}>
              <h3 style={{ fontSize: "1.15rem", marginBottom: "0.5rem" }}>
                Importar fatura para {card.name}
              </h3>
              <p className="muted" style={{ fontSize: "0.85rem", marginBottom: "1.5rem" }}>
                Envie o arquivo de extrato ou fatura para processamento direto neste cartão.
              </p>

              <form
                className="simple-form"
                aria-busy={importingStatement}
                onSubmit={(event) => {
                  event.preventDefault();
                  if (submitStatementImport) {
                    void submitStatementImport(new FormData(event.currentTarget));
                  }
                }}
              >
                <label htmlFor="statement-file" style={{ display: "block", fontSize: "0.85rem", marginBottom: "4px" }}>
                  Arquivo de fatura
                </label>
                <input
                  id="statement-file"
                  name="statement"
                  type="file"
                  accept="application/pdf,text/plain,.txt,.bsf-fixture"
                  required
                  disabled={importingStatement}
                  aria-invalid={statementImportFailed || undefined}
                  aria-describedby={statementImportDescribedBy}
                  style={{ width: "100%", padding: "10px 12px", borderRadius: "10px" }}
                />
                <small id="statement-import-help" className="muted" style={{ display: "block", margin: "6px 0 12px" }}>
                  Até 5 MB. Formatos suportados: PDF ou fixture de fatura.
                </small>

                <button
                  type="submit"
                  disabled={importingStatement}
                  className="button-primary"
                  style={{ padding: "12px", borderRadius: "10px", fontWeight: 700, cursor: "pointer" }}
                >
                  {importingStatement ? "Processando arquivo..." : "Enviar para importação"}
                </button>

                {statementImportFeedback && (
                  <p
                    id="statement-import-feedback"
                    className={statementImportFailed ? "form-error" : "form-success"}
                    role={statementImportFailed ? "alert" : "status"}
                    style={{ marginTop: "1rem" }}
                  >
                    {statementImportFeedback}
                  </p>
                )}
              </form>

              {statementImports.length > 0 && (
                <div style={{ marginTop: "2rem" }}>
                  <h4 style={{ fontSize: "0.95rem", marginBottom: "0.5rem" }}>Importações Recentes</h4>
                  <ul className="list" aria-label="Importações recentes">
                    {statementImports.map((item) => (
                      <li key={item.id} style={{ display: "flex", justifyContent: "space-between", padding: "8px 12px" }}>
                        <span>{item.file_name}</span>
                        <strong data-status={item.status}>
                          {item.status === "failed" ? "Falhou" : item.status}
                        </strong>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
