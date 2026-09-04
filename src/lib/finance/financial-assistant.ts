export type FinancialAssistantData = {
  accounts: { id: string; name: string; type: string; initial_balance: number }[];
  categories: { id: string; name: string }[];
  transactions: {
    id: string;
    description: string;
    amount: number;
    type: string;
    competence_date: string;
    category_id?: string | null;
  }[];
  commitments?: {
    id: string;
    description: string;
    amount: number;
    due_day: number;
  }[];
  referenceDate?: string;
};

export type FinancialAssistantResponse = {
  text: string;
  matchedTransactions?: FinancialAssistantData["transactions"];
  chips?: string[];
};

function formatCurrency(val: number): string {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(val);
}

function normalize(str: string): string {
  return str
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .trim();
}

export function askFinancialAssistant(
  query: string,
  data: FinancialAssistantData
): FinancialAssistantResponse {
  const normQuery = normalize(query);
  const { accounts, categories, transactions, commitments = [] } = data;

  // 1. Saldo / Contas / Dinheiro
  if (
    normQuery.includes("saldo") ||
    normQuery.includes("quanto tenho") ||
    normQuery.includes("minhas contas")
  ) {
    const totalBalance = accounts.reduce((acc, a) => acc + (Number(a.initial_balance) || 0), 0);
    const accountLines = accounts
      .map((a) => `• **${a.name}**: ${formatCurrency(Number(a.initial_balance) || 0)}`)
      .join("\n");

    return {
      text: `Seu saldo total atual em contas é de **${formatCurrency(
        totalBalance
      )}**.\n\nDetalhamento por conta:\n${accountLines}`,
      chips: ["Qual meu maior gasto?", "O que vence nos próximos dias?", "Quanto gastei este mês?"],
    };
  }

  // 2. Maior gasto / Maiores despesas
  if (
    normQuery.includes("maior gasto") ||
    normQuery.includes("maiores despesas") ||
    normQuery.includes("onde gastei mais")
  ) {
    const expenses = transactions
      .filter((t) => t.type === "expense")
      .sort((a, b) => Number(b.amount) - Number(a.amount));

    if (expenses.length === 0) {
      return {
        text: "Você não possui despesas registradas no período para análise.",
        chips: ["Qual meu saldo?", "O que vence nos próximos dias?"],
      };
    }

    const top = expenses.slice(0, 3);
    const topLines = top
      .map((t, idx) => `${idx + 1}. **${t.description}**: ${formatCurrency(Number(t.amount))}`)
      .join("\n");

    return {
      text: `Seu maior gasto foi **${top[0].description}** no valor de **${formatCurrency(
        Number(top[0].amount)
      )}**.\n\nTop despesas:\n${topLines}`,
      matchedTransactions: top,
      chips: ["Quanto gastei com alimentação?", "Qual meu saldo?"],
    };
  }

  // 3. Contas a vencer / Próximos compromissos
  if (
    normQuery.includes("vence") ||
    normQuery.includes("contas a pagar") ||
    normQuery.includes("proximos dias") ||
    normQuery.includes("compromissos")
  ) {
    if (commitments.length === 0) {
      return {
        text: "Você não tem compromissos ou contas fixas cadastradas.",
        chips: ["Qual meu saldo?", "Qual meu maior gasto?"],
      };
    }

    const todayDay = data.referenceDate
      ? parseInt(data.referenceDate.split("-")[2], 10)
      : new Date().getDate();

    // Ordena por proximidade do vencimento
    const sorted = [...commitments].sort((a, b) => {
      const diffA = (a.due_day - todayDay + 31) % 31;
      const diffB = (b.due_day - todayDay + 31) % 31;
      return diffA - diffB;
    });

    const lines = sorted
      .slice(0, 4)
      .map(
        (c) => `• **${c.description}**: ${formatCurrency(Number(c.amount))} (Vencimento dia ${c.due_day})`
      )
      .join("\n");

    return {
      text: `Aqui estão seus próximos compromissos e contas agendadas:\n\n${lines}`,
      chips: ["Qual meu saldo?", "Qual meu maior gasto?"],
    };
  }

  // 4. Pergunta sobre categoria (ex: "quanto gastei com alimentação")
  for (const cat of categories) {
    const normCatName = normalize(cat.name);
    if (normQuery.includes(normCatName)) {
      const matched = transactions.filter(
        (t) => t.category_id === cat.id && t.type === "expense"
      );
      const total = matched.reduce((acc, t) => acc + Number(t.amount), 0);

      return {
        text: `Você gastou um total de **${formatCurrency(total)}** na categoria **${
          cat.name
        }** (${matched.length} transação/transações).`,
        matchedTransactions: matched,
        chips: ["Qual meu maior gasto?", "Qual meu saldo?"],
      };
    }
  }

  // 5. Pergunta sobre termo específico (ex: "quanto gastei com ifood", "delivery", "uber", "mercado")
  const stopWords = new Set([
    "quanto", "gastei", "com", "de", "em", "no", "na", "meu", "minha", "este", "mes",
    "total", "qual", "foi", "para", "um", "uma", "o", "a", "os", "as"
  ]);
  const tokens = normQuery
    .replace(/[^\w\s]/g, "")
    .split(/\s+/)
    .filter((w) => w.length > 2 && !stopWords.has(w));

  if (tokens.length > 0) {
    for (const token of tokens) {
      const matched = transactions.filter((t) =>
        normalize(t.description).includes(token)
      );
      if (matched.length > 0) {
        const total = matched.reduce((acc, t) => acc + Number(t.amount), 0);
        return {
          text: `Encontrei **${matched.length}** movimentação(ões) correspondente(s) a "${token}", somando **${formatCurrency(
            total
          )}**.`,
          matchedTransactions: matched,
          chips: ["Qual meu maior gasto?", "Qual meu saldo?"],
        };
      }
    }
  }

  // 6. Fallback com sugestões interativas
  return {
    text: "Não compreendi sua pergunta com precisão. Você pode perguntar sobre categorias, saldo, contas ou despesas.",
    chips: [
      "Qual meu saldo total?",
      "Qual foi meu maior gasto?",
      "Quanto gastei com alimentação?",
      "O que vence nos próximos dias?",
    ],
  };
}
