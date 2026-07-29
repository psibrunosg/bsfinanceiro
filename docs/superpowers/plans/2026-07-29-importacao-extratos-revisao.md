# Importação de extratos com revisão Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Importar CSV de extrato com prévia, deduplicação e confirmação idempotente.

**Architecture:** O browser converte CSV em linhas normalizadas; o banco persiste lote e itens sob RLS e uma RPC aplica somente itens aprovados. `TransactionsPage` apresenta upload, revisão e inbox sem alterar o formulário manual.

**Tech Stack:** Next.js 15, React 19, TypeScript, Vitest, Supabase Postgres/RLS/RPC.

## Global Constraints

- Não armazenar arquivos CSV.
- Nunca inserir em `transactions` antes de `apply_transaction_import_batch`.
- Usar centavos inteiros no parser e RLS por `owner_id` em toda tabela nova.
- Não incluir OFX, PDF, OCR, Open Finance ou categorização automática.

---

### Task 1: Parser CSV e contrato de prévia

**Files:** Create `src/lib/finance/statement-csv.ts`, `src/lib/finance/statement-csv.test.ts`.

- [ ] **Step 1: Escrever testes para cabeçalhos, receita/despesa, datas BR/ISO e linhas inválidas**

```ts
expect(parseStatementCsv('date,description,amount\n2026-07-29,Salário,1000\n2026-07-30,Café,-12,50')).toMatchObject({ valid: 2, invalid: 0 });
```

- [ ] **Step 2: Rodar o teste e confirmar falha**

Run: `npm test -- src/lib/finance/statement-csv.test.ts`

- [ ] **Step 3: Implementar `parseStatementCsv(input, mapping?)`**

Retornar `{ headers, items }`; item válido contém `rowNumber`, `competenceDate`, `description`, `amountCents`, `type` e `fingerprint`; item inválido contém `reason`. Aceitar vírgula ou ponto e vírgula, decimal brasileiro e ISO.

- [ ] **Step 4: Rodar o teste e confirmar aprovação**

Run: `npm test -- src/lib/finance/statement-csv.test.ts`

- [ ] **Step 5: Commitar**

```bash
git add src/lib/finance/statement-csv.ts src/lib/finance/statement-csv.test.ts
git commit -m "feat: parse statement csv previews"
```

### Task 2: Lotes, itens, RLS e confirmação atômica

**Files:** Create migration via `supabase migration new reviewed_statement_imports`; modify `supabase/rls-smoke-test.sql`.

- [ ] **Step 1: Criar teste SQL/manual para RLS e reaplicação idempotente**

O segundo usuário não pode selecionar, descartar nem confirmar lote alheio; chamar a RPC duas vezes deve retornar as mesmas transações.

- [ ] **Step 2: Criar migration**

Criar `transaction_import_batches` e `transaction_import_items`, índices por workspace/status e chave única `(batch_id,row_number)`. Ativar RLS e políticas de proprietário. Criar `apply_transaction_import_batch(p_batch_id uuid)` como `security invoker`, validar proprietário e lote `pending`, inserir itens `ready` em `transactions` com `idempotency_key` determinística e marcar lote `applied` atomicamente. Criar `discard_transaction_import_batch(p_batch_id uuid)` para lote pendente.

- [ ] **Step 3: Executar migration no projeto vinculado e smoke test**

Run: `supabase db push --linked` and `supabase db query --linked --file supabase/rls-smoke-test.sql`

- [ ] **Step 4: Commitar**

```bash
git add supabase/migrations supabase/rls-smoke-test.sql
git commit -m "feat: add reviewed statement import batches"
```

### Task 3: Persistência de prévia e inbox

**Files:** Modify `src/app/components/types.ts`, `src/app/components/useFinance.ts`; create tests in `src/app/components/useFinance.test.tsx`.

- [ ] **Step 1: Escrever teste de carregamento de lotes recentes e recarga após confirmar**

Mockar `transaction_import_batches` e verificar que somente o workspace atual é consultado.

- [ ] **Step 2: Implementar tipos `TransactionImportBatch` e `TransactionImportItem`**

Adicionar ao retorno de `useFinance("transactions")` até dez lotes, ordenados por criação; expor `reload` existente para atualizar histórico e inbox.

- [ ] **Step 3: Rodar teste focado**

Run: `npm test -- src/app/components/useFinance.test.tsx`

- [ ] **Step 4: Commitar**

```bash
git add src/app/components/types.ts src/app/components/useFinance.ts src/app/components/useFinance.test.tsx
git commit -m "feat: load statement import inbox"
```

### Task 4: Prévia e confirmação na interface

**Files:** Create `src/app/components/StatementImportPanel.tsx`, `src/app/components/StatementImportPanel.test.tsx`; modify `src/app/TransactionsPage.tsx`, `src/app/transaction.css`.

- [ ] **Step 1: Escrever testes observáveis**

Cobrir upload CSV, escolha de conta, resumo pronto/duplicado/inválido, confirmação chamando RPC e descarte chamando RPC.

- [ ] **Step 2: Implementar painel acessível**

Ler arquivo com `File.text()`, executar parser, inserir lote/itens com `owner_id` e `workspace_id`, mostrar tabela limitada a 50 linhas e mensagens por status. Desabilitar confirmação sem itens prontos e enquanto a RPC estiver pendente.

- [ ] **Step 3: Integrar em Movimentações**

Adicionar painel antes do formulário manual e uma inbox de lotes com botões `Revisar`, `Confirmar` e `Descartar`; usar `reload()` após ações com sucesso.

- [ ] **Step 4: Rodar testes focados**

Run: `npm test -- src/app/components/StatementImportPanel.test.tsx src/app/TransactionsPage.test.tsx`

- [ ] **Step 5: Commitar**

```bash
git add src/app/components/StatementImportPanel.tsx src/app/components/StatementImportPanel.test.tsx src/app/TransactionsPage.tsx src/app/transaction.css
git commit -m "feat: review csv statement imports"
```

### Task 5: Verificação e documentação

**Files:** Modify `README.md`, `ROADMAP.md`.

- [ ] **Step 1: Documentar CSV suportado e limite de escopo OFX**

Incluir exemplo de colunas, confirmação explícita e regra de duplicação.

- [ ] **Step 2: Executar verificações**

Run: `npm run lint && npm test && npm run build`

- [ ] **Step 3: Commitar**

```bash
git add README.md ROADMAP.md
git commit -m "docs: describe reviewed csv imports"
```

## Self-review

Cobertura: parser, persistência, RLS, idempotência, UI e documentação possuem tarefas. Não há placeholders; OFX é explicitamente posterior. Tipos e nomes usados pela UI são definidos nas tarefas 1 a 3.
