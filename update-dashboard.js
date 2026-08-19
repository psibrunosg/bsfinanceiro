const fs = require('fs');
let content = fs.readFileSync('src/app/DashboardPage.tsx', 'utf8');

// 1. Remove unused imports
content = content.replace('import Link from "next/link";\n', '');
content = content.replace('ChevronDown, ', '');

// 2. Remove unused variables from useFinance
content = content.replace('const { ownerId, workspace, accounts, transactions, categories, budgets = [], goals, monthSpent = {}, commitments = [], occurrences = [], invoices = [], defaultCashAccountId, loading, reload } = useFinance("dashboard");', 'const { ownerId, workspace, accounts, transactions, categories, defaultCashAccountId, loading, reload } = useFinance("dashboard");');

// 3. Replace the return block
const returnIndex = content.indexOf('  const alerts = [');
if (returnIndex === -1) {
  console.log('Could not find alerts definition');
  process.exit(1);
}

const newReturn = `  return <main className="dashboard-shell">
    <Nav />
    
    <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
      <div>
        <p className="eyebrow">{workspace.name}</p>
        <h1 style={{ fontSize: '2rem', margin: '4px 0 16px' }}>Visão Global Financeira</h1>
        <MonthPicker />
      </div>
      <div>
        <button type="button" style={{ padding: '12px 24px', borderRadius: '12px', background: 'var(--primary)', color: 'var(--bg)', border: 'none', fontWeight: 600, display: 'flex', gap: '8px', alignItems: 'center', cursor: 'pointer' }} onClick={() => {
            if (!Dialog) import("./components/Dialog").then(m => setDialog(() => m.Dialog));
            setOpenQuickForm(true);
        }}>
          <Plus size={18} aria-hidden="true" />
          <span>Nova Movimentação</span>
        </button>
      </div>
    </div>

    {quickTransactionStatus ? <p className="form-success" role="status">{quickTransactionStatus}</p> : null}
    {ownerId && openQuickForm && Dialog ? (
      <Dialog open={openQuickForm} onClose={() => setOpenQuickForm(false)} title="Nova movimentação rápida">
        <QuickTransactionForm workspaceId={workspace.id} ownerId={ownerId} defaultCashAccountId={defaultCashAccountId} accounts={accounts} categories={categories} onSubmitStart={() => setQuickTransactionStatus("")} onSaved={reloadAfterQuickTransaction} />
      </Dialog>
    ) : null}

    <div className="dashboard-bento-grid">
      <div className="bento-main">
        <div className="bento-row">
          <article className="metric-card metric-card--positive">
            <WalletCards size={32} opacity={0.5} style={{ marginBottom: 16 }} />
            <span className="muted">Saldo Atual</span>
            <strong>{money(metrics.balance)}</strong>
          </article>
          <article className="metric-card">
            <Target size={32} opacity={0.5} style={{ marginBottom: 16 }} />
            <span className="muted">Entradas do Mês</span>
            <strong>{money(metrics.monthIncome)}</strong>
          </article>
          <article className="metric-card metric-card--negative">
            <CircleAlert size={32} opacity={0.5} style={{ marginBottom: 16 }} />
            <span className="muted">Saídas do Mês</span>
            <strong>{money(metrics.monthExpense)}</strong>
          </article>
        </div>

        <article className="dashboard-card" style={{ marginTop: '24px' }}>
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Evolução de Saldo Recomendado (30 dias)</h3>
          <p className="muted" style={{ marginBottom: '24px' }}>Baseado no teto diário de {money(dailyDecision.dailyLimit)} para manter o saldo positivo.</p>
          <div className="chart-wrap" style={{ height: '300px' }}>
            <DashboardChart type="line" label="Projeção" labels={dailyDecision.trajectory.map((item) => \`Dia \${item.day}\`)} values={dailyDecision.trajectory.map((item) => item.remaining)} color={dailyDecision.status === "critical" ? "#ef4444" : dailyDecision.status === "warning" ? "#f59e0b" : "#10b981"} />
          </div>
        </article>
      </div>

      <div className="bento-sidebar">
        <article className="dashboard-card" style={{ marginBottom: '24px' }}>
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Alocação de Gastos</h3>
          <div className="chart-wrap" style={{ height: '220px' }}>
            {metrics.expensesByCategory.length ? <DashboardChart type="doughnut" label="Gastos" labels={metrics.expensesByCategory.map((item) => item.label)} values={metrics.expensesByCategory.map((item) => item.value)} color="var(--accent)" /> : <p className="muted">Sem dados suficientes no mês.</p>}
          </div>
        </article>

        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Transações Recentes</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {transactions.slice(0, 5).map(t => (
              <div key={t.id} className="transaction-row" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', border: '1px solid var(--border)', borderRadius: '12px' }}>
                <div>
                  <div style={{ fontWeight: 600 }}>{t.description}</div>
                  <div className="muted" style={{ fontSize: '0.85rem' }}>{new Date(t.competence_date).toLocaleDateString('pt-BR')}</div>
                </div>
                <div style={{ fontWeight: 600, color: t.type === 'expense' ? 'var(--danger)' : 'var(--positive)' }}>
                  {t.type === 'expense' ? '-' : '+'}{money(Number(t.amount))}
                </div>
              </div>
            ))}
            {!transactions.length && <p className="muted">Nenhuma transação recente.</p>}
          </div>
        </article>
      </div>
    </div>
  </main>;
}
`;

fs.writeFileSync('src/app/DashboardPage.tsx', content.substring(0, returnIndex) + newReturn);
console.log('DashboardPage updated successfully.');
