import { describe, it, expect } from "vitest";
import {
  calculateWarrantyStatus,
  computeWarrantySummary,
  type WarrantyItem,
} from "./warranty-vault";

describe("Warranty Vault (Módulo 12)", () => {
  const refDate = "2026-08-15";

  const sampleItems: WarrantyItem[] = [
    {
      id: "w-1",
      name: "iPhone 15 Pro",
      purchaseDate: "2025-09-10",
      warrantyMonths: 12, // Expira em 2026-09-10 (~26 dias restante -> expiring_soon)
      invoiceNumber: "NF-00129",
      value: 7500,
      category: "Eletrônicos",
    },
    {
      id: "w-2",
      name: "Geladeira Brastemp",
      purchaseDate: "2026-01-01",
      warrantyMonths: 24, // Expira em 2028-01-01 -> active
      invoiceNumber: "NF-99882",
      value: 4200,
      category: "Eletrodomésticos",
    },
    {
      id: "w-3",
      name: "Fone Bluetooth",
      purchaseDate: "2025-01-01",
      warrantyMonths: 12, // Expirou em 2026-01-01 -> expired
      value: 250,
      category: "Acessórios",
    },
  ];

  it("calculates correct expiration date and status for active, expiring_soon, and expired", () => {
    const status1 = calculateWarrantyStatus(sampleItems[0], refDate);
    expect(status1.status).toBe("expiring_soon");
    expect(status1.daysRemaining).toBe(26);
    expect(status1.expirationDate).toBe("2026-09-10");

    const status2 = calculateWarrantyStatus(sampleItems[1], refDate);
    expect(status2.status).toBe("active");
    expect(status2.daysRemaining).toBeGreaterThan(30);

    const status3 = calculateWarrantyStatus(sampleItems[2], refDate);
    expect(status3.status).toBe("expired");
    expect(status3.daysRemaining).toBeLessThan(0);
  });

  it("computes warranty summary with total protected value and counts", () => {
    const summary = computeWarrantySummary(sampleItems, refDate);
    expect(summary.totalProtectedValue).toBe(11700); // iPhone (7500) + Geladeira (4200)
    expect(summary.activeCount).toBe(2);
    expect(summary.expiringSoonCount).toBe(1);
    expect(summary.expiredCount).toBe(1);
  });
});
