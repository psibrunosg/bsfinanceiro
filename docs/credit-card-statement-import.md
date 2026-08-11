# Importação revisável de documentos financeiros

## O que está coberto

O BS Financeiro já importa extratos **CSV e OFX** pela inbox de Movimentações. Este ciclo acrescenta dois fluxos de PDF deliberadamente estreitos:

| Fluxo | Entrada aceita | Resultado de revisão | O que não acontece automaticamente |
| --- | --- | --- | --- |
| Fatura de cartão | PDF Santander com texto selecionável e layout textual reconhecido, até 5 MB na tela | compras, parcelas, total declarado, fechamento e vencimento | pagamento da fatura ou movimento de caixa |
| Contracheque | PDF com texto selecionável, até 10 MB, com `CONTRACHEQUE` ou `DEMONSTRATIVO DE PAGAMENTO` e rótulos financeiros reconhecidos | empregador, competência, bruto, descontos e líquido | receita de caixa sem data e conta confirmadas |

O extrator comum rejeita arquivo inválido, maior que 10 MB, com mais de 20 páginas ou sem texto selecionável. Cada tela ainda aplica seu limite menor quando informado acima.

Não há suporte a OCR, PDF escaneado, imagem, OCR remoto, layout universal de bancos/empregadores, Open Finance ou classificação automática. Esses casos falham fechado com um erro recuperável; para OCR, as issues **#8** e **#10** permanecem abertas.

## Fatura Santander

Em **Cartões**, envie a fatura PDF e aguarde o estado `pending_review`. O parser é allow-listed: ele reconhece cabeçalho Santander, fechamento, vencimento, total a pagar e lançamentos lineares. Uma compra parcelada pode conter uma continuação `Total da compra`; se não houver total original, o item exige correção manual antes da confirmação. Data, descrição, valor da parcela, número/quantidade de parcelas e total podem ser revisados, mas a identidade do lançamento permanece protegida.

Ao confirmar, uma única RPC valida a fatura inteira e aplica tudo ou nada. O sistema preserva compra, parcela observada e fatura, impede incompatibilidade de período/fechamento/vencimento e não anexa itens a fatura paga ou cancelada. Repetir a mesma confirmação devolve o resultado anterior; reenviar o mesmo documento não deve duplicar compras ou parcelas.

**Importar não é pagar.** A fatura continua em aberto até que a ação independente **Pagar fatura** seja concluída com a conta e a data escolhidas.

## Contracheque

Em **Ganhos > Contracheques**, a ação **Importar PDF** não altera o cadastro manual nem o anexo privado existente. O documento temporário gera uma prévia com empregador, competência, bruto, descontos e líquido; valores são conferidos em centavos e devem obedecer `bruto - descontos = líquido`.

Na confirmação, o contracheque pode ser salvo sem receita. Para criar receita, informe **ambos** data de recebimento e conta de caixa; a RPC então cria o contracheque e, quando cabível, a receita em uma única transação. Empregador + competência duplicados são recusados e a repetição de uma confirmação bem-sucedida é idempotente.

## Privacidade, estados e recuperação

- PDFs ficam somente em buckets privados temporários, sob o proprietário e o job correspondente.
- O texto bruto extraído fica apenas em memória. Banco e logs de contrato guardam checksum, versão do parser, campos estruturados e um erro curto — nunca o PDF ou seu texto.
- Estados usuais: `pending` → `processing` → `pending_review` → `imported`; falhas vão para `failed` e a revisão pode ser descartada. Jobs importados permanecem como tombstones para garantir idempotência.
- O objeto temporário só é removido depois que o estado terminal foi persistido. Se a limpeza falhar, o job permanece rastreável para nova tentativa, sem reaplicar finanças.
- Jobs pendentes/em processamento expirados são marcados como falhos para que a tentativa seja renovada com segurança.

As RPCs derivam o usuário autenticado e validam workspace, cartão, conta e contexto. O cliente não recebe `service_role`, não consegue editar estados protegidos nem escolher a identidade de itens importados.

## Operação e validação de publicação

O fluxo foi publicado em 11/08/2026 após alinhamento das migrations, smoke remoto de RLS/RPC, publicação das Edge Functions com o import map, validação dos jobs de limpeza e deploy do frontend. O gate autenticado de Playwright só pode voltar a rodar com `E2E_EMAIL` e `E2E_PASSWORD` externos, após rotação da senha que já foi exposta e revogação das sessões correspondentes. Não reutilize a credencial antiga.
