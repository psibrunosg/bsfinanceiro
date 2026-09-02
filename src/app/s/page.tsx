"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { PrintButton } from "@/app/components/PrintButton";
import { money } from "@/app/components/Money";

function SharedReportContent() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  
  const [data, setData] = useState<{ report: { name: string }, transactions: { type: string, amount: string | number, competence_date: string, description?: string, id: string }[] } | null>(null);
  const [error, setError] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!token) {
      setError(true);
      setLoading(false);
      return;
    }
    
    const supabase = createClient();
    supabase.rpc("get_shared_report_data", { p_token: token }).then(({ data: resData, error }) => {
      if (error || !resData) {
        setError(true);
      } else {
        setData(resData as never); // using as never inside then
      }
      setLoading(false);
    });
  }, [token]);

  if (loading) return <main style={{ padding: "2rem" }}>Carregando relatório...</main>;
  if (error || !data) return <main style={{ padding: "2rem" }}>Relatório não encontrado ou link inválido.</main>;

  const { report, transactions } = data;
  const income = transactions.filter(t => t.type === "income").reduce((acc, t) => acc + Number(t.amount), 0);
  const expense = transactions.filter(t => t.type !== "income").reduce((acc, t) => acc + Number(t.amount), 0);
  const balance = income - expense;

  return (
    <main style={{ maxWidth: 800, margin: "0 auto", padding: "2rem", fontFamily: "system-ui, sans-serif" }}>
      <header style={{ marginBottom: "2rem", borderBottom: "1px solid #ccc", paddingBottom: "1rem" }}>
        <h1>Relatório Compartilhado: {report.name}</h1>
        <p style={{ color: "#666" }}>Gerado pelo BS Financeiro</p>
        <PrintButton />
      </header>

      <section style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "1rem", marginBottom: "2rem" }}>
        <div style={{ padding: "1rem", border: "1px solid #e5e7eb", borderRadius: "8px" }}>
          <div style={{ fontSize: "0.875rem", color: "#6b7280" }}>Receitas</div>
          <div style={{ fontSize: "1.5rem", fontWeight: "bold", color: "#10b981" }}>{money(income)}</div>
        </div>
        <div style={{ padding: "1rem", border: "1px solid #e5e7eb", borderRadius: "8px" }}>
          <div style={{ fontSize: "0.875rem", color: "#6b7280" }}>Despesas</div>
          <div style={{ fontSize: "1.5rem", fontWeight: "bold", color: "#ef4444" }}>{money(expense)}</div>
        </div>
        <div style={{ padding: "1rem", border: "1px solid #e5e7eb", borderRadius: "8px" }}>
          <div style={{ fontSize: "0.875rem", color: "#6b7280" }}>Saldo</div>
          <div style={{ fontSize: "1.5rem", fontWeight: "bold", color: "#3b82f6" }}>{money(balance)}</div>
        </div>
      </section>

      <section>
        <h2>Extrato de Lançamentos ({transactions.length})</h2>
        <table style={{ width: "100%", borderCollapse: "collapse", marginTop: "1rem" }}>
          <thead>
            <tr style={{ borderBottom: "2px solid #ccc", textAlign: "left" }}>
              <th style={{ padding: "8px" }}>Data</th>
              <th style={{ padding: "8px" }}>Descrição</th>
              <th style={{ padding: "8px" }}>Valor</th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((t: { type: string, amount: string | number, competence_date: string, description?: string, id: string }) => (
              <tr key={t.id} style={{ borderBottom: "1px solid #eee" }}>
                <td style={{ padding: "8px" }}>{t.competence_date.split("-").reverse().join("/")}</td>
                <td style={{ padding: "8px" }}>{t.description || "—"}</td>
                <td style={{ padding: "8px", color: t.type === "income" ? "#10b981" : "inherit" }}>
                  {money(t.amount)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
    </main>
  );
}

export default function SharedReportPage() {
  return (
    <Suspense fallback={<main style={{ padding: "2rem" }}>Carregando...</main>}>
      <SharedReportContent />
    </Suspense>
  );
}
