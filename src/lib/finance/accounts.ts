/**
 * Accounts management, classification (PJ vs PF), validation and seeding helpers.
 */

export type BankAccountType = 'checking' | 'cash' | 'savings' | 'credit_card' | 'investment';

export type AccountScope = 'pj' | 'pf' | 'other';

export interface BankAccount {
  id?: string;
  workspace_id: string;
  owner_id: string;
  name: string;
  type: BankAccountType;
  initial_balance: number;
  active: boolean;
  is_system?: boolean;
  created_at?: string;
}

export interface BankAccountSpec {
  name: string;
  type: BankAccountType;
  initial_balance: number;
  active: boolean;
  is_system: boolean;
  scope: AccountScope;
}

export const DEFAULT_WORKSPACE_ID = '4244e4ad-d527-4b98-84b8-6333d04a6ee4';
export const DEFAULT_OWNER_ID = '68f89053-fd7b-4803-826e-b01f1847265e';

export const SEED_BANK_ACCOUNTS: BankAccountSpec[] = [
  {
    name: 'Conta Corrente PJ - Clínica',
    type: 'checking',
    initial_balance: 0.0,
    active: true,
    is_system: false,
    scope: 'pj',
  },
  {
    name: 'Conta Corrente PF - Bruno CPF',
    type: 'checking',
    initial_balance: 0.0,
    active: true,
    is_system: false,
    scope: 'pf',
  },
  {
    name: 'Banco Santander',
    type: 'checking',
    initial_balance: 0.0,
    active: true,
    is_system: false,
    scope: 'pf',
  },
];

const PJ_KEYWORDS = ['pj', 'clínica', 'clinica', 'empresa', 'cnpj', 'ltda', 'sociedade'];
const PF_KEYWORDS = ['pf', 'cpf', 'bruno', 'pessoal', 'física', 'fisica', 'santander'];

/**
 * Classifies an account scope as 'pj', 'pf', or 'other' based on account name or object.
 */
export function classifyAccountScope(accountOrName: string | { name: string }): AccountScope {
  const name = typeof accountOrName === 'string' ? accountOrName : accountOrName.name || '';
  const lowerName = name.toLowerCase();

  for (const kw of PJ_KEYWORDS) {
    if (lowerName.includes(kw)) {
      return 'pj';
    }
  }

  for (const kw of PF_KEYWORDS) {
    if (lowerName.includes(kw)) {
      return 'pf';
    }
  }

  return 'other';
}

export function isPJAccount(accountOrName: string | { name: string }): boolean {
  return classifyAccountScope(accountOrName) === 'pj';
}

export function isPFAccount(accountOrName: string | { name: string }): boolean {
  return classifyAccountScope(accountOrName) === 'pf';
}

const VALID_ACCOUNT_TYPES: Set<string> = new Set([
  'checking',
  'cash',
  'savings',
  'credit_card',
  'investment',
]);

const CASH_ACCOUNT_TYPES: Set<string> = new Set(['checking', 'cash', 'savings']);

export function isCashAccountType(type: string): boolean {
  return CASH_ACCOUNT_TYPES.has(type);
}

export function validateBankAccount(account: Partial<BankAccount>): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (!account.name || typeof account.name !== 'string' || account.name.trim().length === 0) {
    errors.push('Nome da conta é obrigatório.');
  }

  if (!account.type || !VALID_ACCOUNT_TYPES.has(account.type)) {
    errors.push(
      `Tipo de conta inválido: "${account.type}". Tipos permitidos: checking, cash, savings, credit_card, investment.`
    );
  }

  if (
    account.initial_balance === undefined ||
    account.initial_balance === null ||
    typeof account.initial_balance !== 'number' ||
    isNaN(account.initial_balance)
  ) {
    errors.push('Saldo inicial deve ser um número válido.');
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

export function filterAccountsByScope<T extends { name: string }>(
  accounts: T[],
  scope: AccountScope
): T[] {
  return accounts.filter((acc) => classifyAccountScope(acc.name) === scope);
}

export function formatAccountBalance(balance: number): string {
  const safeBalance = isNaN(balance) ? 0 : balance;
  return safeBalance.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}

export interface SeedAccountsResult {
  createdCount: number;
  updatedCount: number;
  existingCount: number;
  accounts: Array<{
    id: string;
    name: string;
    type: string;
    initial_balance: number;
    active: boolean;
    is_system: boolean;
    scope: AccountScope;
  }>;
}

export async function seedBankAccounts(
  supabase: any,
  options?: {
    workspaceId?: string;
    ownerId?: string;
    seedSpecs?: BankAccountSpec[];
  }
): Promise<SeedAccountsResult> {
  const workspaceId = options?.workspaceId ?? DEFAULT_WORKSPACE_ID;
  const ownerId = options?.ownerId ?? DEFAULT_OWNER_ID;
  const specs = options?.seedSpecs ?? SEED_BANK_ACCOUNTS;

  let createdCount = 0;
  let updatedCount = 0;
  let existingCount = 0;

  const { data: existingAccounts, error: fetchErr } = await supabase
    .from('accounts')
    .select('id, name, type, initial_balance, active, is_system')
    .eq('workspace_id', workspaceId);

  if (fetchErr) {
    throw fetchErr;
  }

  const existingMap = new Map<string, any>();
  if (existingAccounts) {
    for (const acc of existingAccounts) {
      existingMap.set(acc.name.trim().toLowerCase(), acc);
    }
  }

  const resultAccounts: SeedAccountsResult['accounts'] = [];

  for (const spec of specs) {
    const key = spec.name.trim().toLowerCase();
    const existing = existingMap.get(key);

    if (existing) {
      let needsUpdate = false;
      const updates: Record<string, any> = {};

      if (existing.type !== spec.type) {
        updates.type = spec.type;
        needsUpdate = true;
      }
      if (existing.active !== spec.active) {
        updates.active = spec.active;
        needsUpdate = true;
      }
      if (existing.is_system !== spec.is_system) {
        updates.is_system = spec.is_system;
        needsUpdate = true;
      }

      if (needsUpdate) {
        const { error: updateErr } = await supabase
          .from('accounts')
          .update(updates)
          .eq('id', existing.id);

        if (updateErr) throw updateErr;
        updatedCount++;
      } else {
        existingCount++;
      }

      resultAccounts.push({
        id: existing.id,
        name: existing.name,
        type: updates.type ?? existing.type,
        initial_balance: Number(existing.initial_balance),
        active: updates.active ?? existing.active,
        is_system: updates.is_system ?? existing.is_system ?? false,
        scope: classifyAccountScope(existing.name),
      });
    } else {
      const newAccountPayload = {
        workspace_id: workspaceId,
        owner_id: ownerId,
        name: spec.name,
        type: spec.type,
        initial_balance: spec.initial_balance,
        active: spec.active,
        is_system: spec.is_system,
      };

      const { data: inserted, error: insertErr } = await supabase
        .from('accounts')
        .insert(newAccountPayload)
        .select('id, name, type, initial_balance, active, is_system')
        .single();

      if (insertErr) throw insertErr;

      createdCount++;
      resultAccounts.push({
        id: inserted.id,
        name: inserted.name,
        type: inserted.type,
        initial_balance: Number(inserted.initial_balance),
        active: inserted.active,
        is_system: inserted.is_system ?? false,
        scope: classifyAccountScope(inserted.name),
      });
    }
  }

  return {
    createdCount,
    updatedCount,
    existingCount,
    accounts: resultAccounts,
  };
}
