import { describe, it, expect } from "vitest";
import {
  calculateMilesValue,
  computeMilesSummary,
  type LoyaltyProgram,
} from "./miles-tracker";

describe("Miles & Points Tracker (Módulo 19)", () => {
  const samplePrograms: LoyaltyProgram[] = [
    {
      id: "prog-1",
      name: "Livelo",
      points: 45000,
      pricePerThousand: 32, // R$ 32 / milheiro
      expiringPoints: 10000,
      expiringDate: "2026-09-15",
    },
    {
      id: "prog-2",
      name: "Smiles",
      points: 80000,
      pricePerThousand: 16, // R$ 16 / milheiro
    },
    {
      id: "prog-3",
      name: "Latam Pass",
      points: 25000,
      pricePerThousand: 24, // R$ 24 / milheiro
      expiringPoints: 5000,
      expiringDate: "2026-08-30",
    },
  ];

  it("calculates estimated financial value of points correctly", () => {
    const valueLivelo = calculateMilesValue(samplePrograms[0]);
    // 45.000 / 1000 * 32 = 1.440
    expect(valueLivelo).toBe(1440);
  });

  it("computes total miles, total estimated cash value, and expiring points", () => {
    const summary = computeMilesSummary(samplePrograms);
    expect(summary.totalPoints).toBe(150000);
    // Livelo (1440) + Smiles (80*16=1280) + Latam (25*24=600) = 3320
    expect(summary.totalEstimatedValue).toBe(3320);
    expect(summary.totalExpiringPoints).toBe(15000);
  });
});
