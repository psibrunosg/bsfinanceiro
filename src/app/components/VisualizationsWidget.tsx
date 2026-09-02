"use client";

import { useMemo } from "react";
import { DashboardChart } from "./DashboardChart";
import { money } from "./Money";
import { PieChart, TrendingUp, TrendingDown, Info } from "lucide-react";
import { aggregateExpensesByCategory, computeMonthlyFlow, lastNMonths } from "@/lib/finance/aggregations";
import { generateInsights } from "@/lib/finance/insights";

import type { TransferTransaction as Transaction } from "@/lib/finance/transfers";

type Category = {
  id: string;
  name: string;
  kind: string;
};

type Account = {
  id: string;
  name: string;
  initial_balance: number;
};

type Props = {
  transactions: Transaction[];
  categories: Category[];
  accounts: Account[];
  currentMonth: string;
  nextMonth: string;
};

const CHART_COLORS = [
  "#087f5b", "#d97706", "#e53e3e", "#8B5CF6", "#3B82F6", "#F43F5E", "#10B981"
];

export function VisualizationsWidget({ transactions, categories, accounts, currentMonth, nextMonth }: Props) {
  const data = useMemo(() => {
    // 1. Resumo por categoria e Gráfico de Pizza
    const expensesByCategory = aggregateExpensesByCategory(transactions, categories, currentMonth, 5, nextMonth);
    const categoryLabels = expensesByCategory.map(c => c.label);
    const categoryValues = expensesByCategory.map(c => c.value);

    // 2. Evolução do Saldo (últimos 6 meses)
    const { months: evolutionMonths, labels: evolutionLabels } = lastNMonths(6);
    const { flowIn, flowOut } = computeMonthlyFlow(transactions, evolutionMonths, { categories });
    
    // Calcula saldo projetado/histórico aproximado
    const initialBalance = accounts.reduce((sum, item) => sum + Number(item.initial_balance), 0);
    // Para simplificar, assumimos o saldo histórico somando iterativamente (o ideal era buscar do DRE, mas serve para viz)
    let currentBal = initialBalance;
    const balanceEvolution = evolutionMonths.map((d, index) => {
      // Simplification for line chart
      currentBal += (flowIn[index] - flowOut[index]);
      return currentBal;
    });

    // 3. Relatório Mensal Comparativo (Insights / Data Storytelling)
    // O insights.ts já gera o "Em relação ao mês passado, seus gastos..."
    const insights = generateInsights(transactions as unknown as Parameters<typeof generateInsights>[0], categories, accounts, currentMonth);

    return {
      expensesByCategory,
      categoryLabels,
      categoryValues,
      evolutionLabels,
      flowIn,
      flowOut,
      balanceEvolution,
      insights
    };
  }, [transactions, categories, accounts, currentMonth, nextMonth]);

  return (
    <div className="visualizations-widget" style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      
      {/* Relatório Mensal Comparativo */}
      <article className="dashboard-card" style={{ background: 'rgba(8, 127, 91, 0.05)', border: '1px solid rgba(8, 127, 91, 0.2)' }}>
        <h3 style={{ marginBottom: '16px', fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Info size={20} color="var(--accent)" />
          Relatório Mensal
        </h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {data.insights.length > 0 ? (
            data.insights.map(insight => (
              <p key={insight.id} style={{ margin: 0, fontSize: '1rem', display: 'flex', gap: '8px' }}>
                <span>{insight.icon}</span>
                <span>{insight.text}</span>
              </p>
            ))
          ) : (
            <p className="muted" style={{ margin: 0 }}>Nenhum insight disponível para este mês ainda.</p>
          )}
        </div>
      </article>

      <div className="dashboard-bento-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))' }}>
        
        {/* Gráfico de Pizza e Resumo por Categoria */}
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <PieChart size={20} />
            Despesas por Categoria
          </h3>
          
          {data.categoryValues.length > 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
              <div style={{ height: '220px' }}>
                <DashboardChart 
                  type="doughnut" 
                  label="Gastos" 
                  labels={data.categoryLabels} 
                  values={data.categoryValues} 
                  color="var(--accent)" 
                />
              </div>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <h4 className="muted" style={{ margin: 0, fontSize: '0.85rem', textTransform: 'uppercase' }}>Top 5 Categorias</h4>
                {(() => {
                  const total = data.categoryValues.reduce((sum, v) => sum + v, 0);
                  return data.expensesByCategory.map((cat, i) => (
                    <div key={cat.label} style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <span style={{ display: 'inline-block', width: '10px', height: '10px', borderRadius: '50%', background: CHART_COLORS[i % CHART_COLORS.length] }}></span>
                        {cat.label}
                      </span>
                      <span style={{ fontWeight: '500' }}>{money(cat.value)} <span className="muted" style={{ fontWeight: 'normal', fontSize: '0.8rem' }}>({total > 0 ? Math.round((cat.value / total) * 100) : 0}%)</span></span>
                    </div>
                  ));
                })()}
              </div>
            </div>
          ) : (
            <p className="muted dashboard-empty">Sem despesas registradas para o período.</p>
          )}
        </article>

        {/* Gráfico de Fluxo de Caixa (Barra) */}
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <TrendingUp size={20} />
            Fluxo de Caixa (Mensal)
          </h3>
          <div style={{ height: '280px' }}>
            <DashboardChart
              type="bar"
              labels={data.evolutionLabels}
              compactY
              series={[
                { label: "Receitas", values: data.flowIn, color: "var(--positive)" },
                { label: "Despesas", values: data.flowOut, color: "var(--danger)" },
              ]}
            />
          </div>
        </article>

        {/* Linha de Evolução de Saldo */}
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <TrendingDown size={20} />
            Evolução do Saldo
          </h3>
          <div style={{ height: '280px' }}>
            <DashboardChart
              type="line"
              labels={data.evolutionLabels}
              compactY
              series={[
                { label: "Saldo Projetado", values: data.balanceEvolution, color: "var(--accent)" },
              ]}
            />
          </div>
        </article>

      </div>
    </div>
  );
}
