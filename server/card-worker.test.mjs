import { describe, expect, it } from 'vitest';
import { parseSantanderStatement as native } from './santander-statement.mjs';
import { parseSantanderStatement as original } from '../supabase/functions/_shared/santander-statement.ts';
import { extractSelectablePdfText } from './pdf-text.mjs';
import { textualPdfWithText } from '../supabase/functions/_shared/pdf-test-fixture.ts';
const statement = `Esta é a fatura do seu cartão SANTANDER
Total a Pagar R$ 23,45
VENCIMENTO 22/08/2026
Compras e pagamentos realizados até 15/08/2026
Lançamentos
10/08 MERCADO EXEMPLO R$ 23,45
Limites`;
describe('VPS document worker parser compatibility', () => {
  it('keeps original parser results and fingerprints unchanged', async () => {
    expect(await native(statement)).toEqual(await original(statement));
  });
  it('extracts selectable PDF text with the preserved PDF safety checks', async () => {
    const bytes = textualPdfWithText('Esta e a fatura do seu cartao SANTANDER');
    const result = await extractSelectablePdfText(bytes);
    expect(result.text).toContain('SANTANDER');
    await expect(extractSelectablePdfText(new TextEncoder().encode('not pdf'))).rejects.toThrow('invalid_pdf');
  });
});
