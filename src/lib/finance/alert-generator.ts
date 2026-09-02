import type { FinancialAlert } from "./alerts";


type Account = { id: string; name: string; initial_balance: number };
type Transaction = { id: string; amount: number; type: string; category_id?: string | null; competence_date: string; status?: string };
type Invoice = { id: string; due_date: string; status: string; credit_card_installments?: { amount: number }[] | null };
type Occurrence = { id: string; description: string; amount: number; due_date?: string; status: string };
type Goal = { id: string; name: string; target_amount: number; current_amount: number };
type Budget = { id: string; category_id: string; amount: number };

export function generateAllAlerts(
  accounts: Account[],
  transactions: Transaction[],
  invoices: Invoice[],
  occurrences: Occurrence[],
  goals: Goal[],
  budgets: Budget[],
  currentDate: Date
): FinancialAlert[] {
  const alerts: FinancialAlert[] = [];
  const todayIso = currentDate.toISOString().split("T")[0];

  // 1. Alerta de orçamento 80%
  // Calculate expenses by category for current month
  const currentMonthStart = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1).toISOString().split("T")[0];
  const monthExpenses = transactions.filter(t => t.type === "expense" && t.competence_date >= currentMonthStart && t.competence_date <= todayIso);
  const expensesByCat = new Map<string, number>();
  monthExpenses.forEach(t => {
    if (t.category_id) expensesByCat.set(t.category_id, (expensesByCat.get(t.category_id) || 0) + t.amount);
  });

  budgets.forEach(b => {
    const spent = expensesByCat.get(b.category_id) || 0;
    if (spent >= b.amount * 0.8 && spent < b.amount) {
      alerts.push({
        id: `budget-80-${b.id}`,
        title: "Orçamento Próximo do Limite",
        message: `Você atingiu ${Math.round((spent / b.amount) * 100)}% do limite.`,
        preference: "budget",
        severity: "warning",
        impactCents: spent * 100,
      });
    } else if (spent >= b.amount) {
      alerts.push({
        id: `budget-100-${b.id}`,
        title: "Orçamento Estourado",
        message: `Você excedeu o limite mensal estipulado.`,
        preference: "budget",
        severity: "critical",
        impactCents: spent * 100,
      });
    }
  });

  // 2. Alerta de fatura próxima do vencimento (3 dias)
  const threeDaysFromNow = new Date(currentDate);
  threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);
  const threeDaysIso = threeDaysFromNow.toISOString().split("T")[0];
  
  invoices.filter(i => i.status !== "paid").forEach(inv => {
    if (inv.due_date >= todayIso && inv.due_date <= threeDaysIso) {
      const parts = inv.due_date.split("-");
      let totalAmount = 0;
      if (Array.isArray(inv.credit_card_installments)) {
        totalAmount = inv.credit_card_installments.reduce((acc: number, inst: { amount: number }) => acc + (inst.amount || 0), 0);
      }
      alerts.push({
        id: `invoice-due-${inv.id}`,
        title: "Fatura Próxima do Vencimento",
        message: `Fatura vence dia ${parts[2]}/${parts[1]}.`,
        preference: "invoice",
        severity: "warning",
        impactCents: totalAmount * 100,
        dueDate: inv.due_date
      });
    }
  });

  // 3. Alerta de compromisso fixo (2 dias)
  const twoDaysFromNow = new Date(currentDate);
  twoDaysFromNow.setDate(twoDaysFromNow.getDate() + 2);
  const twoDaysIso = twoDaysFromNow.toISOString().split("T")[0];
  
  occurrences.filter(o => o.status !== "paid" && o.due_date).forEach(c => {
    if (c.due_date! >= todayIso && c.due_date! <= twoDaysIso) {
      const parts = c.due_date!.split("-");
      alerts.push({
        id: `commitment-due-${c.id}`,
        title: "Conta Fixa Próxima do Vencimento",
        message: `${c.description} vence dia ${parts[2]}/${parts[1]}.`,
        preference: "recurring",
        severity: "warning",
        impactCents: c.amount * 100,
        dueDate: c.due_date
      });
    }
  });

  // 4. Alerta de meta atingida
  goals.forEach(g => {
    if (g.current_amount >= g.target_amount && g.target_amount > 0) {
      alerts.push({
        id: `goal-reached-${g.id}`,
        title: "Meta Atingida! 🎉",
        message: `Parabéns, você completou a meta ${g.name}!`,
        preference: "goal",
        severity: "info",
        impactCents: g.target_amount * 100,
      });
    }
  });

  // 5. Alerta de saldo baixo
  // Assuming threshold is < 10% of total income for the month, or hardcoded $100 for now.
  // We don't have account limits in the database schema yet, so we use a heuristic.
  // accounts.forEach(a => {
  //   // We would need to calculate real balance here, but for now we skip or use a generic one
  // });

  return alerts;
}
