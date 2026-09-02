import { generateAllAlerts } from "@/lib/finance/alert-generator";
import { selectAlerts, type AlertPreferences } from "@/lib/finance/alerts";
import { CircleAlert, Info, TriangleAlert, BellRing } from "lucide-react";
import Link from "next/link";

type Account = { id: string; name: string; initial_balance: number };
type Transaction = { id: string; amount: number; type: string; category_id?: string | null; competence_date: string; status?: string };
type Invoice = { id: string; due_date: string; status: string; credit_card_installments?: { amount: number }[] | null };
type Occurrence = { id: string; description: string; amount: number; due_date: string; status: string };
type Goal = { id: string; name: string; target_amount: number; current_amount: number };
type Budget = { id: string; category_id: string; amount: number };

import type { AlertPreference } from "./types";

type Props = {
  accounts: Account[];
  transactions: Transaction[];
  invoices: Invoice[];
  occurrences: Occurrence[];
  goals: Goal[];
  budgets: Budget[];
  preferences: AlertPreference | null;
};

const DEFAULT_PREFS: AlertPreferences = {
  budget: true,
  cashflow: true,
  invoice: true,
  goal: true,
  recurring: true,
};

export function AlertsWidget({ 
  accounts = [], 
  transactions = [], 
  invoices = [], 
  occurrences = [], 
  goals = [], 
  budgets = [], 
  preferences 
}: Props) {
  const currentDate = new Date();
  const allAlerts = generateAllAlerts(accounts, transactions, invoices, occurrences, goals, budgets, currentDate);
  
  // Use user preferences or default to all enabled
  const activePrefs: AlertPreferences = preferences ? {
    budget: preferences.budget_alerts !== false,
    cashflow: true, // We don't have this in DB yet
    invoice: preferences.credit_card_alerts !== false,
    goal: preferences.goal_alerts !== false,
    recurring: preferences.fixed_commitment_alerts !== false,
  } : DEFAULT_PREFS;
  const topAlerts = selectAlerts(allAlerts, activePrefs);

  if (topAlerts.length === 0) return (
    <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '16px' }}>
      <button 
        onClick={() => typeof Notification !== 'undefined' && Notification.requestPermission()}
        className="button button-outline"
        style={{ fontSize: '0.8rem', padding: '6px 12px' }}
      >
        <BellRing size={14} style={{ marginRight: '6px' }} /> Ativar Notificações
      </button>
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h3 style={{ margin: 0, fontSize: '1.2rem' }}>Avisos Inteligentes</h3>
        <button 
          onClick={() => typeof Notification !== 'undefined' && Notification.requestPermission()}
          className="button button-ghost"
          style={{ fontSize: '0.8rem', padding: '6px 12px' }}
        >
          <BellRing size={14} style={{ marginRight: '6px' }} /> Notificações Push
        </button>
      </div>
      {topAlerts.map(alert => (
        <div key={alert.id} className="dashboard-card" style={{ 
          display: 'flex', 
          alignItems: 'flex-start', 
          gap: '12px', 
          padding: '16px',
          borderLeft: `4px solid ${alert.severity === 'critical' ? '#E11D48' : alert.severity === 'warning' ? '#F5A623' : '#3B82F6'}`
        }}>
          <div style={{ marginTop: '2px', color: alert.severity === 'critical' ? '#E11D48' : alert.severity === 'warning' ? '#F5A623' : '#3B82F6' }}>
            {alert.severity === 'critical' ? <CircleAlert size={20} /> : alert.severity === 'warning' ? <TriangleAlert size={20} /> : <Info size={20} />}
          </div>
          <div style={{ flex: 1 }}>
            <h4 style={{ margin: '0 0 4px 0', fontSize: '1rem', display: 'flex', alignItems: 'center', gap: '6px' }}>
              {alert.title}
              {alert.severity === 'info' && <BellRing size={14} className="muted" />}
            </h4>
            <p className="muted" style={{ margin: 0, fontSize: '0.9rem' }}>{alert.message}</p>
          </div>
          {alert.actionUrl && (
            <Link href={alert.actionUrl} style={{ fontSize: '0.85rem', fontWeight: 500, color: 'var(--accent)', textDecoration: 'none' }}>
              Ver mais
            </Link>
          )}
        </div>
      ))}
    </div>
  );
}
