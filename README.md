# BS Financeiro

Planejador e controlador financeiro visual, simples e preparado para múltiplos usuários com dados privados.

## Começar
Requer Node.js 22 ou superior.

1. Copie `.env.example` para `.env.local`.
2. Preencha a publishable key disponível em Project Settings > API Keys. Nunca use `service_role` no cliente.
3. Execute `npm install` e `npm run dev`.
4. Para teste completo de cadastro, confirme o e-mail do usuário antes de tentar login.

## Verificação
Use `npm run lint`, `npm test` e `npm run build` antes de integrar mudanças.
Use `supabase/rls-smoke-test.sql` para conferir isolamento básico de RLS no banco remoto vinculado.

### Cenário manual de aceitação: decisão diária

Com uma conta de teste autenticada, percorra o fluxo abaixo para validar a experiência de pessoa física:

1. Crie uma conta corrente ativa e defina-a como conta principal.
2. Registre uma renda planejada futura.
3. Crie um compromisso fixo ainda não pago, com vencimento antes dessa renda.
4. Abra o Painel e confira `Disponível para gastar`, a data da próxima entrada e a explicação da reserva do compromisso.
5. Lance uma despesa pelo registro rápido, informando somente valor e descrição; ela deve usar a conta principal e a data de hoje.
6. Abra Movimentações, pesquise pela descrição e confirme que a despesa aparece no histórico.

O ciclo inclui importação de extratos CSV e OFX com prévia, deduplicação e inbox de revisão. A confirmação continua explícita: a prévia nunca grava movimentações sozinha.

### Importar extrato CSV com revisão

Em **Movimentações**, escolha uma conta e envie um CSV UTF-8 com cabeçalho. O formato reconhecido usa colunas de data, descrição e valor (por exemplo, `date,description,amount`); valores positivos viram receitas e negativos, despesas. A prévia mostra linhas prontas, duplicadas e inválidas, sem gravar movimentações. Só `Confirmar importação` aplica as linhas prontas. Duplicatas são revalidadas no banco por conta, data, tipo, valor e descrição normalizada; reenviar ou confirmar o mesmo lote não duplica lançamentos.

### Importar OFX com revisão

Em **Movimentações**, envie um OFX do internet banking para a mesma inbox de revisão do CSV. Antes de confirmar, confira conta, data, descrição e valor de cada linha. Reenviar o arquivo ou confirmar um lote novamente não deve duplicar movimentações.

### Importar documentos PDF com revisão

O app também aceita dois fluxos estreitos de PDF com **texto selecionável**:

- **Cartões:** fatura Santander no layout textual reconhecido, em **Cartões**. A prévia cria candidatos de compra e parcela; revise-os e confirme a fatura. Importar uma fatura não a paga e não cria movimento de caixa. O pagamento segue sendo uma ação separada.
- **Ganhos:** contracheque textual com rótulos reconhecidos, em **Ganhos > Contracheques**. Revise empregador, competência, bruto, descontos e líquido. Só há receita no caixa quando data e conta de recebimento forem informadas e confirmadas.

Os arquivos são temporários em buckets privados e o texto extraído não é guardado no banco. PDFs escaneados, vazios, grandes, extensos, ambíguos ou de layout não reconhecido falham sem criar dados financeiros. OCR, Open Finance e suporte universal a emissores continuam fora do escopo; acompanhe OCR nas issues #8 e #10. Consulte [a documentação de faturas](./docs/credit-card-statement-import.md) para limites, estados e recuperação.

## Deploy no GitHub Pages
Configure estes Repository secrets em `Settings > Secrets and variables > Actions`:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`

O workflow usa esses valores somente durante o build estático. Nunca configure `service_role` nesses secrets.

## Banco
O projeto Supabase é `wgntlhzjyriwhncumjsv`, o mesmo ref usado em `.env.example`. O histórico remoto está alinhado até `20260811000010`; o smoke de RLS/RPC usa dois usuários e roles SQL reais. As quatro Edge Functions de documentos e os dois jobs horários de limpeza estão ativos. As RPCs financeiras legadas usadas por Cartões e Ganhos foram restringidas ao proprietário autenticado e não concedem execução a `anon`.

## Estado atual
- Dashboard responsivo com temas claro/escuro e dados reais do Supabase.
- PWA básica.
- Cliente Supabase browser e server configurados com sessão SSR.
- Rotas de login, cadastro, callback de confirmação e logout.
- Middleware protege o dashboard e valida tokens com `getClaims()`.
- Migrations para contas, categorias, transações, compromissos fixos, cartões, faturas, parcelas, orçamentos e metas, com RLS por proprietário.
- Banco remoto resetado e recriado apenas com as migrations financeiras.
- RLS validado no banco remoto com dois usuários simulados em transação com rollback.
- Telas e ações para onboarding, contas, categorias, movimentações, cartões, compromissos e planejamento.
- Importação revisável de CSV/OFX, faturas Santander textuais e contracheques textuais publicada; migrations, Edge Functions, cron e smoke remoto foram validados em 11/08/2026.
- A navegação mostra apenas rotas disponíveis no app.

## Plano de desenvolvimento
O plano priorizado está em [ROADMAP.md](./ROADMAP.md). O próximo passo é validar o fluxo real de cadastro, onboarding e primeiro lançamento financeiro.
