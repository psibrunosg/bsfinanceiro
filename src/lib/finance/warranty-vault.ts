export type WarrantyItem = {
  id: string;
  name: string;
  purchaseDate: string; // YYYY-MM-DD
  warrantyMonths: number;
  invoiceNumber?: string;
  value: number;
  category?: string;
  notes?: string;
};

export type WarrantyStatus = {
  expirationDate: string;
  daysRemaining: number;
  status: "active" | "expiring_soon" | "expired";
};

export type WarrantySummary = {
  totalProtectedValue: number;
  activeCount: number;
  expiringSoonCount: number;
  expiredCount: number;
};

export function calculateWarrantyStatus(
  item: WarrantyItem,
  referenceDate?: string
): WarrantyStatus {
  const [year, month, day] = item.purchaseDate.split("-").map(Number);
  const expDate = new Date(Date.UTC(year, month - 1 + item.warrantyMonths, day));

  const expYear = expDate.getUTCFullYear();
  const expMonth = String(expDate.getUTCMonth() + 1).padStart(2, "0");
  const expDay = String(expDate.getUTCDate()).padStart(2, "0");
  const expirationDate = `${expYear}-${expMonth}-${expDay}`;

  let refUtc: number;
  if (referenceDate) {
    const [ry, rm, rd] = referenceDate.split("-").map(Number);
    refUtc = Date.UTC(ry, rm - 1, rd);
  } else {
    const now = new Date();
    refUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
  }

  const diffTime = expDate.getTime() - refUtc;
  const daysRemaining = Math.round(diffTime / (1000 * 60 * 60 * 24));

  let status: "active" | "expiring_soon" | "expired" = "active";
  if (daysRemaining <= 0) {
    status = "expired";
  } else if (daysRemaining <= 30) {
    status = "expiring_soon";
  }

  return {
    expirationDate,
    daysRemaining,
    status,
  };
}

export function computeWarrantySummary(
  items: WarrantyItem[],
  referenceDate?: string
): WarrantySummary {
  let totalProtectedValue = 0;
  let activeCount = 0;
  let expiringSoonCount = 0;
  let expiredCount = 0;

  for (const item of items) {
    const { status } = calculateWarrantyStatus(item, referenceDate);
    if (status === "expired") {
      expiredCount++;
    } else {
      activeCount++;
      totalProtectedValue += Number(item.value) || 0;
      if (status === "expiring_soon") {
        expiringSoonCount++;
      }
    }
  }

  return {
    totalProtectedValue,
    activeCount,
    expiringSoonCount,
    expiredCount,
  };
}
