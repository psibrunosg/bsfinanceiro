export type EmergencyFundInput = {
  monthlyFixedExpenses: number;
  currentFundBalance: number;
  targetMonths?: number; // 6 (CLT) ou 12 (Autônomo/PJ)
  annualCdiPercent?: number; // Padrão: 12% a.a.
};

export type EmergencyFundResult = {
  monthlyFixedExpenses: number;
  currentFundBalance: number;
  targetMonths: number;
  targetAmount: number;
  currentRunwayMonths: number;
  progressPercent: number;
  remainingAmount: number;
  monthlyYieldCdi: number;
  safetyStatus: "critical" | "moderate" | "safe" | "shielded";
  statusText: string;
};

export type WithdrawalSimulationInput = {
  currentFundBalance: number;
  monthlyFixedExpenses: number;
  withdrawAmount: number;
};

export type WithdrawalSimulationResult = {
  currentFundBalance: number;
  withdrawAmount: number;
  newBalance: number;
  currentRunwayMonths: number;
  newRunwayMonths: number;
  lostRunwayMonths: number;
  warningMessage: string;
};

/**
 * Calcula as métricas essenciais da reserva de emergência e meses de sobrevivência (runway).
 */
export function calculateEmergencyFundMetrics(
  input: EmergencyFundInput
): EmergencyFundResult {
  const {
    monthlyFixedExpenses,
    currentFundBalance,
    targetMonths = 6,
    annualCdiPercent = 12.0,
  } = input;

  const cost = Math.max(1, monthlyFixedExpenses);
  const balance = Math.max(0, currentFundBalance);
  const target = Math.max(1, targetMonths);

  const targetAmount = Math.round(cost * target * 100) / 100;
  const currentRunwayMonths = Math.round((balance / cost) * 10) / 10;
  const progressPercent =
    targetAmount > 0 ? Math.min(100, Math.round((balance / targetAmount) * 1000) / 10) : 100;
  const remainingAmount = Math.max(0, Math.round((targetAmount - balance) * 100) / 100);

  const monthlyRate = Math.pow(1 + annualCdiPercent / 100, 1 / 12) - 1;
  const monthlyYieldCdi = Math.round(balance * monthlyRate * 100) / 100;

  let safetyStatus: EmergencyFundResult["safetyStatus"] = "critical";
  let statusText = "Reserva Crítica (Menos de 2 meses de sobrevivência)";

  if (currentRunwayMonths >= target) {
    safetyStatus = "shielded";
    statusText = "Reserva 100% Blindada! Seu custo de vida está totalmente protegido.";
  } else if (currentRunwayMonths >= 6) {
    safetyStatus = "safe";
    statusText = "Reserva Segura! Fôlego para 6 meses ou mais.";
  } else if (currentRunwayMonths >= 2) {
    safetyStatus = "moderate";
    statusText = "Reserva Moderada. Continue aportando para blindar seu custo de vida.";
  }

  return {
    monthlyFixedExpenses: cost,
    currentFundBalance: balance,
    targetMonths: target,
    targetAmount,
    currentRunwayMonths,
    progressPercent,
    remainingAmount,
    monthlyYieldCdi,
    safetyStatus,
    statusText,
  };
}

/**
 * Simula o impacto de uma retirada sobre o fôlego de sobrevivência (Guardião da Reserva).
 */
export function simulateWithdrawalImpact(
  input: WithdrawalSimulationInput
): WithdrawalSimulationResult {
  const { currentFundBalance, monthlyFixedExpenses, withdrawAmount } = input;

  const cost = Math.max(1, monthlyFixedExpenses);
  const balance = Math.max(0, currentFundBalance);
  const withdraw = Math.max(0, withdrawAmount);

  const newBalance = Math.max(0, balance - withdraw);
  const currentRunwayMonths = Math.round((balance / cost) * 10) / 10;
  const newRunwayMonths = Math.round((newBalance / cost) * 10) / 10;
  const lostRunwayMonths = Math.round((currentRunwayMonths - newRunwayMonths) * 10) / 10;

  const warningMessage = `Atenção: Retirar R$ ${withdraw.toLocaleString("pt-BR")} reduz seu fôlego de sobrevivência de ${currentRunwayMonths.toFixed(1).replace(".", ",")} para ${newRunwayMonths.toFixed(1).replace(".", ",")} meses (-${lostRunwayMonths.toFixed(1).replace(".", ",")} meses de proteção).`;

  return {
    currentFundBalance: balance,
    withdrawAmount: withdraw,
    newBalance,
    currentRunwayMonths,
    newRunwayMonths,
    lostRunwayMonths,
    warningMessage,
  };
}
