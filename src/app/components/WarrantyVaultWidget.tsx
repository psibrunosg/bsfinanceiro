"use client";

import { useState } from "react";
import { AlertCircle, CheckCircle2, Clock, Plus, ShieldCheck } from "lucide-react";
import { money } from "./Money";
import {
  calculateWarrantyStatus,
  computeWarrantySummary,
  type WarrantyItem,
} from "@/lib/finance/warranty-vault";

type WarrantyVaultWidgetProps = {
  initialItems?: WarrantyItem[];
  referenceDate?: string;
};

const DEFAULT_SAMPLE_ITEMS: WarrantyItem[] = [
  {
    id: "w-1",
    name: "iPhone 15 Pro",
    purchaseDate: "2025-09-10",
    warrantyMonths: 12,
    invoiceNumber: "NF-00129",
    value: 7500,
    category: "Eletrônicos",
  },
  {
    id: "w-2",
    name: "Geladeira Brastemp",
    purchaseDate: "2026-01-01",
    warrantyMonths: 24,
    invoiceNumber: "NF-99882",
    value: 4200,
    category: "Eletrodomésticos",
  },
];

export function WarrantyVaultWidget({
  initialItems = DEFAULT_SAMPLE_ITEMS,
  referenceDate,
}: WarrantyVaultWidgetProps) {
  const [items, setItems] = useState<WarrantyItem[]>(initialItems);
  const [showAddForm, setShowAddForm] = useState(false);

  const [newName, setNewName] = useState("");
  const [newValue, setNewValue] = useState("");
  const [newMonths, setNewMonths] = useState("12");
  const [newPurchaseDate, setNewPurchaseDate] = useState("2026-08-01");
  const [newInvoiceNumber, setNewInvoiceNumber] = useState("");
  const [newCategory, setNewCategory] = useState("Eletrônicos");

  const summary = computeWarrantySummary(items, referenceDate);

  const handleAddItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName.trim()) return;

    const newItem: WarrantyItem = {
      id: `w-${Date.now()}`,
      name: newName.trim(),
      value: Number(newValue) || 0,
      warrantyMonths: Number(newMonths) || 12,
      purchaseDate: newPurchaseDate || "2026-08-01",
      invoiceNumber: newInvoiceNumber.trim() || undefined,
      category: newCategory,
    };

    setItems((prev) => [newItem, ...prev]);
    setNewName("");
    setNewValue("");
    setNewInvoiceNumber("");
    setShowAddForm(false);
  };

  return (
    <section
      className="dashboard-card"
      aria-label="Cofre de Garantias e Notas Fiscais"
      style={{
        padding: "1.5rem",
        borderRadius: "16px",
        background: "var(--surface)",
        border: "1px solid var(--border)",
        boxShadow: "0 4px 20px rgba(0, 0, 0, 0.15)",
        marginBottom: "1.5rem",
      }}
    >
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "1.25rem",
          flexWrap: "wrap",
          gap: "10px",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
          <span
            style={{
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              width: "36px",
              height: "36px",
              borderRadius: "10px",
              background: "rgba(59, 130, 246, 0.15)",
              color: "var(--accent, #3b82f6)",
            }}
          >
            <ShieldCheck size={20} />
          </span>
          <div>
            <h2 style={{ fontSize: "1.1rem", fontWeight: 700, margin: 0, color: "var(--text)" }}>
              Cofre de Garantias & Notas Fiscais
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Proteja seus bens de alto valor e acompanhe o vencimento da garantia legal/estendida.
            </p>
          </div>
        </div>

        <button
          type="button"
          onClick={() => setShowAddForm((s) => !s)}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
            background: "rgba(59, 130, 246, 0.12)",
            color: "var(--accent, #3b82f6)",
            border: "1px solid rgba(59, 130, 246, 0.3)",
            borderRadius: "8px",
            padding: "6px 12px",
            fontSize: "0.8rem",
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          <Plus size={14} />
          Cadastrar Garantia
        </button>
      </header>

      {/* Summary KPI Cards */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))",
          gap: "12px",
          marginBottom: "1.25rem",
        }}
      >
        <div
          style={{
            padding: "10px 14px",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Valor Sob Garantia</span>
          <div style={{ fontSize: "1.25rem", fontWeight: 700, color: "var(--text)", marginTop: "2px" }}>
            {money(summary.totalProtectedValue)}
          </div>
        </div>

        <div
          style={{
            padding: "10px 14px",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Garantias Ativas</span>
          <div style={{ fontSize: "1.25rem", fontWeight: 700, color: "var(--positive, #22c55e)", marginTop: "2px" }}>
            {summary.activeCount}
          </div>
        </div>

        <div
          style={{
            padding: "10px 14px",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Vencendo em 30d</span>
          <div style={{ fontSize: "1.25rem", fontWeight: 700, color: summary.expiringSoonCount > 0 ? "var(--warning, #f59e0b)" : "var(--muted)", marginTop: "2px" }}>
            {summary.expiringSoonCount}
          </div>
        </div>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <form
          onSubmit={handleAddItem}
          style={{
            padding: "14px",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.04))",
            border: "1px solid var(--border)",
            marginBottom: "1.25rem",
            display: "grid",
            gap: "10px",
            gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
          }}
        >
          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Item
            </label>
            <input
              type="text"
              placeholder="Nome do item (ex: iPhone 15, TV...)"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              required
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Valor (R$)
            </label>
            <input
              type="number"
              step="0.01"
              placeholder="Valor em R$"
              value={newValue}
              onChange={(e) => setNewValue(e.target.value)}
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Garantia (Meses)
            </label>
            <input
              type="number"
              placeholder="Meses de garantia"
              value={newMonths}
              onChange={(e) => setNewMonths(e.target.value)}
              required
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label htmlFor="purchase-date-input" style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Data da compra
            </label>
            <input
              id="purchase-date-input"
              type="date"
              aria-label="Data da compra"
              value={newPurchaseDate}
              onChange={(e) => setNewPurchaseDate(e.target.value)}
              required
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Nota Fiscal (Opcional)
            </label>
            <input
              type="text"
              placeholder="Número / Chave da NF"
              value={newInvoiceNumber}
              onChange={(e) => setNewInvoiceNumber(e.target.value)}
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Categoria
            </label>
            <select
              value={newCategory}
              onChange={(e) => setNewCategory(e.target.value)}
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            >
              <option value="Eletrônicos">Eletrônicos</option>
              <option value="Eletrodomésticos">Eletrodomésticos</option>
              <option value="Informática">Informática</option>
              <option value="Acessórios">Acessórios</option>
              <option value="Outros">Outros</option>
            </select>
          </div>

          <div style={{ display: "flex", alignItems: "flex-end", gap: "8px" }}>
            <button
              type="submit"
              style={{
                flex: 1,
                padding: "9px 14px",
                borderRadius: "8px",
                background: "var(--accent, #3b82f6)",
                color: "#ffffff",
                border: "none",
                fontWeight: 600,
                fontSize: "0.85rem",
                cursor: "pointer",
              }}
            >
              Salvar
            </button>
            <button
              type="button"
              onClick={() => setShowAddForm(false)}
              style={{
                padding: "9px 14px",
                borderRadius: "8px",
                background: "transparent",
                color: "var(--muted)",
                border: "1px solid var(--border)",
                fontSize: "0.85rem",
                cursor: "pointer",
              }}
            >
              Cancelar
            </button>
          </div>
        </form>
      )}

      {/* Items list */}
      <div style={{ display: "grid", gap: "8px" }}>
        {items.map((item) => {
          const { expirationDate, daysRemaining, status } = calculateWarrantyStatus(item, referenceDate);
          const isExpiring = status === "expiring_soon";
          const isExpired = status === "expired";

          return (
            <div
              key={item.id}
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                padding: "10px 14px",
                borderRadius: "10px",
                background: isExpiring
                  ? "rgba(245, 158, 11, 0.08)"
                  : "var(--surface-2, rgba(255,255,255,0.02))",
                border: isExpiring
                  ? "1px solid rgba(245, 158, 11, 0.3)"
                  : "1px solid var(--border)",
                flexWrap: "wrap",
                gap: "10px",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                <span
                  style={{
                    color: isExpired
                      ? "var(--muted)"
                      : isExpiring
                      ? "var(--warning, #f59e0b)"
                      : "var(--positive, #22c55e)",
                  }}
                >
                  {isExpired ? <Clock size={18} /> : isExpiring ? <AlertCircle size={18} /> : <CheckCircle2 size={18} />}
                </span>
                <div>
                  <strong style={{ fontSize: "0.9rem", color: "var(--text)", display: "block" }}>
                    {item.name}
                  </strong>
                  <span style={{ fontSize: "0.75rem", color: "var(--muted)", display: "flex", gap: "8px" }}>
                    {item.invoiceNumber && <span>{item.invoiceNumber}</span>}
                    {item.category && <span>• {item.category}</span>}
                    <span>• Compra: {item.purchaseDate}</span>
                  </span>
                </div>
              </div>

              <div style={{ textAlign: "right" }}>
                <b style={{ fontSize: "0.92rem", color: "var(--text)", display: "block" }}>
                  {money(item.value)}
                </b>
                <span
                  style={{
                    fontSize: "0.75rem",
                    fontWeight: 600,
                    color: isExpired
                      ? "var(--muted)"
                      : isExpiring
                      ? "var(--warning, #f59e0b)"
                      : "var(--accent, #3b82f6)",
                  }}
                >
                  {isExpired
                    ? "Garantia expirada"
                    : isExpiring
                    ? `Expira em ${daysRemaining}d (${expirationDate})`
                    : `Até ${expirationDate}`}
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
