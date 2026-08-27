export type DetectedSubscription = {
  id: string;
  name: string;
  serviceKey: string;
  monthlyAmount: number;
  dueDay: number;
  category: "streaming" | "software" | "health_fitness" | "music" | "other";
  iconName?: string;
};

export type SubscriptionMetrics = {
  totalMonthly: number;
  annualizedCost: number;
  activeCount: number;
  mostExpensive: DetectedSubscription | null;
  upcomingRenewals: {
    id: string;
    name: string;
    amount: number;
    dueDay: number;
    daysRemaining: number;
  }[];
};

export type CancellationSavingsInput = {
  monthlyCost: number;
  annualRatePercent?: number; // Padrão: 12% a.a. CDI
  years?: number; // Padrão: 5 anos
};

export type CancellationSavingsResult = {
  totalSavedNominal: number;
  totalWithCompoundInterest: number;
  extraInterestGained: number;
};

type KnownService = {
  serviceKey: string;
  name: string;
  pattern: RegExp;
  category: "streaming" | "software" | "health_fitness" | "music" | "other";
};

const KNOWN_SERVICES: KnownService[] = [
  { serviceKey: "netflix", name: "Netflix", pattern: /netflix/i, category: "streaming" },
  { serviceKey: "spotify", name: "Spotify", pattern: /spotify/i, category: "music" },
  { serviceKey: "amazon_prime", name: "Amazon Prime", pattern: /(amazon\s*prime|prime\s*video|amzn\s*prime)/i, category: "streaming" },
  { serviceKey: "chatgpt", name: "ChatGPT (OpenAI)", pattern: /(openai|chatgpt)/i, category: "software" },
  { serviceKey: "disney_plus", name: "Disney+", pattern: /(disney\s*\+|disneyplus)/i, category: "streaming" },
  { serviceKey: "max", name: "Max (HBO)", pattern: /(max\.com|hbomax|hbo\s*max)/i, category: "streaming" },
  { serviceKey: "youtube", name: "YouTube Premium", pattern: /(youtube\s*premium|google\s*youtube)/i, category: "streaming" },
  { serviceKey: "apple", name: "Apple Services", pattern: /(apple\.com\/bill|apple\s*music|icloud)/i, category: "software" },
  { serviceKey: "smartfit", name: "Smart Fit", pattern: /smart\s*fit/i, category: "health_fitness" },
  { serviceKey: "gympass", name: "Gympass / Wellhub", pattern: /(gympass|wellhub)/i, category: "health_fitness" },
  { serviceKey: "uber_pass", name: "Uber One", pattern: /(uber\s*one|uber\s*pass)/i, category: "other" },
  { serviceKey: "globo_play", name: "Globoplay", pattern: /globoplay/i, category: "streaming" },
];

type InputTx = {
  id: string;
  description: string;
  amount: number | string;
  competence_date?: string;
};

type InputCommitment = {
  id: string;
  description: string;
  amount: number | string;
  due_day: number;
};

/**
 * Identifica serviços recorrentes e assinaturas conhecidas a partir de transações e compromissos.
 */
export function detectSubscriptions(
  transactions: InputTx[],
  commitments: InputCommitment[] = []
): DetectedSubscription[] {
  const foundMap = new Map<string, DetectedSubscription>();

  // 1. Processa compromissos fixos cadastrados
  for (const c of commitments) {
    const desc = (c.description || "").trim();
    for (const s of KNOWN_SERVICES) {
      if (s.pattern.test(desc)) {
        foundMap.set(s.serviceKey, {
          id: `sub-c-${c.id}`,
          name: s.name,
          serviceKey: s.serviceKey,
          monthlyAmount: Number(c.amount) || 0,
          dueDay: c.due_day || 1,
          category: s.category,
        });
        break;
      }
    }
  }

  // 2. Processa transações do histórico
  for (const tx of transactions) {
    const desc = (tx.description || "").trim();
    for (const s of KNOWN_SERVICES) {
      if (s.pattern.test(desc) && !foundMap.has(s.serviceKey)) {
        const dateObj = tx.competence_date ? new Date(`${tx.competence_date}T12:00:00`) : new Date();
        const dueDay = dateObj.getDate() || 1;

        foundMap.set(s.serviceKey, {
          id: `sub-tx-${tx.id}`,
          name: s.name,
          serviceKey: s.serviceKey,
          monthlyAmount: Number(tx.amount) || 0,
          dueDay,
          category: s.category,
        });
        break;
      }
    }
  }

  return Array.from(foundMap.values());
}

/**
 * Calcula o custo total mensal, anualizado e detecta vencimentos nos próximos dias.
 */
export function computeSubscriptionMetrics(
  subscriptions: DetectedSubscription[],
  currentDayOfMonth: number = new Date().getDate()
): SubscriptionMetrics {
  let totalMonthly = 0;
  let mostExpensive: DetectedSubscription | null = null;
  const upcomingRenewals: SubscriptionMetrics["upcomingRenewals"] = [];

  for (const sub of subscriptions) {
    totalMonthly += sub.monthlyAmount;

    if (!mostExpensive || sub.monthlyAmount > mostExpensive.monthlyAmount) {
      mostExpensive = sub;
    }

    // Calcula dias até a próxima cobrança
    let daysRemaining = sub.dueDay - currentDayOfMonth;
    if (daysRemaining < 0) {
      // Já passou este mês, próximo mês (estimativa aproximada de 30 dias)
      daysRemaining += 30;
    }

    if (daysRemaining >= 0 && daysRemaining <= 7) {
      upcomingRenewals.push({
        id: sub.id,
        name: sub.name,
        amount: sub.monthlyAmount,
        dueDay: sub.dueDay,
        daysRemaining,
      });
    }
  }

  upcomingRenewals.sort((a, b) => a.daysRemaining - b.daysRemaining);

  return {
    totalMonthly: Math.round(totalMonthly * 100) / 100,
    annualizedCost: Math.round(totalMonthly * 12 * 100) / 100,
    activeCount: subscriptions.length,
    mostExpensive,
    upcomingRenewals,
  };
}

/**
 * Calcula quanto o usuário acumularia caso cancelasse uma assinatura e investisse no CDI.
 */
export function simulateSubscriptionCancellationSavings(
  input: CancellationSavingsInput
): CancellationSavingsResult {
  const { monthlyCost, annualRatePercent = 12, years = 5 } = input;
  const months = years * 12;
  const monthlyRate = Math.pow(1 + annualRatePercent / 100, 1 / 12) - 1;

  let totalAccumulated = 0;
  for (let m = 1; m <= months; m++) {
    totalAccumulated = (totalAccumulated + monthlyCost) * (1 + monthlyRate);
  }

  const totalSavedNominal = Math.round(monthlyCost * months * 100) / 100;
  const totalWithCompoundInterest = Math.round(totalAccumulated * 100) / 100;
  const extraInterestGained =
    Math.round((totalWithCompoundInterest - totalSavedNominal) * 100) / 100;

  return {
    totalSavedNominal,
    totalWithCompoundInterest,
    extraInterestGained,
  };
}
