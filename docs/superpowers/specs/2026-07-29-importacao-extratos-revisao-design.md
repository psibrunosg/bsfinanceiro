# Importação de extratos com revisão

## Objetivo

Permitir que uma pessoa importe um extrato CSV de uma conta de caixa, revise o resultado e só então crie as movimentações. OFX será um segundo parser sobre o mesmo fluxo, sem mudar a experiência ou o modelo de revisão.

## Escopo do primeiro incremento

- CSV UTF-8 com cabeçalho; o usuário mapeia data, descrição e valor para colunas do arquivo.
- Um lote pertence a uma conta, workspace e proprietário; o arquivo não é armazenado.
- A prévia classifica cada linha como pronta, duplicada ou inválida. Nenhuma linha é criada em `transactions` durante a análise.
- A confirmação cria somente linhas prontas, como `paid`, com data de competência e pagamento iguais à data importada.
- A deduplicação é determinística por conta, data, valor absoluto, tipo e descrição normalizada. Linhas repetidas no próprio arquivo também são duplicadas.
- Uma inbox na tela Movimentações mostra lotes recentes, seus totais e permite abrir a prévia; o usuário pode descartar um lote pendente.

## Fora de escopo

- OFX neste incremento, integração bancária, Open Finance, PDF, OCR, IA e categorização automática.
- Gravar automaticamente, editar importações já aplicadas ou desfazer lançamentos aplicados.
- Criar contas ou categorias pela importação.

## Modelo e segurança

`transaction_import_batches` registra o lote e seu estado (`pending`, `applied`, `discarded`). `transaction_import_items` registra a prévia normalizada, seu status e, depois de confirmar, a transação criada. Ambos incluem `workspace_id` e `owner_id`, têm RLS por proprietário e chaves compostas para impedir associação entre workspaces. Uma RPC transacional `apply_transaction_import_batch` valida o proprietário, aplica apenas itens prontos e usa uma chave de idempotência estável por item; a RPC pode ser repetida sem duplicar lançamentos.

## Fluxo

1. Em Movimentações, a pessoa escolhe conta e um CSV.
2. O navegador lê o arquivo, apresenta cabeçalhos e pede o mapeamento apenas se os nomes não forem reconhecidos.
3. O navegador envia as linhas normalizadas para um lote pendente. O banco marca duplicatas comparando linhas existentes e itens do lote.
4. A tela mostra totais de prontas, duplicadas e inválidas, com motivo por linha.
5. `Confirmar importação` chama a RPC; sucesso atualiza o lote para `applied` e recarrega o histórico. `Descartar` remove o lote pendente e seus itens.

## Critérios de aceite

- CSV válido com receita e despesa produz prévia sem criar movimentações.
- Duplicatas existentes e repetidas no arquivo não são aplicadas.
- Confirmação repetida não duplica transações.
- Um usuário não lê, descarta ou confirma lote de outro usuário.
- A tela explica linhas inválidas e continua utilizável para as demais.
- Testes cobrem parser, classificação, RPC/idempotência, RLS e interface; lint, testes e build passam.
