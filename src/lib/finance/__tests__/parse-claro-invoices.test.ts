import fs from 'fs';
import path from 'path';
import { describe, expect, it } from 'vitest';
import { ClaroInvoiceRecord, parseClaroInvoicesFromDir } from '../parse-claro-invoices';

const PARSED_JSON_PATH = path.join(process.cwd(), 'scripts', 'claro-invoices-parsed.json');
const DRIVE_DIR = 'G:\\Meu Drive\\n';

describe('Claro Invoices Parser', () => {
  it('should have generated scripts/claro-invoices-parsed.json with 20 records', () => {
    expect(fs.existsSync(PARSED_JSON_PATH)).toBe(true);
    const content = fs.readFileSync(PARSED_JSON_PATH, 'utf-8');
    const records: ClaroInvoiceRecord[] = JSON.parse(content);

    expect(records.length).toBe(20);
  });

  it('should categorize records into Claro Telefone Móvel, Claro Internet Clínica, and Outro', () => {
    const content = fs.readFileSync(PARSED_JSON_PATH, 'utf-8');
    const records: ClaroInvoiceRecord[] = JSON.parse(content);

    const claroRecords = records.filter(r => r.isClaro);
    const movelRecords = records.filter(r => r.service === 'Claro Telefone Móvel');
    const netRecords = records.filter(r => r.service === 'Claro Internet Clínica');
    const outrosRecords = records.filter(r => !r.isClaro);

    expect(claroRecords.length).toBe(14);
    expect(movelRecords.length).toBe(9);
    expect(netRecords.length).toBe(5);
    expect(outrosRecords.length).toBe(6);

    // Verify contract numbers
    movelRecords.forEach(r => {
      expect(r.contrato).toBe('53 99189 8309');
      expect(r.vencimento).not.toBeNull();
      expect(r.valorTotal).toBeGreaterThan(0);
    });

    netRecords.forEach(r => {
      expect(r.contrato).toBe('NET 691/398972107');
      expect(r.vencimento).not.toBeNull();
      expect(r.valorTotal).toBeGreaterThan(0);
    });

    outrosRecords.forEach(r => {
      expect(r.isClaro).toBe(false);
      expect(r.contrato).toBeNull();
      expect(r.vencimento).toBeNull();
    });
  });

  it('should cover competency months from 2026-02 to 2026-08', () => {
    const content = fs.readFileSync(PARSED_JSON_PATH, 'utf-8');
    const records: ClaroInvoiceRecord[] = JSON.parse(content);

    const claroRecords = records.filter(r => r.isClaro);
    const competencias = new Set(claroRecords.map(r => r.competencia));

    const expectedMonths = [
      '2026-02-01',
      '2026-03-01',
      '2026-04-01',
      '2026-05-01',
      '2026-06-01',
      '2026-07-01',
      '2026-08-01',
    ];

    expectedMonths.forEach(m => {
      expect(competencias.has(m)).toBe(true);
    });
  });

  it('should parse real Drive directory dynamically if directory exists', async () => {
    if (!fs.existsSync(DRIVE_DIR)) {
      console.log('Skipping live drive test: Drive directory not found');
      return;
    }

    const records = await parseClaroInvoicesFromDir(DRIVE_DIR);
    expect(records.length).toBe(20);

    const claroRecords = records.filter(r => r.isClaro);
    expect(claroRecords.length).toBe(14);
  });
});
