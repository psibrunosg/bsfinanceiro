# Finanças pessoais simples e orientadas à decisão

## Problema

O BS Financeiro já modela contas, cartões, lançamentos, compromissos, orçamento, metas e alertas. Para uma pessoa física, porém, esses conceitos aparecem como módulos e formulários independentes. A pessoa precisa decidir conta, categoria, tipo e datas antes de obter uma resposta prática: se pode gastar agora sem comprometer os próximos dias.

## Objetivo do primeiro ciclo

Entregar uma experiência de pessoa física centrada em duas promessas:

1. Abrir o app e saber quanto pode gastar até a próxima entrada prevista.
2. Registrar uma entrada ou saída em poucos segundos, deixando os detalhes opcionais e editáveis depois.

O painel passa a ser o ponto de entrada diário. Contas, categorias, cartões, compromissos e planejamento continuam disponíveis, mas deixam de ser a navegação primária.

## Experiência

- O painel mostra `Disponível para gastar`, a data da próxima entrada prevista e uma explicação curta do cálculo.
- O cálculo parte do saldo atual das contas de caixa, soma movimentações pagas posteriores ao saldo inicial e reserva compromissos fixos ainda não pagos até a próxima receita planejada. Contas de cartão e investimentos não entram no dinheiro disponível.
- Um único botão `Registrar movimentação` abre um formulário compacto: valor e descrição são obrigatórios; tipo começa em despesa; conta começa na conta principal; categoria e data ficam em `Mais detalhes`.
- Cada pessoa pode definir uma conta principal. Sem ela, o formulário mostra a escolha de conta como obrigatória e oferece um atalho para defini-la.
- A tela de movimentações vira o histórico pesquisável e filtrável. O formulário completo permanece acessível em `Mais detalhes`, não como a primeira tarefa da tela.
- A navegação principal fica em `Painel`, `Movimentações` e `Planejamento`; configurações e cadastros estruturais ficam em uma área `Mais`.

## Limites deste ciclo

- Não inclui Open Finance, integração com banco, leitura de PDF, OFX ou CSV.
- Não inclui categorização automática, inbox de revisão, regras por estabelecimento, IA, voz ou WhatsApp.
- Não altera a separação pessoal/negócio. Essa dimensão será introduzida depois que o fluxo pessoal estiver estável.
- Não inicia pagamentos, Pix ou cobranças.

## Próximos ciclos deliberadamente separados

1. Importação OFX/CSV com prévia, deduplicação e inbox de revisão.
2. Regras de normalização e categorização aprendidas com correções do usuário.
3. Contexto pessoal/negócio, retirada e fluxo de caixa para MEI.

## Critérios de aceite

- Com uma conta principal e compromissos futuros, o painel apresenta um valor disponível consistente e explica quais reservas foram descontadas.
- Uma despesa pode ser registrada com valor e descrição, usando a conta principal e a data de hoje sem abrir campos adicionais.
- Se não existir conta principal, a pessoa não consegue salvar sem escolher uma conta e recebe uma mensagem acessível explicando o motivo.
- Cartões de crédito, investimentos, transferências e movimentações planejadas não distorcem o valor disponível.
- O histórico permite encontrar uma movimentação por descrição e limitar a visualização por tipo e período.
- As rotas existentes continuam acessíveis e os testes, lint e build passam.

## Verificação do ciclo

O cenário manual reproduzível está no README: criar uma conta corrente como principal, registrar uma renda planejada futura, criar um compromisso fixo, abrir o painel e conferir a reserva, lançar uma despesa rápida e encontrá-la pelo histórico. A verificação automática roda `npm run lint`, `npm test` e `npm run build`.

Com isso, este ciclo entrega conta principal, saldo real, disponibilidade projetada, registro simples, navegação e histórico. Importação, regras de categorização e contexto MEI permanecem fora do escopo; o próximo ciclo é importação OFX/CSV com prévia, deduplicação e inbox de revisão. Open Finance não foi implementado.
