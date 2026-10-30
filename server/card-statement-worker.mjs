import { readFile } from 'node:fs/promises';
import { extractSelectablePdfText } from './pdf-text.mjs';
import { parseSantanderStatement } from './santander-statement.mjs';

try {
  const bytes = new Uint8Array(await readFile(process.argv[2]));
  if (!bytes.length || bytes.length > 5242880) throw new Error('pdf_too_large');
  const text = process.argv[3] === 'application/pdf'
    ? (await extractSelectablePdfText(bytes)).text : new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  console.log(JSON.stringify(await parseSantanderStatement(text)));
} catch (error) {
  const codes = ['pdf_too_large', 'pdf_too_many_pages', 'pdf_without_selectable_text', 'invalid_pdf', 'unsupported_layout', 'ambiguous_financial_fields'];
  console.log(JSON.stringify({ error: codes.includes(error?.message) ? error.message : 'processing_failed' }));
  process.exitCode = 1;
}
