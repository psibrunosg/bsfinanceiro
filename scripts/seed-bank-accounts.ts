import fs from 'fs';
import path from 'path';
import { createClient } from '@supabase/supabase-js';
import {
  seedBankAccounts,
  DEFAULT_WORKSPACE_ID,
  DEFAULT_OWNER_ID,
  formatAccountBalance,
} from '../src/lib/finance/accounts';

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
  const supabaseKey =
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

  if (!supabaseUrl || !supabaseKey) {
    console.error(
      'Missing Supabase environment variables (NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY)'
    );
    process.exit(1);
  }

  const supabase = createClient(supabaseUrl, supabaseKey);

  console.log(`Starting bank accounts seeding for workspace ${DEFAULT_WORKSPACE_ID}...`);

  const result = await seedBankAccounts(supabase, {
    workspaceId: DEFAULT_WORKSPACE_ID,
    ownerId: DEFAULT_OWNER_ID,
  });

  console.log(`\n--- Seeding Summary ---`);
  console.log(`Accounts created: ${result.createdCount}`);
  console.log(`Accounts updated: ${result.updatedCount}`);
  console.log(`Accounts unchanged: ${result.existingCount}`);

  console.log(`\nBank Accounts in Workspace (${result.accounts.length}):`);
  result.accounts.forEach((acc) => {
    console.log(
      ` - [${acc.id}] ${acc.name} (${acc.type.toUpperCase()}) | Scope: ${acc.scope.toUpperCase()} | Balance: ${formatAccountBalance(
        acc.initial_balance
      )}`
    );
  });

  console.log('\nBank accounts seeding completed successfully!');
}

main().catch((err) => {
  console.error('Fatal error running bank accounts seed script:', err);
  process.exit(1);
});
