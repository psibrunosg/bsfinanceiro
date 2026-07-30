# Evolução do BS Financeiro para central financeira completa

## 1. Experiência e navegação

- Reorganizar a sidebar desktop em: Painel, Ganhos, Gastos, Contas, Cartões, Investimentos, Planejamento e Mais.
- No celular: Painel, Ganhos, Adicionar, Gastos e Mais. A página Mais reúne Contas, Cartões, Investimentos, Planejamento, Categorias e Configurações.
- Transformar Ganhos e Gastos em hubs analíticos. `/compromissos` redirecionará para `/gastos?tab=recorrentes`.
- Remover formulários fixos das laterais. Cada página terá um único botão de cadastro no cabeçalho, abrindo `<dialog>` estilizado no desktop e bottom sheet no celular.
- Corrigir o CSS ausente do registro rápido, inputs e selects. Padronizar dropdowns, foco, erro, carregamento, estados vazios e responsividade.
- Aproveitar toda a largura disponível, eliminando colunas vazias e cartões excessivamente altos.

## 2. Painel e módulos financeiros

- O Painel abrirá no mês atual, consolidando Pessoal e Clínica, com filtros visíveis de contexto, mês, ano e período personalizado.
- Remover o grande banner e o formulário permanente da primeira área. A ordem será:
  1. Fluxo de caixa em linha/barras.
  2. Gastos por categoria em rosca.
  3. Composição dos ganhos: contracheques, pacientes e outras receitas.
  4. Indicadores de saldo disponível, resultado do período, contas próximas, recebimentos pendentes e faturas.
  5. Evolução e composição da carteira de investimentos.
  6. Alertas e pareceres automáticos baseados nos dados.
- Contas mostrará saldo atual por conta, participação no patrimônio, última movimentação, evolução e distribuição por conta. Cartões deixam de aparecer e de poder ser cadastrados como contas.
- Cartões terá botão “Cadastrar cartão”, indicadores de fatura aberta e limite, gráficos por cartão/categoria, evolução mensal e anual, comparação entre faturas e parecer textual determinístico. A conta técnica do cartão continuará internamente para preservar compras e pagamentos, mas ficará invisível.
- Movimentações terá histórico em largura total, filtros organizados, importação CSV recolhível e botão “Nova movimentação”. O painel lateral vazio será removido.
- Ganhos terá abas Visão geral, Contracheques, Pacientes e Outras receitas. Contracheques registrarão empregador, competência, bruto, descontos, líquido, recebimento, movimentação e PDF privado. Pacientes usarão nome completo e registros financeiros por atendimento, sem informações clínicas.
- Gastos terá abas Visão geral, Lançamentos e Recorrentes, com separação Pessoal/Clínica, recorrente/variável e gráficos por categoria, período e contexto.
- Investimentos terá ativos, compras, vendas, rendimentos, taxas, quantidade, custo médio, cotação manual, rentabilidade e alocação. As operações gerarão movimentações vinculadas automaticamente.
- Categorias terá cadastro por botão superior e suporte a categorias globais ou específicas de Pessoal/Clínica.

## 3. Dados, segurança e interfaces

- Criar `financial_contexts` para Pessoal e Clínica. Movimentações, compromissos, orçamentos, metas, compras no cartão e novos registros financeiros receberão `context_id`. Dados existentes serão migrados para Pessoal.
- Adicionar:
  - `patients` e `patient_earnings`, com valor, atendimento, vencimento, situação e movimentação vinculada.
  - `payslips`, com valores estruturados, competência, arquivo privado e movimentação vinculada.
  - `investment_assets`, `investment_operations` e `investment_quotes`.
  - `accounts.is_system`, marcando contas técnicas de cartões.
- Criar RPCs atômicas e idempotentes para cadastrar cartão com conta técnica, receber atendimento, registrar contracheque e lançar operação de investimento.
- Rendimentos recebidos entram como receita; compras e vendas de ativos ficam vinculadas a transferências entre conta de caixa e conta de investimento.
- Relatórios de gastos incluirão parcelas de cartão por competência e excluirão pagamentos de fatura da composição por categoria, evitando dupla contagem.
- PDFs ficarão em bucket privado, limitados a PDF e 10 MB, em caminho pertencente ao usuário.
- Todas as novas tabelas terão constraints, índices por `workspace_id`, `owner_id`, contexto, situação e data, RLS por proprietário e grants explícitos. Isso segue a orientação oficial de [RLS do Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security) e a mudança de 2026 sobre [exposição de novas tabelas na API](https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically).
- Ampliar `workspace_preferences` com contexto e período padrão, ocultação de valores, densidade visual, contas/categorias padrão, valor padrão de atendimento e prazo de cobrança.
- Manter `profiles.theme_preference` e oferecer seleção Sistema, Claro ou Escuro dentro de Configurações.
- Criar tipos públicos `FinancialContext`, `Patient`, `PatientEarning`, `Payslip`, `InvestmentAsset`, `InvestmentOperation` e `InvestmentQuote`.
- Adicionar ao `PageHeader` uma ação principal reutilizável. Novos hubs terão consultas próprias por período/contexto, enquanto agregações financeiras permanecerão em utilitários puros usando centavos.

## 4. Personalização e ideias incorporadas

- Configurações será dividida em Aparência, Painel, Contextos, Ganhos, Gastos, Alertas, Privacidade e Dados.
- Opções: período inicial, contexto inicial, ocultar valores, modo compacto, cores de Pessoal/Clínica, contas e categorias padrão, valor padrão por atendimento, prazo de cobrança e alertas de recebimento atrasado ou cotação desatualizada.
- Pareceres mostrarão variação contra o período anterior, maior categoria, principal fonte de receita, paciente com maior faturamento, peso das despesas fixas, cartão com maior uso e evolução da carteira.
- Estados vazios terão uma ação clara, como “Cadastrar primeiro investimento” ou “Registrar primeiro atendimento”.

## 5. Testes, migração e entrega

- Testar agregações por período e contexto, contracheques, recebimentos pendentes, custo médio, rentabilidade, parcelas de cartão e prevenção de dupla contagem.
- Testar RLS entre usuários, backfill para Pessoal, RPCs atômicas, idempotência, conta técnica oculta e acesso privado aos PDFs.
- Atualizar testes de componentes para dialogs, selects, botões de cabeçalho, filtros e navegação.
- Expandir Playwright com Supabase simulado para Painel, Contas, Cartões, Movimentações, Ganhos, Gastos, Investimentos, Categorias e Configurações em 375, 768, 1024 e 1440 px, claro/escuro, teclado e movimento reduzido.
- Preservar os 131 testes atuais, lint e build.
- Criar migrations pelo CLI, revisar rollback, executar advisors, aplicar primeiro no Supabase, validar consultas e somente depois publicar o frontend no GitHub Pages.
- Defaults adotados: mês consolidado, conta técnica de cartão apenas oculta, investimentos vinculados automaticamente às movimentações e formulários em dialog/bottom sheet.
