import { describe, it, expect } from "vitest";
import {
  computeAcademicRoi,
  simulateNextAcademicInvestment,
} from "./academic-roi";

describe("academic-roi", () => {
  it("calculates course payback and net return on clinical education", () => {
    const courses = [
      {
        id: "c1",
        title: "Especialização em TCC",
        cost: 4000,
        completionDate: "2025-06-01",
        monthlyIncomeBefore: 6000,
        monthlyIncomeAfter: 8000, // +2000/mês
      },
      {
        id: "c2",
        title: "Supervisão Clínica Avançada",
        cost: 1500,
        completionDate: "2026-01-01",
        monthlyIncomeBefore: 8000,
        monthlyIncomeAfter: 8500, // +500/mês
      },
    ];

    const res = computeAcademicRoi(courses, "2026-08");

    expect(res.totalInvested).toBe(5500); // 4000 + 1500
    expect(res.totalMonthlyGain).toBe(2500); // 2000 + 500
    expect(res.coursesWithRoi[0].paybackMonths).toBe(2); // 4000 / 2000 = 2 meses
    expect(res.coursesWithRoi[0].isPaidOff).toBe(true);
    expect(res.coursesWithRoi[0].totalReturnToDate).toBeGreaterThan(20000);
    expect(res.topPerformingCourse?.title).toBe("Especialização em TCC");
  });

  it("simulates payback for a prospective course or specialization", () => {
    const sim = simulateNextAcademicInvestment({
      courseCost: 12000,
      expectedIncomeIncreasePercent: 20, // +20% na renda atual
      currentMonthlyIncome: 10000,
    });

    expect(sim.monthlyGain).toBe(2000); // 20% de 10.000
    expect(sim.paybackMonths).toBe(6);  // 12.000 / 2.000 = 6 meses
    expect(sim.verdict).toContain("se paga em 6 meses");
  });
});
