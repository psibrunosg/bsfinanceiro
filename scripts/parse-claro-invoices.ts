import fs from 'fs';
import path from 'path';
import { parseClaroInvoicesFromDir } from '../src/lib/finance/parse-claro-invoices';

const DRIVE_DIR = 'G:\\Meu Drive\\n';
const OUTPUT_FILE = path.join(__dirname, 'claro-invoices-parsed.json');

async function main() {
  console.log(`Reading files from ${DRIVE_DIR}...`);
  const results = await parseClaroInvoicesFromDir(DRIVE_DIR);

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2), 'utf-8');
  console.log(`Saved ${results.length} parsed records to ${OUTPUT_FILE}`);

  const claroRecords = results.filter(r => r.isClaro);
  const movelRecords = claroRecords.filter(r => r.service === 'Claro Telefone Móvel');
  const netRecords = claroRecords.filter(r => r.service === 'Claro Internet Clínica');
  const outrosRecords = results.filter(r => !r.isClaro);

  console.log(`\n--- Summary ---`);
  console.log(`Total Files: ${results.length}`);
  console.log(`Claro Invoices: ${claroRecords.length}`);
  console.log(` - Claro Telefone Móvel (53 99189 8309): ${movelRecords.length}`);
  console.log(` - Claro Internet Clínica (NET 691/398972107): ${netRecords.length}`);
  console.log(`Other Files (Non-Claro): ${outrosRecords.length}`);
}

main().catch(err => {
  console.error('Error running parser script:', err);
  process.exit(1);
});
