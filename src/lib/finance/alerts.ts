export type AlertPreference =
  | "budget"
  | "cashflow"
  | "invoice"
  | "goal"
  | "recurring";

export type AlertSeverity = "info" | "warning" | "critical";

export type FinancialAlert = {
  id: string;
  preference: AlertPreference;
  severity: AlertSeverity;
  /** Monetary impact in cents. Larger values are shown first within a severity. */
  impactCents: number;
};

export type AlertPreferences = Record<AlertPreference, boolean>;

const severityPriority: Record<AlertSeverity, number> = {
  critical: 3,
  warning: 2,
  info: 1,
};

/**
 * Selects the most useful alerts for the compact dashboard area.
 *
 * Input is never mutated. Ties keep their original order so callers can use
 * their own deterministic order as a final ranking criterion.
 */
export function selectAlerts(
  alerts: readonly FinancialAlert[],
  preferences: Readonly<AlertPreferences>,
): FinancialAlert[] {
  return alerts
    .map((alert, index) => ({ alert, index }))
    .filter(({ alert }) => preferences[alert.preference])
    .sort(
      (left, right) =>
        severityPriority[right.alert.severity] -
          severityPriority[left.alert.severity] ||
        right.alert.impactCents - left.alert.impactCents ||
        left.index - right.index,
    )
    .slice(0, 3)
    .map(({ alert }) => alert);
}
