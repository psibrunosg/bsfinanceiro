import fs from 'fs';
import path from 'path';
import { createClient } from '@supabase/supabase-js';
import {
  seedClaroCommitments,
  DEFAULT_WORKSPACE_ID,
  DEFAULT_OWNER_ID,
  DEFAULT_CATEGORY_ID,
  ParsedInvoiceRecord,
} from '../src/lib/finance/seed-claro-commitments';

function loadEnvLocal() {
  const envPath = path.resolve(process.cwd(), '.env.local');
  if (fs.existsSync(envPath)) {
    const content = fs.readFileSync(envPath, 'utf-8');
    for (const line of content.split('\n')) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const eqIdx = trimmed.indexOf('=');
      if (eqIdx > 0) {
        const key = trimmed.slice(0, eqIdx).trim();
        const value = trimmed.slice(eqIdx + 1).trim();
        if (!process.env[key]) {
          process.env[key] = value;
        }
      }
    }
  }
}

async function main() {
  loadEnvLocal();

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

  if (!supabaseUrl || !supabaseKey) {
    console.error('Missing Supabase environment variables (NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY)');
    process.exit(1);
  }

  const supabase = createClient(supabaseUrl, supabaseKey);

  const jsonPath = path.resolve(process.cwd(), 'scripts', 'claro-invoices-parsed.json');
  if (!fs.existsSync(jsonPath)) {
    console.error(`Parsed JSON file not found at ${jsonPath}`);
    process.exit(1);
  }

  const invoicesData: ParsedInvoiceRecord[] = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));

  console.log(`Starting Claro commitments seeding for workspace ${DEFAULT_WORKSPACE_ID}...`);

  const result = await seedClaroCommitments(supabase, invoicesData, {
    workspaceId: DEFAULT_WORKSPACE_ID,
    ownerId: DEFAULT_OWNER_ID,
    categoryId: DEFAULT_CATEGORY_ID,
  });

  console.log(`\n--- Seeding Summary ---`);
  console.log(`Commitments created: ${result.commitmentsCreated}`);
  console.log(`Commitments updated: ${result.commitmentsUpdated}`);
  console.log(`Occurrences created: ${result.occurrencesCreated}`);
  console.log(`Occurrences updated: ${result.occurrencesUpdated}`);

  console.log(`\nCommitments in DB (${result.commitments.length}):`);
  result.commitments.forEach((c) => console.log(` - [${c.id}] ${c.description}`));

  console.log(`\nOccurrences in DB (${result.occurrences.length}):`);
  result.occurrences.forEach((o) =>
    console.log(` - [${o.id}] ${o.month}: ${o.description} - R$ ${o.amount.toFixed(2)}`)
  );

  console.log('\nSeeding completed successfully!');
}

main().catch((err) => {
  console.error('Fatal error running seed script:', err);
  process.exit(1);
});
