import { describe, it, expect } from 'vitest';
import {
  classifyAccountScope,
  isPJAccount,
  isPFAccount,
  validateBankAccount,
  filterAccountsByScope,
  formatAccountBalance,
  isCashAccountType,
  seedBankAccounts,
  DEFAULT_WORKSPACE_ID,
  DEFAULT_OWNER_ID,
} from '../accounts';

describe('Accounts Module (PJ / PF & Seeding)', () => {
  describe('Scope Classification (PJ vs PF)', () => {
    it('should classify PJ accounts correctly based on name keywords', () => {
      expect(classifyAccountScope('Conta Corrente PJ - Clínica')).toBe('pj');
      expect(classifyAccountScope('Empresa Ltda')).toBe('pj');
      expect(classifyAccountScope('Conta CNPJ')).toBe('pj');
      expect(classifyAccountScope('Sociedade Médica')).toBe('pj');
      expect(classifyAccountScope({ name: 'Clínica Odontológica' })).toBe('pj');
    });

    it('should classify PF accounts correctly based on name keywords', () => {
      expect(classifyAccountScope('Conta Corrente PF - Bruno CPF')).toBe('pf');
      expect(classifyAccountScope('Banco Santander')).toBe('pf');
      expect(classifyAccountScope('Conta Pessoal')).toBe('pf');
      expect(classifyAccountScope('CPF Bruno')).toBe('pf');
      expect(classifyAccountScope({ name: 'Bruno Guimarães' })).toBe('pf');
    });

    it('should return "other" for unrecognized generic names', () => {
      expect(classifyAccountScope('Reserva Especial')).toBe('other');
      expect(classifyAccountScope('')).toBe('other');
    });

    it('should provide isPJAccount and isPFAccount predicate helpers', () => {
      expect(isPJAccount('Conta Corrente PJ - Clínica')).toBe(true);
      expect(isPJAccount('Banco Santander')).toBe(false);

      expect(isPFAccount('Banco Santander')).toBe(true);
      expect(isPFAccount('Conta Corrente PJ - Clínica')).toBe(false);
    });

    it('should filter an array of accounts by scope', () => {
      const accounts = [
        { name: 'Conta Corrente PJ - Clínica' },
        { name: 'Conta Corrente PF - Bruno CPF' },
        { name: 'Banco Santander' },
        { name: 'Empresa XPTO' },
      ];

      const pjList = filterAccountsByScope(accounts, 'pj');
      expect(pjList).toHaveLength(2);
      expect(pjList.map((a) => a.name)).toEqual(['Conta Corrente PJ - Clínica', 'Empresa XPTO']);

      const pfList = filterAccountsByScope(accounts, 'pf');
      expect(pfList).toHaveLength(2);
      expect(pfList.map((a) => a.name)).toEqual(['Conta Corrente PF - Bruno CPF', 'Banco Santander']);
    });
  });

  describe('Account Helpers & Validation', () => {
    it('should validate valid bank accounts', () => {
      const validAccount = {
        name: 'Conta Corrente PJ - Clínica',
        type: 'checking' as const,
        initial_balance: 0,
      };

      const result = validateBankAccount(validAccount);
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject invalid account fields', () => {
      const resultEmptyName = validateBankAccount({ name: '   ', type: 'checking', initial_balance: 0 });
      expect(resultEmptyName.valid).toBe(false);
      expect(resultEmptyName.errors).toContain('Nome da conta é obrigatório.');

      const resultInvalidType = validateBankAccount({
        name: 'Conta',
        type: 'crypto' as unknown as BankAccountType,
        initial_balance: 0,
      });
      expect(resultInvalidType.valid).toBe(false);
      expect(resultInvalidType.errors[0]).toContain('Tipo de conta inválido');

      const resultInvalidBalance = validateBankAccount({
        name: 'Conta',
        type: 'checking',
        initial_balance: NaN,
      });
      expect(resultInvalidBalance.valid).toBe(false);
      expect(resultInvalidBalance.errors).toContain('Saldo inicial deve ser um número válido.');
    });

    it('should identify cash account types correctly', () => {
      expect(isCashAccountType('checking')).toBe(true);
      expect(isCashAccountType('cash')).toBe(true);
      expect(isCashAccountType('savings')).toBe(true);

      expect(isCashAccountType('credit_card')).toBe(false);
      expect(isCashAccountType('investment')).toBe(false);
    });

    it('should format currency balance correctly in BRL', () => {
      const formatted0 = formatAccountBalance(0);
      expect(formatted0).toContain('0,00');

      const formatted1500 = formatAccountBalance(1500.5);
      expect(formatted1500).toContain('1.500,50');
    });
  });

  describe('seedBankAccounts Seeder Logic (Idempotent)', () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    function createMockSupabase(initialDbAccounts: any[] = []) {
      const dbAccounts = [...initialDbAccounts];

      return {
        from: (table: string) => {
          if (table !== 'accounts') {
            throw new Error(`Unexpected table ${table}`);
          }

          let filterWorkspaceId: string | null = null;

          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          const chain: any = {
            select: () => chain,
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            eq: (col: string, val: any) => {
              if (col === 'workspace_id') filterWorkspaceId = val;
              return chain;
            },
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            update: (updates: any) => ({
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              eq: (col: string, val: any) => {
                const idx = dbAccounts.findIndex((a) => a.id === val);
                if (idx >= 0) {
                  dbAccounts[idx] = { ...dbAccounts[idx], ...updates };
                }
                return Promise.resolve({ error: null });
              },
            }),
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            insert: (payload: any) => ({
              select: () => ({
                single: () => {
                  const newRow = { id: `acc-${dbAccounts.length + 1}`, ...payload };
                  dbAccounts.push(newRow);
                  return Promise.resolve({ data: newRow, error: null });
                },
              }),
            }),
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            then: (resolve: any) => {
              const matched = dbAccounts.filter(
                (a) => !filterWorkspaceId || a.workspace_id === filterWorkspaceId
              );
              resolve({ data: matched, error: null });
            },
          };

          return chain;
        },
      };
    }

    it('should create all target bank accounts when database is empty', async () => {
      const mockSupabase = createMockSupabase([]);

      const result = await seedBankAccounts(mockSupabase, {
        workspaceId: DEFAULT_WORKSPACE_ID,
        ownerId: DEFAULT_OWNER_ID,
      });

      expect(result.createdCount).toBe(3);
      expect(result.updatedCount).toBe(0);
      expect(result.existingCount).toBe(0);
      expect(result.accounts).toHaveLength(3);

      const pjAcc = result.accounts.find((a) => a.name === 'Conta Corrente PJ - Clínica');
      expect(pjAcc).toBeDefined();
      expect(pjAcc?.scope).toBe('pj');
      expect(pjAcc?.type).toBe('checking');

      const pfAcc = result.accounts.find((a) => a.name === 'Conta Corrente PF - Bruno CPF');
      expect(pfAcc).toBeDefined();
      expect(pfAcc?.scope).toBe('pf');

      const santander = result.accounts.find((a) => a.name === 'Banco Santander');
      expect(santander).toBeDefined();
      expect(santander?.scope).toBe('pf');
    });

    it('should be idempotent and preserve existing accounts on second run', async () => {
      // Simulate Banco Santander already existing in DB
      const existingSantander = {
        id: 'e4ddae7c-2b28-444f-a9cb-b203a9856f8f',
        workspace_id: DEFAULT_WORKSPACE_ID,
        owner_id: DEFAULT_OWNER_ID,
        name: 'Banco Santander',
        type: 'checking',
        initial_balance: 5000,
        active: true,
        is_system: false,
      };

      const mockSupabase = createMockSupabase([existingSantander]);

      // First run: Santander exists, PJ and PF need to be created
      const run1 = await seedBankAccounts(mockSupabase);
      expect(run1.createdCount).toBe(2);
      expect(run1.existingCount).toBe(1);

      const santanderInRun1 = run1.accounts.find((a) => a.name === 'Banco Santander');
      expect(santanderInRun1?.initial_balance).toBe(5000);

      // Second run: All 3 accounts already exist
      const run2 = await seedBankAccounts(mockSupabase);
      expect(run2.createdCount).toBe(0);
      expect(run2.updatedCount).toBe(0);
      expect(run2.existingCount).toBe(3);
      expect(run2.accounts).toHaveLength(3);
    });

    it('should update mismatched fields if account exists with outdated properties', async () => {
      const outdatedAcc = {
        id: 'acc-pj-old',
        workspace_id: DEFAULT_WORKSPACE_ID,
        owner_id: DEFAULT_OWNER_ID,
        name: 'Conta Corrente PJ - Clínica',
        type: 'savings', // Outdated type
        initial_balance: 0,
        active: false, // Outdated active
        is_system: false,
      };

      const mockSupabase = createMockSupabase([outdatedAcc]);

      const result = await seedBankAccounts(mockSupabase, {
        seedSpecs: [
          {
            name: 'Conta Corrente PJ - Clínica',
            type: 'checking',
            initial_balance: 0,
            active: true,
            is_system: false,
            scope: 'pj',
          },
        ],
      });

      expect(result.updatedCount).toBe(1);
      expect(result.accounts[0].type).toBe('checking');
      expect(result.accounts[0].active).toBe(true);
    });
  });
});
