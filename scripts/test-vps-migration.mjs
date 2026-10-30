// Run only against the explicitly named disposable containers described in the handoff.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { textualPdfWithText } from '../supabase/functions/_shared/pdf-test-fixture.ts';

const container = 'bsfinanceiro-vps-migration-test-20261005';
const base = process.env.BS_FINANCEIRO_TEST_BASE_URL;
assert.equal(process.env.BS_FINANCEIRO_DISPOSABLE_TEST, '1', 'Disposable test guard is required');
assert.equal(base, 'http://127.0.0.1:58009/api', 'Only the local disposable API is allowed');
assert.equal(execFileSync('docker', ['inspect', container, '--format', '{{index .Config.Labels "purpose"}}'], { encoding: 'utf8' }).trim(), 'bsfinanceiro-disposable-test');
const sql = query => execFileSync('docker', ['exec', '-i', container, 'psql', '-U', 'postgres', '-d', 'bsfinanceiro_test', '-v', 'ON_ERROR_STOP=1', '-At'], { input: query, encoding: 'utf8' }).trim();
let checks = 0;
async function request(route, user, body, status = 200, extraHeaders = {}) {
  const headers = { ...extraHeaders };
  if (user) headers.Authorization = `Bearer ${user.token}`;
  const multipart = body instanceof FormData;
  if (body && !multipart) headers['Content-Type'] = 'application/json';
  const res = await fetch(base + route, { method: body ? 'POST' : 'GET', headers, body: body ? multipart ? body : JSON.stringify(body) : undefined });
  const data = await res.json();
  assert.equal(res.status, status, `${route}: ${JSON.stringify(data)}`);
  checks++;
  return data;
}
const suffix = randomUUID();
const password = 'LocalDisposablePassword123!';
async function register(label) { return request('/auth/register', null, { email: `${label}-${suffix}@example.invalid`, password, name: label }); }
const owner = await register('owner');
const editor = await register('editor');
const viewer = await register('viewer');
const outsider = await register('outsider');
await request('/auth/login', null, { email: '', password: '' }, 400);
assert.equal((await request('/auth/login', null, { email: owner.user.email, password })).onboarding_required, true);
const wid = owner.workspace.id;
const boot = user => request(`/bootstrap?workspace_id=${user.workspace.id}`, user);
await request('/bootstrap', null, undefined, 401);
await request('/reports/shared?token=invalid', null, undefined, 404);
await request(`/bootstrap?workspace_id=${wid}`, outsider, undefined, 403);
const initial = await boot(owner);
const account = initial.accounts[0].id;
const otherAccount = (await boot(outsider)).accounts[0].id;
const bootstrapKeys = ['accounts','categories','transactions','budgets','goals','debts','investments','investment_operations','investment_quotes','workspace_users','workspace_invites','contexts','category_rules','transaction_import_batches'];
for (const key of bootstrapKeys) assert(Array.isArray(initial[key]), `Missing bootstrap array: ${key}`);
assert('alert_preferences' in initial && 'workspace_preferences' in initial);
const onboarding = { display_name: 'Owner', monthly_income: 1000, current_balance: 100, card_name: 'Test Card', closing_day: 15, due_day: 22 };
await request('/onboarding', owner, onboarding);
await request('/onboarding', owner, onboarding);
const configured = await boot(owner);
assert.equal(configured.cards.length, 1);
assert.equal(configured.transactions.filter(t => t.description.includes('onboarding')).length, 1);
const login = await request('/auth/login', null, { email: owner.user.email, password });
assert.equal(login.onboarding_required, false);
for (const [member, role] of [[editor, 'editor'], [viewer, 'viewer']]) {
  const invite = await request('/invites', owner, { workspace_id: wid, role });
  await request('/invites/accept', member, { token: invite.token });
  await request('/invites/accept', member, { token: invite.token });
  await request('/invites/accept', outsider, { token: invite.token }, 409);
}
await request('/invites', editor, { workspace_id: wid, role: 'admin' }, 403);
assert.equal((await request(`/bootstrap?workspace_id=${wid}`, viewer)).workspace_invites.length, 0);
assert.equal((await request(`/bootstrap?workspace_id=${wid}`, editor)).workspace_invites.length, 0);
assert.equal((await boot(owner)).workspace_invites.length, 0); // Consumed tokens are never returned.
await request('/patients', viewer, { workspace_id: wid, name: 'Forbidden' }, 403);
const patient = (await request('/patients', editor, { workspace_id: wid, owner_id: outsider.user.id, name: 'Test Patient' })).patient;
assert.equal(patient.owner_id, editor.user.id);
await request('/patient-earnings', owner, { workspace_id: outsider.workspace.id, patient_id: patient.id, amount: 10, appointment_date: '2026-10-01' }, 403);
const earning = (await request('/patient-earnings', editor, { workspace_id: wid, patient_id: patient.id, amount: 25, appointment_date: '2026-10-01', due_date: '2026-10-02' })).earning;
await request('/patient-earnings/receive', owner, { earning_id: earning.id, account_id: otherAccount, received_date: '2026-10-02' }, 403);
const receiveBody = { earning_id: earning.id, account_id: account, received_date: '2026-10-02' };
const received = await request('/patient-earnings/receive', owner, receiveBody);
const repeated = await request('/patient-earnings/receive', owner, receiveBody);
assert.equal(repeated.transaction_id, received.transaction_id);
assert.equal(sql(`SELECT count(*) FROM transactions WHERE id='${received.transaction_id}';`), '1');
const slip = { workspace_id: wid, employer: 'Test Employer', competence: '2026-10-01', gross_amount: 100, discounts_amount: 20, net_amount: 80, received_date: '2026-10-02', account_id: account };
await request('/payslips', owner, { ...slip, net_amount: 999 }, 400);
await request('/payslips', owner, { ...slip, received_date: null }, 400);
const pdf = '%PDF-1.4\nDisposable test document';
const form = () => { const data = new FormData(); Object.entries(slip).forEach(([k, v]) => data.set(k, String(v))); data.set('pdf', new Blob([pdf], { type: 'application/pdf' }), 'test.pdf'); return data; };
const slipKey = { 'X-Idempotency-Key': randomUUID() };
const saved = await request('/payslips', owner, form(), 200, slipKey);
const replay = await request('/payslips', owner, form(), 200, slipKey);
assert.equal(replay.payslip.id, saved.payslip.id);
await request('/payslips', owner, { ...slip, employer: 'Different' }, 409, slipKey);
const document = `/payslips/${saved.payslip.id}/document`;
await request(document, outsider, undefined, 403);
const download = await fetch(base + document, { headers: { Authorization: `Bearer ${viewer.token}` } });
assert.equal(download.status, 200); assert.match(download.headers.get('Content-Type'), /^application\/pdf/); assert.equal(await download.text(), pdf); checks++;
const asset = (await request('/investments/assets', owner, { workspace_id: wid, ticker: '', name: 'Local Asset', type: 'cdb' })).asset;
await request('/investments/quotes', outsider, { workspace_id: outsider.workspace.id, asset_id: asset.id, unit_price: 12, quote_date: '2026-10-01' }, 404);
const operation = { workspace_id: wid, asset_id: asset.id, account_id: account, operation_type: 'buy', quantity: 2, unit_price: 12, operation_date: '2026-10-01' };
const operationKey = { 'X-Idempotency-Key': randomUUID() };
const created = await request('/investments/operations', owner, operation, 200, operationKey);
const operationReplay = await request('/investments/operations', owner, operation, 200, operationKey);
assert.equal(created.operation.id, operationReplay.operation.id);
assert.equal(created.transaction_id, operationReplay.transaction_id);
assert.equal(created.operation.transaction_id, created.transaction_id);
await request('/investments/operations', owner, { ...operation, quantity: 3 }, 409, operationKey);
await request('/investments/operations', viewer, operation, 403);
const concurrentKey = { 'X-Idempotency-Key': randomUUID() };
const concurrent = await Promise.all([request('/investments/operations', owner, operation, 200, concurrentKey), request('/investments/operations', owner, operation, 200, concurrentKey)]);
assert.equal(concurrent[0].operation.id, concurrent[1].operation.id);
// Fault injection proves effects and receipt roll back together after a mid-operation failure.
sql(`CREATE OR REPLACE FUNCTION vps_migration_test_reject_tx() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN IF NEW.description LIKE '%Local Asset%' OR NEW.description LIKE '%Rollback-Probe%' THEN RAISE EXCEPTION 'disposable fault injection'; END IF; RETURN NEW; END $$;
CREATE TRIGGER vps_migration_test_reject_tx BEFORE INSERT ON transactions FOR EACH ROW EXECUTE FUNCTION vps_migration_test_reject_tx();`);
try {
  const before = sql(`SELECT count(*) FROM investment_operations WHERE workspace_id='${wid}';`);
  const failedKey = randomUUID();
  await request('/investments/operations', owner, operation, 500, { 'X-Idempotency-Key': failedKey });
  assert.equal(sql(`SELECT count(*) FROM investment_operations WHERE workspace_id='${wid}';`), before);
  assert.equal(sql(`SELECT count(*) FROM api_idempotency WHERE request_key='${failedKey}';`), '0');
  await request('/payslips', owner, { ...slip, employer: 'Rollback-Probe' }, 500, { 'X-Idempotency-Key': randomUUID() });
  assert.equal(sql(`SELECT count(*) FROM payslips WHERE workspace_id='${wid}' AND employer='Rollback-Probe';`), '0');
} finally {
  sql('DROP TRIGGER vps_migration_test_reject_tx ON transactions; DROP FUNCTION vps_migration_test_reject_tx();');
}
// A pre-marker account with real activity must not receive fresh onboarding financial seeds.
await request('/transactions', outsider, { workspace_id: outsider.workspace.id, account_id: otherAccount, type: 'income', amount: 10, description: 'Existing legacy activity', competence_date: '2026-10-01', status: 'paid' });
const legacyBefore = await boot(outsider);
await request('/onboarding', outsider, onboarding);
const legacyAfter = await boot(outsider);
assert.equal(legacyAfter.transactions.length, legacyBefore.transactions.length);
assert.equal(legacyAfter.cards.length, legacyBefore.cards.length);
const share = await request('/reports/share', editor, { workspace_id: wid, name: 'Consolidated' });
const report = await request(`/reports/shared?token=${share.token}`, null);
assert(report.data.transactions.some(t => t.id === received.transaction_id));
assert(report.data.transactions.some(t => t.id === created.transaction_id));
assert(report.data.transactions.every(t => ['income', 'expense'].includes(t.type)));
assert.deepEqual(Object.keys(report.data).sort(), ['report', 'transactions']);
sql(`UPDATE shared_reports SET expires_at=NOW()-INTERVAL '1 second' WHERE token='${share.token}';`);
await request(`/reports/shared?token=${share.token}`, null, undefined, 404);
const statement = `Esta é a fatura do seu cartão SANTANDER
Fatura de agosto de 2026
Total a Pagar R$ 223,35
VENCIMENTO 22/08/2026
Compras e pagamentos realizados até 15/08/2026
Lançamentos
10/08 MERCADO EXEMPLO R$ 23,45
12/08 LIVRARIA MODELO 02/10 R$ 199,90
Total da compra R$ 1.999,00
Limites
Limite disponível R$ 1.000,00`;
const statementForm = () => { const data = new FormData(); data.set('credit_card_id', configured.cards[0].id); data.set('statement', new Blob([statement], { type: 'text/plain' }), 'santander.txt'); return data; };
await request('/card-statement-imports', viewer, statementForm(), 403);
const upload = await request('/card-statement-imports', editor, statementForm());
assert.equal(upload.import.status, 'pending_review');
const reviewPath = `/card-statement-imports/${upload.import.id}/apply`;
await request(reviewPath, viewer, { items: upload.import.items }, 403);
await request(reviewPath, editor, { items: upload.import.items });
await request(reviewPath, editor, { items: upload.import.items });
const duplicateUpload = await request('/card-statement-imports', editor, statementForm());
assert.equal(duplicateUpload.import.id, upload.import.id);
assert.equal(sql(`SELECT count(*) FROM credit_card_purchases WHERE credit_card_id='${configured.cards[0].id}';`), '2');
assert.equal(sql(`SELECT total_amount FROM credit_card_invoices WHERE credit_card_id='${configured.cards[0].id}' AND month=8 AND year=2026;`), '223.35');
assert.equal(sql(`SELECT count(*) FROM credit_card_installments WHERE credit_card_id='${configured.cards[0].id}';`), '10');
const pdfStatement = new FormData();
pdfStatement.set('credit_card_id', configured.cards[0].id);
pdfStatement.set('statement', new Blob([textualPdfWithText(statement.normalize('NFD').replace(/[\u0300-\u036f]/g, ''))], { type: 'application/pdf' }), 'santander.pdf');
const pdfUpload = await request('/card-statement-imports', editor, pdfStatement);
assert.equal(pdfUpload.import.status, 'pending_review');
assert.equal(pdfUpload.import.content_type, 'application/pdf');
await request(`/card-statement-imports/${pdfUpload.import.id}/discard`, editor, {});
await request(`/card-statement-imports/${pdfUpload.import.id}/discard`, editor, {});
console.log(`PASS: ${checks} HTTP checks plus atomicity, idempotency, workspace/role isolation and financial assertions.`);
