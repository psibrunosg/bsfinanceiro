# Financeiro diário, cadastro rápido e importação de PDFs

## Problema

Registrar a vida financeira ainda exige muitos campos e a leitura manual de faturas e contracheques. O painel atual mostra dados estáticos, sem orientar qual é a decisão mais importante do dia.

## Solução

Criar um primeiro ciclo de decisão financeira: cadastro inicial em até 60 segundos, painel diário com projeção e uma ação prioritária, e importação automática de faturas de cartão e contracheques. PDFs são processados em segundo plano; o sistema tenta texto selecionável antes de OCR, grava apenas dados estruturados e descarta o arquivo. Não haverá tela de confirmação antes de salvar, mas haverá correção posterior e bloqueio determinístico de duplicatas.

## Experiência

- Cadastro inicial: nome, renda mensal, saldo atual e cartões. Informações extras continuam opcionais.
- Painel `Hoje`: saldo projetado até o próximo pagamento, um alerta priorizado e uma ação rápida para registrar despesa, receita, cartão ou meta.
- Importação: usuário envia ou solta PDF e recebe estados `processando`, `importado` ou `falhou`.
- Fatura: gera lançamentos ligados ao cartão e atualiza sua visão financeira.
- Contracheque: gera receita e participa da projeção de caixa.
- Correção: lançamentos importados podem ser corrigidos depois da gravação.

## Decisões de implementação

- O processamento recebe o arquivo temporariamente, extrai texto quando disponível e usa OCR apenas quando não houver texto selecionável útil.
- O processamento acontece em segundo plano e nunca bloqueia a navegação.
- O arquivo PDF e qualquer imagem intermediária são descartados ao concluir ou falhar; somente campos financeiros estruturados e metadados mínimos permanecem.
- A fonte do lançamento identifica a importação, com competência, hash do conteúdo e estado de processamento para rastreabilidade e idempotência.
- Fatura duplicada é bloqueada por cartão, competência e valor total. Contracheque duplicado é bloqueado por empregador, competência e valor líquido.
- Se extração, validação ou gravação falhar, nenhum lançamento parcial é salvo; o usuário vê o motivo e pode tentar novamente.
- Projeção de caixa e priorização de alertas permanecem regras puras, separadas da interface. O painel consome apenas resultados calculados.
- O alerta principal considera severidade, impacto e relevância temporal; o painel apresenta somente o alerta mais útil para evitar sobrecarga.

## Histórias de usuário

1. Como pessoa que começa a organizar as finanças, quero cadastrar os dados essenciais rapidamente para chegar ao painel sem preencher formulários longos.
2. Como usuário, quero ver meu saldo projetado até o próximo pagamento para saber se posso gastar com segurança.
3. Como usuário, quero receber só o alerta financeiro mais importante para agir sem ser soterrado por notificações.
4. Como usuário, quero registrar uma receita ou despesa pela ação rápida para manter a projeção confiável.
5. Como titular de cartão, quero importar uma fatura em PDF para não digitar cada compra.
6. Como trabalhador, quero importar meu contracheque para registrar renda recorrente sem preenchimento manual.
7. Como usuário, quero que PDFs com texto sejam lidos diretamente e escaneados usem OCR para importar ambos os formatos.
8. Como usuário, quero continuar navegando enquanto o PDF é processado para não ficar preso numa tela de espera.
9. Como usuário, quero saber se uma importação está processando, terminou ou falhou para agir no momento certo.
10. Como usuário, quero que o sistema descarte o PDF após extrair os dados para reduzir exposição de informações sensíveis.
11. Como usuário, quero que uma fatura já importada seja bloqueada para não duplicar despesas.
12. Como usuário, quero que um contracheque já importado seja bloqueado para não duplicar renda.
13. Como usuário, quero corrigir lançamentos importados posteriormente para ajustar interpretações erradas sem refazer a importação.
14. Como usuário, quero que falhas não deixem lançamentos incompletos para manter meus dados consistentes.

## Testes

- Testar comportamento observável, não detalhes internos de componentes.
- Cobrir extração de PDF com texto, encaminhamento para OCR e descarte do arquivo temporário.
- Cobrir criação correta de lançamentos de fatura e contracheque, falha atômica e reprocessamento após erro.
- Cobrir as chaves de duplicidade definidas para fatura e contracheque.
- Cobrir projeção e ordenação de alertas como funções puras, seguindo o padrão de testes financeiros existente.
- Cobrir os estados de importação e a ação rápida na interface, seguindo os testes de componentes existentes.

## Fora de escopo

- Armazenar PDFs, imagens, holerites ou OCR bruto.
- Confirmação manual antes de gravar importações.
- Integração bancária, e-mail, WhatsApp ou Open Finance.
- Recomendações financeiras prescritivas, pontuação de crédito ou automação de pagamentos.
- Classificação perfeita de todos os layouts bancários no primeiro ciclo.

## Notas

O primeiro ciclo privilegia transparência e correção posterior: automação sem confirmação prévia, com status, rastreabilidade mínima e bloqueio de duplicidade. A importação precisa operar com fornecedores e limites de OCR ainda a definir no plano técnico; essa escolha não muda a experiência nem a regra de descarte.
