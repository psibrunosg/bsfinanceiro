import { SupabaseClient } from '@supabase/supabase-js';
import { describe, it, expect } from 'vitest';
import fs from 'fs';
import path from 'path';
import {
  extractOccurrencesFromParsedInvoices,
  seedClaroCommitments,
  DEFAULT_WORKSPACE_ID,
  DEFAULT_OWNER_ID,
  DEFAULT_CATEGORY_ID,
  ParsedInvoiceRecord,
} from '../seed-claro-commitments';

describe('Seed Claro Commitments', () => {
  const sampleInvoices: ParsedInvoiceRecord[] = [
    {
      filename: 'Fatura de fevereiro.pdf',
      isClaro: true,
      service: 'Claro Telefone Móvel',
      contrato: '53 99189 8309',
      vencimento: '12/02/2026',
      vencimentoIso: '2026-02-12',
      competencia: '2026-02-01',
      valorBase: 59.9,
      valorTotal: 61.0,
    },
    {
      filename: 'Fatura de agosto (1).pdf',
      isClaro: true,
      service: 'Claro Telefone Móvel',
      contrato: '53 99189 8309',
      vencimento: '20/08/2026',
      vencimentoIso: '2026-08-20',
      competencia: '2026-08-01',
      valorBase: 59.9,
      valorTotal: 59.9,
    },
    {
      filename: 'Fatura de agosto (2).pdf',
      isClaro: true,
      service: 'Claro Telefone Móvel',
      contrato: '53 99189 8309',
      vencimento: '20/08/2026',
      vencimentoIso: '2026-08-20',
      competencia: '2026-08-01',
      valorBase: 59.9,
      valorTotal: 59.9,
    },
    {
      filename: 'minha-claro-fatura (4).pdf',
      isClaro: true,
      service: 'Claro Internet Clínica',
      contrato: 'NET 691/398972107',
      vencimento: '20/06/2026',
      vencimentoIso: '2026-06-20',
      competencia: '2026-06-01',
      valorBase: 63.13,
      valorTotal: 63.13,
    },
    {
      filename: 'minha-claro-fatura (6).pdf',
      isClaro: true,
      service: 'Claro Internet Clínica',
      contrato: 'NET 691/398972107',
      vencimento: '20/06/2026',
      vencimentoIso: '2026-06-20',
      competencia: '2026-06-01',
      valorBase: 49.67,
      valorTotal: 49.67,
    },
    {
      filename: 'Cliente-Vendas (1).pdf',
      isClaro: false,
      service: 'Outro',
      contrato: null,
      vencimento: null,
      vencimentoIso: null,
      competencia: null,
      valorBase: null,
      valorTotal: null,
    },
  ];

  describe('extractOccurrencesFromParsedInvoices', () => {
    it('should extract occurrences and deduplicate records by service and month', () => {
      const occurrences = extractOccurrencesFromParsedInvoices(sampleInvoices);

      // Should have 3 occurrences: Móvel Fev, Móvel Ago, Internet Jun
      expect(occurrences).toHaveLength(3);

      const movelFeb = occurrences.find(
        (o) => o.service === 'Claro Telefone Móvel' && o.occurrence_month === '2026-02-01'
      );
      expect(movelFeb).toBeDefined();
      expect(movelFeb?.due_date).toBe('2026-02-12');
      expect(movelFeb?.amount).toBe(61.0);
      expect(movelFeb?.status).toBe('paid');

      const movelAug = occurrences.filter(
        (o) => o.service === 'Claro Telefone Móvel' && o.occurrence_month === '2026-08-01'
      );
      expect(movelAug).toHaveLength(1);
      expect(movelAug[0].amount).toBe(59.9);

      const netJun = occurrences.find(
        (o) => o.service === 'Claro Internet Clínica' && o.occurrence_month === '2026-06-01'
      );
      expect(netJun).toBeDefined();
      expect(netJun?.amount).toBe(63.13); // Picked 63.13 over 49.67
    });

    it('should process the real claro-invoices-parsed.json file correctly', () => {
      const jsonPath = path.resolve(process.cwd(), 'scripts', 'claro-invoices-parsed.json');
      const realInvoices: ParsedInvoiceRecord[] = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));

      const occurrences = extractOccurrencesFromParsedInvoices(realInvoices);

      // 7 months for Móvel (Feb to Aug), 3 months for Internet (May to Jul) = 10 total
      expect(occurrences).toHaveLength(10);

      const movelOccs = occurrences.filter((o) => o.service === 'Claro Telefone Móvel');
      expect(movelOccs).toHaveLength(7);
      expect(movelOccs.map((o) => o.occurrence_month)).toEqual([
        '2026-02-01',
        '2026-03-01',
        '2026-04-01',
        '2026-05-01',
        '2026-06-01',
        '2026-07-01',
        '2026-08-01',
      ]);

      const netOccs = occurrences.filter((o) => o.service === 'Claro Internet Clínica');
      expect(netOccs).toHaveLength(3);
      expect(netOccs.map((o) => o.occurrence_month)).toEqual(['2026-05-01', '2026-06-01', '2026-07-01']);
    });
  });

  describe('seedClaroCommitments', () => {
    
    function createMockSupabase(existingCommitments: Record<string, unknown>[] = [], existingOccurrences: Record<string, unknown>[] = []) {
      const commitmentsState = [...existingCommitments];
      const occurrencesState = [...existingOccurrences];

      return {
        from: (table: string) => {
          if (table === 'fixed_commitments') {
            let filterWorkspace: string | null = null;
            let filterDesc: string | null = null;

            
            const chain: Record<string, unknown> = {
              select: () => chain,
              
              eq: (col: string, val: unknown) => {
                if (col === 'workspace_id') filterWorkspace = val as string;
                if (col === 'description') filterDesc = val as string;
                if (col === 'id') {
                  return {
                    single: () => {
                      const item = commitmentsState.find((c) => c.id === val);
                      return Promise.resolve({ data: item, error: null });
                    },
                  };
                }
                return chain;
              },
              
              update: (updatePayload: Record<string, unknown>) => ({
                
                eq: (col: string, val: unknown) => {
                  const idx = commitmentsState.findIndex((c) => c.id === val);
                  if (idx >= 0) {
                    commitmentsState[idx] = { ...commitmentsState[idx], ...updatePayload };
                  }
                  return Promise.resolve({ error: null });
                },
              }),
              
              insert: (insertPayload: Record<string, unknown>) => ({
                select: () => ({
                  single: () => {
                    const newItem = { id: `fc-${commitmentsState.length + 1}`, ...insertPayload };
                    commitmentsState.push(newItem);
                    return Promise.resolve({ data: newItem, error: null });
                  },
                }),
              }),
              
              then: (resolve: (val: unknown) => void) => {
                const matches = commitmentsState.filter((c) => {
                  if (filterWorkspace && c.workspace_id !== filterWorkspace) return false;
                  if (filterDesc && c.description !== filterDesc) return false;
                  return true;
                });
                resolve({ data: matches, error: null });
              },
            };
            return chain;
          }

          if (table === 'fixed_commitment_occurrences') {
            let filterCommitmentId: string | null = null;
            let filterMonth: string | null = null;

            
            const chain: Record<string, unknown> = {
              select: () => chain,
              
              eq: (col: string, val: unknown) => {
                if (col === 'fixed_commitment_id') filterCommitmentId = val as string;
                if (col === 'occurrence_month') filterMonth = val as string;
                return chain;
              },
              
              update: (updatePayload: Record<string, unknown>) => ({
                
                eq: (col: string, val: unknown) => {
                  const idx = occurrencesState.findIndex((o) => o.id === val);
                  if (idx >= 0) {
                    occurrencesState[idx] = { ...occurrencesState[idx], ...updatePayload };
                  }
                  return Promise.resolve({ error: null });
                },
              }),
              
              insert: (insertPayload: Record<string, unknown>) => ({
                select: () => ({
                  single: () => {
                    const newItem = { id: `occ-${occurrencesState.length + 1}`, ...insertPayload };
                    occurrencesState.push(newItem);
                    return Promise.resolve({ data: newItem, error: null });
                  },
                }),
              }),
              
              then: (resolve: (val: unknown) => void) => {
                const matches = occurrencesState.filter((o) => {
                  if (filterCommitmentId && o.fixed_commitment_id !== filterCommitmentId) return false;
                  if (filterMonth && o.occurrence_month !== filterMonth) return false;
                  return true;
                });
                resolve({ data: matches, error: null });
              },
            };
            return chain;
          }

          throw new Error(`Unexpected table ${table}`);
        },
      };
    }

    it('should create base commitments and occurrences when tables are empty', async () => {
      const mockSupabase = createMockSupabase();

      const result = await seedClaroCommitments((mockSupabase as unknown as SupabaseClient), sampleInvoices, {
        workspaceId: DEFAULT_WORKSPACE_ID,
        ownerId: DEFAULT_OWNER_ID,
        categoryId: DEFAULT_CATEGORY_ID,
      });

      expect(result.commitmentsCreated).toBe(2);
      expect(result.commitmentsUpdated).toBe(0);
      expect(result.occurrencesCreated).toBe(3);
      expect(result.occurrencesUpdated).toBe(0);
      expect(result.commitments).toHaveLength(2);
      expect(result.occurrences).toHaveLength(3);
    });

    it('should be idempotent and update existing records on re-run', async () => {
      const mockSupabase = createMockSupabase();

      // First run
      const result1 = await seedClaroCommitments((mockSupabase as unknown as SupabaseClient), sampleInvoices);
      expect(result1.commitmentsCreated).toBe(2);
      expect(result1.occurrencesCreated).toBe(3);

      // Second run (re-run)
      const result2 = await seedClaroCommitments((mockSupabase as unknown as SupabaseClient), sampleInvoices);
      expect(result2.commitmentsCreated).toBe(0);
      expect(result2.commitmentsUpdated).toBe(2);
      expect(result2.occurrencesCreated).toBe(0);
      expect(result2.occurrencesUpdated).toBe(3);
    });
  });
});
