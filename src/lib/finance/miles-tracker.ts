export type LoyaltyProgram = {
  id: string;
  name: string;
  points: number;
  pricePerThousand: number; // Valor estimado por milheiro em R$
  expiringPoints?: number;
  expiringDate?: string; // YYYY-MM-DD
  accountNumber?: string;
};

export type MilesSummary = {
  totalPoints: number;
  totalEstimatedValue: number;
  totalExpiringPoints: number;
  programCount: number;
};

export function calculateMilesValue(program: LoyaltyProgram): number {
  const points = Number(program.points) || 0;
  const price = Number(program.pricePerThousand) || 0;
  return Math.round((points / 1000) * price * 100) / 100;
}

export function computeMilesSummary(programs: LoyaltyProgram[]): MilesSummary {
  let totalPoints = 0;
  let totalEstimatedValue = 0;
  let totalExpiringPoints = 0;

  for (const prog of programs) {
    totalPoints += Number(prog.points) || 0;
    totalEstimatedValue += calculateMilesValue(prog);
    if (prog.expiringPoints) {
      totalExpiringPoints += Number(prog.expiringPoints) || 0;
    }
  }

  return {
    totalPoints,
    totalEstimatedValue: Math.round(totalEstimatedValue * 100) / 100,
    totalExpiringPoints,
    programCount: programs.length,
  };
}
