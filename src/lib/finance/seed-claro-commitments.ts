import { SupabaseClient } from "@supabase/supabase-js";


export interface ParsedInvoiceRecord {
  filename: string;
  isClaro: boolean;
  service: string;
  contrato: string | null;
  vencimento: string | null;
  vencimentoIso: string | null;
  competencia: string | null;
  valorBase: number | null;
  valorTotal: number | null;
}

export interface CommitmentSpec {
  service: string;
  description: string;
  amount: number;
  due_day: number;
  recurrence: 'monthly';
  type: 'expense';
}

export const DEFAULT_WORKSPACE_ID = '4244e4ad-d527-4b98-84b8-6333d04a6ee4';
export const DEFAULT_OWNER_ID = '68f89053-fd7b-4803-826e-b01f1847265e';
export const DEFAULT_CATEGORY_ID = 'b65240de-9de5-4110-aa19-feaa88f613ef';

export const CLARO_COMMITMENT_SPECS: CommitmentSpec[] = [
  {
    service: 'Claro Telefone Móvel',
    description: 'Claro Telefone Móvel (53 99189 8309)',
    amount: 59.90,
    due_day: 20,
    recurrence: 'monthly',
    type: 'expense',
  },
  {
    service: 'Claro Internet Clínica',
    description: 'Claro Internet Clínica (NET 691/398972107)',
    amount: 84.11,
    due_day: 20,
    recurrence: 'monthly',
    type: 'expense',
  },
];

export interface ExtractedOccurrence {
  service: string;
  occurrence_month: string;
  due_date: string;
  description: string;
  amount: number;
  status: 'paid';
  paid_at: string;
  idempotency_key: string;
}

