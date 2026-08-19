# Importação segura de documentos financeiros — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remover segredos versionados e importar, com revisão e idempotência, faturas Santander e contracheques em PDF com texto selecionável.

**Architecture:** PDFs ficam temporariamente em Storage privado e são processados por Edge Functions. Somente drafts estruturados chegam ao banco; RPCs transacionais aplicam a confirmação financeira.

**Tech Stack:** Next.js 15.5.x, React 19, TypeScript, Vitest, Playwright, Supabase Edge/Deno, `unpdf`, Postgres/RLS/RPC.

## Global Constraints

- Usar apenas `codex/secure-document-imports` na worktree isolada; preservar `work/` e mudanças não relacionadas.
- Subagentes escrevem relatório em arquivo e respondem ao orquestrador somente `OK` ou `Fail`.
- Usar `gpt-5.6-terra` com esforço baixo em testes e tarefas mecânicas; elevar capacidade apenas para integração/revisão final.
- TDD obrigatório: relatório precisa registrar RED, GREEN, comando e saída.
- Texto/PDF bruto nunca é persistido; OCR não pertence a este ciclo.
- Valores ficam em centavos nos parsers; pagamento de fatura continua separado da importação.
- Sem force-push, rotação de senha, custo externo ou migration destrutiva sem autorização/ação do usuário.

## Entregas verticais

1. Segurança/E2E e dependências.
2. Extração Edge compartilhada.
3. Fatura Santander: candidatos, revisão e aplicação atômica.
4. Contracheque: draft, revisão e aplicação atômica.
5. Documentação, tracker, banco, deploy e evidências.

## Skills previstas

| Etapa | Skill | Evidência |
|---|---|---|
| Preparação | `using-git-worktrees` | worktree/branch e baseline de 168 testes |
| Implementação | `subagent-driven-development`, `test-driven-development` | relatório RED/GREEN por tarefa |
| Simplicidade | `ponytail` | dois pipelines estreitos; somente extração compartilhada |
| Revisão | `requesting-code-review`, `verification-before-completion` | pacote de diff, gates e revisão final |

### Task 1: Segurança de credenciais, dependências e Playwright

**Files:** `e2e/validation-p27.e2e.ts`, `e2e/auth.setup.ts`, `playwright.config.ts`, `.env.example`, `package.json`, `package-lock.json`.

**Produces:** specs autenticadas só existem quando ambas as variáveis E2E estão presentes; nenhum segredo no código; audit sem high/critical.

- [ ] RED: sem variáveis, `npx playwright test --list` demonstra que P2.7 roda deslogado ou que projetos auth dependem de estado inexistente.
- [ ] Remover constantes/login embutidos; usar `const AUTH_SPECS = /(visual-hubs|validation-p27)\.e2e\.ts/` e `storageState` único.
- [ ] Construir projetos setup/auth somente quando `E2E_EMAIL && E2E_PASSWORD`; manter mobile/tablet/desktop públicos sempre.
- [ ] Atualizar Next/ESLint config para patch seguro da mesma minor e lockfile; aplicar somente fixes sem major.
- [ ] GREEN:

```powershell
Remove-Item Env:E2E_EMAIL -ErrorAction SilentlyContinue
Remove-Item Env:E2E_PASSWORD -ErrorAction SilentlyContinue
npx playwright test --list
rg -n -i 'TEST_(EMAIL|PASSWORD)' e2e playwright.config.ts .env.example
npm audit
npm test
```

- [ ] Commit: `fix(security): remove exposed e2e credentials`.

### Task 2: Extrator PDF compartilhado no Edge

**Files:** create `supabase/functions/_shared/pdf-text.ts`, `supabase/functions/_shared/pdf-text.test.ts`, `supabase/functions/_shared/pdf-test-fixture.ts`; modify/add import map/config de funções.

**Produces:** `extractSelectablePdfText(bytes: Uint8Array): Promise<{ text: string; totalPages: number }>`; erros `invalid_pdf`, `pdf_too_large`, `pdf_too_many_pages`, `pdf_without_selectable_text`.

- [ ] RED: fixture PDF textual real retorna texto/1 página; PDFs sem header, sem texto, >10 MiB e >20 páginas falham com código exato.
- [ ] Pin `unpdf@1.8.0` no runtime Edge; não adicionar ao bundle Next.
- [ ] Implementar limites antes/depois da extração, normalizar whitespace e descartar referência ao texto após o parser.
- [ ] GREEN: executar teste compatível; se Deno/Docker não existir, usar teste Node para o módulo puro e `supabase functions deploy --dry-run`/bundle disponível. Não fingir verificação Edge.
- [ ] Commit: `feat(import): extract selectable text in edge functions`.

### Task 3: Fatura Santander revisável e atômica

**Files:** create parser/test em `supabase/functions/_shared/`; modify `process-credit-card-statement-import`; create migration `20260811000000_review_credit_card_statement_imports.sql`; modify `CardsPage.tsx`, tests, types/useFinance e `supabase/rls-smoke-test.sql`.

