export type GoalActionTarget = { id: string };

export type TodayAction = {
  id: "expense" | "income" | "card" | "goal";
  label: string;
  href: string;
};

export function todayActions(goals: readonly GoalActionTarget[]): TodayAction[] {
  const goal = goals.length === 0
    ? { label: "Criar meta", href: "/planejamento?focus=new-goal" }
    : goals.length === 1
      ? { label: "Aportar meta", href: `/planejamento?focus=goal-contribution&goalId=${encodeURIComponent(goals[0].id)}` }
      : { label: "Escolher meta", href: "/planejamento?focus=choose-goal" };

  return [
    { id: "expense", label: "Nova despesa", href: "/movimentacoes?type=expense" },
    { id: "income", label: "Nova receita", href: "/movimentacoes?type=income" },
    { id: "card", label: "Adicionar cartão", href: "/cartoes?focus=new-card" },
    { id: "goal", ...goal },
  ];
}