// Generate deterministic UUID for idempotency
export function generateDeterministicUuid(seed: string): string {
  let hash = 0;
  for (let i = 0; i < seed.length; i++) {
    const char = seed.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  const hex = Math.abs(hash).toString(16).padStart(8, '0');
  return `${hex.slice(0, 8)}-0000-4000-8000-000000000000`;
}

export function extractOccurrencesFromParsedInvoices(
  invoices: ParsedInvoiceRecord[]
): ExtractedOccurrence[] {
  const claroInvoices = invoices.filter(
    (inv) => inv.isClaro && inv.competencia && inv.vencimentoIso && inv.valorTotal != null
  );

  // Group by service + competencia to handle duplicates
  const map = new Map<string, ParsedInvoiceRecord>();

  for (const inv of claroInvoices) {
    const key = `${inv.service}::${inv.competencia}`;
    if (!map.has(key)) {
      map.set(key, inv);
    } else {
      // Pick higher amount (e.g. original invoice 63.13 over reemission 49.67)
      const existing = map.get(key)!;
      if ((inv.valorTotal ?? 0) > (existing.valorTotal ?? 0)) {
        map.set(key, inv);
      }
    }
  }

  const occurrences: ExtractedOccurrence[] = [];

  for (const inv of map.values()) {
    const spec = CLARO_COMMITMENT_SPECS.find((s) => s.service === inv.service);
    if (!spec) continue;

    const seed = `${inv.service}_${inv.competencia}`;
    const idempotencyKey = generateDeterministicUuid(seed);

    occurrences.push({
      service: inv.service,
      occurrence_month: inv.competencia!,
      due_date: inv.vencimentoIso!,
      description: spec.description,
      amount: inv.valorTotal!,
      status: 'paid',
      paid_at: inv.vencimentoIso!,
      idempotency_key: idempotencyKey,
    });
  }

  // Sort by service, then occurrence_month
  occurrences.sort((a, b) => {
    if (a.service !== b.service) return a.service.localeCompare(b.service);
    return a.occurrence_month.localeCompare(b.occurrence_month);
  });

  return occurrences;
}

export interface SeedResult {
  commitmentsCreated: number;
  commitmentsUpdated: number;
  occurrencesCreated: number;
  occurrencesUpdated: number;
  commitments: Array<{ id: string; description: string }>;
  occurrences: Array<{ id: string; month: string; description: string; amount: number }>;
}

export async function seedClaroCommitments(
  supabase: SupabaseClient,
  invoices: ParsedInvoiceRecord[],
  options?: {
    workspaceId?: string;
    ownerId?: string;
    categoryId?: string;
    accountId?: string;
  }
): Promise<SeedResult> {
  const workspaceId = options?.workspaceId ?? DEFAULT_WORKSPACE_ID;
  const ownerId = options?.ownerId ?? DEFAULT_OWNER_ID;
  const categoryId = options?.categoryId ?? DEFAULT_CATEGORY_ID;
  const accountId = options?.accountId;

  let commitmentsCreated = 0;
  let commitmentsUpdated = 0;
  let occurrencesCreated = 0;
  let occurrencesUpdated = 0;

  const commitmentMap = new Map<string, string>();
  const resultCommitments: Array<{ id: string; description: string }> = [];

  // 1. Process base commitments
  for (const spec of CLARO_COMMITMENT_SPECS) {
    const { data: existingRows, error: searchError } = await supabase
      .from('fixed_commitments')
      .select('id, amount, due_day, category_id, active')
      .eq('workspace_id', workspaceId)
      .eq('description', spec.description);

    if (searchError) throw searchError;

    let commitmentId: string;

    if (existingRows && existingRows.length > 0) {
      commitmentId = existingRows[0].id;
      const { error: updateError } = await supabase
        .from('fixed_commitments')
        .update({
          amount: spec.amount,
          due_day: spec.due_day,
          category_id: categoryId,
          active: true,
        })
        .eq('id', commitmentId);

      if (updateError) throw updateError;
      commitmentsUpdated++;
    } else {
      const { data: inserted, error: insertError } = await supabase
        .from('fixed_commitments')
        .insert({
          workspace_id: workspaceId,
          owner_id: ownerId,
          category_id: categoryId,
          description: spec.description,
          amount: spec.amount,
          due_day: spec.due_day,
          active: true,
        })
        .select('id')
        .single();

      if (insertError) throw insertError;
      commitmentId = inserted.id;
      commitmentsCreated++;
    }

    commitmentMap.set(spec.service, commitmentId);
    resultCommitments.push({ id: commitmentId, description: spec.description });
  }

  // 2. Process occurrences from parsed JSON
  const extractedOccurrences = extractOccurrencesFromParsedInvoices(invoices);
  const resultOccurrences: Array<{ id: string; month: string; description: string; amount: number }> = [];

  for (const occ of extractedOccurrences) {
    const commitmentId = commitmentMap.get(occ.service);
    if (!commitmentId) continue;

    let paymentTxId: string | null = null;

    if (occ.status === 'paid' && accountId) {
      // Find or insert transaction for this paid occurrence
      const { data: existingTx } = await supabase
        .from('transactions')
        .select('id')
        .eq('workspace_id', workspaceId)
        .eq('idempotency_key', occ.idempotency_key);

      if (existingTx && existingTx.length > 0) {
        paymentTxId = existingTx[0].id;
      } else {
        const { data: newTx, error: txErr } = await supabase
          .from('transactions')
          .insert({
            workspace_id: workspaceId,
            owner_id: ownerId,
            account_id: accountId,
            category_id: categoryId,
            type: 'expense',
            status: 'paid',
            description: occ.description,
            amount: occ.amount,
            competence_date: occ.due_date,
            paid_at: occ.paid_at,
            notes: 'Carga de faturas Claro',
            idempotency_key: occ.idempotency_key,
          })
          .select('id')
          .single();

        if (!txErr && newTx) {
          paymentTxId = newTx.id;
        }
      }
    }

    const { data: existingOccs, error: occSearchErr } = await supabase
      .from('fixed_commitment_occurrences')
      .select('id')
      .eq('fixed_commitment_id', commitmentId)
      .eq('occurrence_month', occ.occurrence_month);

    if (occSearchErr) throw occSearchErr;

    let occId: string;

    const occPayload: Record<string, unknown> = {
      due_date: occ.due_date,
      description: occ.description,
      amount: occ.amount,
      status: occ.status,
      paid_at: occ.paid_at,
    };

    if (paymentTxId) {
      occPayload.payment_transaction_id = paymentTxId;
      occPayload.payment_idempotency_key = occ.idempotency_key;
    }

    if (existingOccs && existingOccs.length > 0) {
      occId = existingOccs[0].id;
      const { error: occUpdErr } = await supabase
        .from('fixed_commitment_occurrences')
        .update(occPayload)
        .eq('id', occId);

      if (occUpdErr) throw occUpdErr;
      occurrencesUpdated++;
    } else {
      const { data: insertedOcc, error: occInsErr } = await supabase
        .from('fixed_commitment_occurrences')
        .insert({
          workspace_id: workspaceId,
          owner_id: ownerId,
          fixed_commitment_id: commitmentId,
          occurrence_month: occ.occurrence_month,
          ...occPayload,
        })
        .select('id')
        .single();

      if (occInsErr) throw occInsErr;
      occId = insertedOcc.id;
      occurrencesCreated++;
    }

    resultOccurrences.push({
      id: occId,
      month: occ.occurrence_month,
      description: occ.description,
      amount: occ.amount,
    });
  }

  return {
    commitmentsCreated,
    commitmentsUpdated,
    occurrencesCreated,
    occurrencesUpdated,
    commitments: resultCommitments,
    occurrences: resultOccurrences,
  };
}