**Produces:** candidatos estruturados e RPC `apply_credit_card_statement_import(p_import_id uuid, p_items jsonb) returns uuid[]`.

- [ ] RED parser: fixture Santander literal cobre compra à vista, `02/10`, moeda brasileira, vencimento/fechamento, campo ausente e layout ambíguo.
- [ ] Implementar parser allow-listed; sem total original de parcela, marcar item `needs_review` e nunca inventar total.
- [ ] RED SQL contract: enum contém `pending_review`; child table tem FK, RLS, `unique(import_id,ordinal)` e sem grant direto de mutação; apply usa `auth.uid()`, lock e limite 500.
- [ ] Migration: job guarda parser/version/declared total; child table guarda somente campos estruturados. RPC aplica tudo numa transação, usa fingerprints estáveis, cria/reutiliza fatura/compra/parcela e termina job.
- [ ] Edge: checksum, extração, parser, persistência de candidatos, remoção do PDF, estado `pending_review`; nenhum loop de RPC financeira.
- [ ] RED/GREEN UI: upload mostra estados, prévia editável e diferença; confirmação chama uma RPC; nenhum pagamento/transação de caixa.
- [ ] Verificar parser, CardsPage, contract tests e smoke SQL.
- [ ] Commit: `feat(cartoes): review textual Santander statements`.

### Task 4: Contracheque textual revisável e atômico

**Files:** create parser/test; create migration `20260811000001_payslip_document_imports.sql`; create `process-payslip-document-import`; modify `ganhos/page.tsx`, tests, types e smoke RLS.

**Produces:** `PayslipCandidate`; jobs temporários; RPC `apply_payslip_document_import(p_import_id uuid, p_candidate jsonb, p_received_date date, p_account_id uuid, p_context_id uuid) returns uuid`.

- [ ] RED parser: empregador, `07/2026`, bruto, descontos e líquido; ausência/ambiguidade falha; `bruto - descontos = líquido` é validado em centavos.
- [ ] Migration: tabela/job/bucket privado temporário, estados, checksum, expiração, RLS, retry, claim/finish/apply/cleanup. Não alterar retenção de anexos manuais existentes.
- [ ] Apply deriva owner/workspace de `auth.uid()`, traduz duplicata para `duplicate_payslip` e não cria transação sem data+conta.
- [ ] Edge recomputa checksum, extrai, parseia, salva draft e remove objeto em terminal; service role não sai do Edge.
- [ ] RED/GREEN UI: ação separada “Importar PDF”, status e prévia; cadastro manual/anexo privado continuam funcionando.
- [ ] Verificar parser, UI, SQL/RLS, retry e idempotência.
- [ ] Commit: `feat(ganhos): review textual payslip imports`.

### Task 5: Documentação, tracker, gates e handoff

**Files:** `README.md`, `ROADMAP.md`, `docs/credit-card-statement-import.md`, `work/handoffs/bsfinanceiro_2026-08-11_importacao_documentos.md`.

- [ ] Documentar OFX já entregue, layouts textuais suportados, revisão, privacidade e OCR pendente.
- [ ] Gates locais: `npm audit`, `npm run lint`, `npm test`, `npm run build`, Playwright público, `git diff --check`.
- [ ] Banco: alinhar histórico local/remoto antes de push; executar migrations, smoke RLS e advisors antes do frontend.
- [ ] Gate autenticado: somente com credencial rotacionada externa; validar P2.7 e hubs em 375/1440. Sem credencial, registrar bloqueio real.
- [ ] Atualizar #3/#7/#9 com evidências; manter #8/#10 abertas.
- [ ] Após revisão e autorização de integração, deploy e verificação de produção.

## Recuperação de falhas

- Parser falha: job `failed`, objeto removido, cadastro manual disponível.
- Apply falha: rollback integral e draft preservado para correção/retry.
- Limpeza falha: job permanece rastreável para cleanup; não reaplica finanças.
- Migration/RLS falha: interromper deploy e não publicar frontend incompatível.
- Credencial E2E ausente/comprometida: não usar o segredo antigo; gate autenticado fica pendente.

## Definição de pronto

Credencial removida do HEAD e rotacionada, audit sem high/critical, PDFs textuais processados no Edge sem texto bruto persistido, ambos os fluxos revisáveis/idempotentes, RLS e migrations validadas, lint/test/build/Playwright verdes, revisão final limpa e produção verificada.

## Workflow autônomo

O agente segue sozinho em decisões reversíveis dentro do escopo, com TDD, commits e reviews por tarefa. Pausa somente para rotação/revogação, reescrita de histórico, credencial/custo externo, migration remota destrutiva ou ampliação para OCR/outros layouts.

## Self-review

- Todas as exigências do design aparecem em tarefas.
- Nenhum marcador pendente; OCR e suporte universal estão explicitamente fora.
- Nomes de estados, parsers e RPCs são consistentes.
- A importação não altera a semântica de pagamento de fatura ou recebimento de renda.
