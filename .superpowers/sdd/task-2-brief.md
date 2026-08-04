# Task 2 Brief: Cadastro de Compromissos Fixos e Ocorrências no Supabase

## Contexto & Objetivos
Com os dados extraídos das faturas Claro no JSON `scripts/claro-invoices-parsed.json`, precisamos cadastrar os compromissos fixos e suas ocorrências mensais na base Supabase para o workspace **"BS finanças"** (`4244e4ad-d527-4b98-84b8-6333d04a6ee4`).

## Especificações

### Workspace & Parâmetros
- **Workspace ID:** `4244e4ad-d527-4b98-84b8-6333d04a6ee4`
- **Owner ID:** `68f89053-fd7b-4803-826e-b01f1847265e`
- **Categoria:** `b65240de-9de5-4110-aa19-feaa88f613ef` (Contas) ou id correspondente a despesas fixas.

### Registros em `fixed_commitments` (2 compromissos base):
1. **Claro Telefone Móvel**
   - `description`: "Claro Telefone Móvel (53 99189 8309)"
   - `amount`: 59.90 (valor base do plano)
   - `due_day`: 20
   - `recurrence`: "monthly"
   - `type`: "expense"
2. **Claro Internet Clínica**
   - `description`: "Claro Internet Clínica (NET 691/398972107)"
   - `amount`: 84.11 (valor base do plano)
   - `due_day`: 20
   - `recurrence`: "monthly"
   - `type`: "expense"

### Registros em `fixed_commitment_occurrences`:
Criar as ocorrências dos meses de **2026-02-01 a 2026-08-01** baseadas nas faturas do JSON `scripts/claro-invoices-parsed.json`:
- `status`: `'paid'`
- `due_date`: data real da fatura (ex: 2026-02-12, 2026-03-12, 2026-04-20, 2026-05-20, 2026-06-20, 2026-07-20, 2026-08-20)
- `amount`: valor total real da fatura extraída no JSON para aquele mês.

## Entregáveis
1. Script Node/TypeScript idempotente: `scripts/seed-claro-commitments.ts` (lê `scripts/claro-invoices-parsed.json` e popula a base Supabase usando o cliente Supabase ou RPCs da aplicação).
2. Testes unitários para a lógica do seeder em `src/lib/finance/__tests__/seed-claro-commitments.test.ts`.
3. Execução do script com sucesso contra o Supabase ou geração dos SQLs idempotentes de carga.
4. Relatório completo em `.superpowers/sdd/task-2-report.md`.
