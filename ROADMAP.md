# Roadmap

Atualizado em 15/07/2026.

## Situação confirmada

O projeto Supabase do BS Financeiro é `wgntlhzjyriwhncumjsv`, que também aparece em `.env.example`. Em 15/07/2026, o banco remoto foi resetado e recriado a partir das oito migrations financeiras locais. As tabelas de RH que estavam misturadas no schema `public` foram removidas no reset. Depois da recriação, os advisors de segurança e desempenho não apontaram issues.

## P0. Vincular e validar o banco

1. Banco remoto vinculado, resetado e recriado apenas com as migrations financeiras.
2. Histórico remoto alinhado com as oito migrations locais.
3. Advisors de segurança e desempenho sem issues.
4. RLS validado com dois usuários simulados em `supabase/rls-smoke-test.sql`.
5. Falta validar o mesmo percurso pela interface publicada.

Concluído no nível de banco. Falta a validação de produção pela interface: cadastro, login, onboarding, conta, categoria e primeira movimentação.

## P1. Colocar o fluxo financeiro em uso real

1. Dashboard já busca saldos, receitas, despesas e próximos vencimentos no banco.
2. Login e cadastro carregam com `.env.local` apontando para o Supabase remoto.
3. Cadastro via Supabase Auth cria usuário, mas exige confirmação de e-mail antes do login.
4. Percurso confirmado com o primeiro usuário: e-mail confirmado, login, onboarding, conta, movimentação e atualização do dashboard.
5. Segundo usuário confirmado pela interface sem exibir dados do primeiro usuário.
6. Mostrar estados vazios e erros de forma clara nas telas principais.
7. Manter a navegação sem links para rotas ainda não implementadas.

Concluído no fluxo principal: uma pessoa nova consegue entrar, passar pelo onboarding, criar dados financeiros e vê-los no painel sem cruzar dados com outro usuário.

## P2. Fechar os ciclos financeiros já modelados

1. Validar cartões, faturas e parcelamentos com dados reais.
2. Validar o pagamento de compromissos fixos e o comportamento em meses diferentes.
3. Validar orçamento e metas contra as movimentações cadastradas.

Concluído quando cada recurso tiver um fluxo manual reproduzível, sem depender de dados demonstrativos.

## P3. Preparar uma primeira liberação

1. Cobrir com testes os fluxos críticos de autenticação, RLS e criação de movimentação.
2. Manter `npm run lint`, `npm test` e `npm run build` sem falhas antes de cada integração.
3. Revisar a instalação PWA em celular e corrigir apenas os problemas que impedirem o uso básico.

## Depois da primeira liberação

Importação de extrato, Open Finance, alertas e relatórios avançados ficam fora do ciclo atual. Só entram quando o fluxo básico estiver estável com dados reais.
