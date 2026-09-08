"use client";

import { useMemo } from "react";
import { money, dateFmt } from "./Money";
import type { Account, Category } from "./types";

export type ExecutiveReportProps = {
  workspaceName: string;
  label: string;
  month: string;
  income: number;
  expense: number;
  rows: Array<{
    name: string;
    total: number;
    share: number;
    delta: number | null;
  }>;
  topExpenses: Array<{
    id: string;
    description?: string | null;
    amount: number | string;
    competence_date: string;
    category_id?: string | null;
    account_id?: string | null;
  }>;
  categories: Category[];
  accounts: Account[];
  isScreenPreview?: boolean;
};

export function ExecutiveReportView({
  workspaceName,
  label,
  month,
  income,
  expense,
  rows,
  topExpenses,
  categories,
  accounts,
  isScreenPreview = false,
}: ExecutiveReportProps) {
  const netSavings = income - expense;
  const savingsRate = income > 0 ? (netSavings / income) * 100 : 0;

  const categoryMap = useMemo(() => {
    return new Map(categories.map((c) => [c.id, c.name]));
  }, [categories]);

  const containerStyle = isScreenPreview
    ? {
        background: "#ffffff",
        color: "#111827",
        padding: "24px",
        borderRadius: "8px",
        border: "1px solid #e5e7eb",
        fontFamily: "system-ui, -apple-system, sans-serif",
      }
    : undefined;

  return (
    <div className={isScreenPreview ? "exec-report-screen" : "print-only"} style={containerStyle}>
      {/* Cabeçalho Executivo */}
      <div className="exec-print-header" style={{ borderBottom: "2px solid #111827", paddingBottom: "10px", marginBottom: "14px", display: "flex", justifyContent: "space-between", alignItems: "flex-end" }}>
        <div>
          <div style={{ fontSize: "18pt", fontWeight: 800, letterSpacing: "-0.02em", color: "#111827", margin: 0 }}>
            BS FINANCEIRO
          </div>
          <p style={{ margin: "2px 0 0", fontSize: "10pt", color: "#4b5563" }}>
            Relatório Executivo Mensal · {workspaceName}
          </p>
        </div>
        <div style={{ textAlign: "right" }}>
          <span style={{ fontSize: "12pt", fontWeight: 700, color: "#111827", display: "block" }}>
            {label}
          </span>
          <small style={{ fontSize: "8pt", color: "#6b7280" }}>
            Competência: {month}
          </small>
        </div>
      </div>

      {/* Grade de Indicadores Principais (KPIs) */}
      <div className="exec-print-kpi-grid">
        <div className="exec-print-kpi">
          <span>Receitas Totais</span>
          <strong>{money(income)}</strong>
        </div>
        <div className="exec-print-kpi">
          <span>Despesas Totais</span>
          <strong>{money(expense)}</strong>
        </div>
        <div className="exec-print-kpi">
          <span>Resultado Líquido</span>
          <strong style={{ color: netSavings >= 0 ? "#166534" : "#991b1b" }}>
            {money(netSavings)}
          </strong>
        </div>
        <div className="exec-print-kpi">
          <span>Taxa de Poupança</span>
          <strong>{savingsRate.toFixed(1).replace(".", ",")}%</strong>
        </div>
      </div>

      {/* Distribuição de Gastos por Categoria */}
      <div style={{ marginBottom: "18px" }}>
        <h3 style={{ margin: "0 0 6px", fontSize: "11pt", fontWeight: 700, borderBottom: "1px solid #111827", paddingBottom: "4px", color: "#111827" }}>
          Distribuição de Despesas por Categoria
        </h3>
        {rows.length > 0 ? (
          <table className="exec-print-table">
            <thead>
              <tr>
                <th style={{ width: "40%" }}>Categoria</th>
                <th style={{ width: "22%", textAlign: "right" }}>Total</th>
                <th style={{ width: "18%", textAlign: "right" }}>% do Mês</th>
                <th style={{ width: "20%", textAlign: "right" }}>vs. Mês Anterior</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.name}>
                  <td><strong>{row.name}</strong></td>
                  <td style={{ textAlign: "right" }}>{money(row.total)}</td>
                  <td style={{ textAlign: "right" }}>{row.share.toFixed(1).replace(".", ",")}%</td>
                  <td style={{ textAlign: "right" }}>
                    {row.delta === null ? "—" : `${row.delta > 0 ? "+" : ""}${row.delta.toFixed(1).replace(".", ",")}%`}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <p style={{ fontSize: "9pt", color: "#6b7280", fontStyle: "italic" }}>
            Nenhuma despesa registrada nesta competência.
          </p>
        )}
      </div>

      {/* Maiores Gastos do Mês */}
      {topExpenses.length > 0 && (
        <div style={{ marginBottom: "18px" }}>
          <h3 style={{ margin: "0 0 6px", fontSize: "11pt", fontWeight: 700, borderBottom: "1px solid #111827", paddingBottom: "4px", color: "#111827" }}>
            Maiores Lançamentos do Período
          </h3>
          <table className="exec-print-table">
            <thead>
              <tr>
                <th style={{ width: "18%" }}>Data</th>
                <th style={{ width: "42%" }}>Descrição</th>
                <th style={{ width: "22%" }}>Categoria</th>
                <th style={{ width: "18%", textAlign: "right" }}>Valor</th>
              </tr>
            </thead>
            <tbody>
              {topExpenses.map((tx) => (
                <tr key={tx.id}>
                  <td>{dateFmt.format(new Date(`${tx.competence_date}T12:00:00`))}</td>
                  <td>{tx.description || "Sem descrição"}</td>
                  <td>{categoryMap.get(tx.category_id ?? "") || "Sem categoria"}</td>
                  <td style={{ textAlign: "right", fontWeight: 600 }}>{money(tx.amount)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Contas e Posição Patrimonial */}
      {accounts.length > 0 && (
        <div style={{ marginBottom: "16px" }}>
          <h3 style={{ margin: "0 0 6px", fontSize: "11pt", fontWeight: 700, borderBottom: "1px solid #111827", paddingBottom: "4px", color: "#111827" }}>
            Contas Cadastradas no Workspace
          </h3>
          <table className="exec-print-table">
            <thead>
              <tr>
                <th style={{ width: "60%" }}>Conta</th>
                <th style={{ width: "40%", textAlign: "right" }}>Saldo Base / Tipo</th>
              </tr>
            </thead>
            <tbody>
              {accounts.map((acc) => (
                <tr key={acc.id}>
                  <td>{acc.name}</td>
                  <td style={{ textAlign: "right" }}>
                    {money(acc.initial_balance)} ({acc.type === "checking" ? "Conta Corrente" : acc.type === "savings" ? "Poupança" : acc.type === "investment" ? "Investimentos" : "Carteira"})
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Rodapé Executivo */}
      <div
        style={{
          marginTop: "20px",
          paddingTop: "8px",
          borderTop: "1px solid #d1d5db",
          display: "flex",
          justifyContent: "space-between",
          fontSize: "7.5pt",
          color: "#6b7280",
        }}
      >
        <span>BS Financeiro · Gestão Patrimonial Inteligente</span>
        <span>Relatório emitido para conferência e planejamento</span>
      </div>
    </div>
  );
}
