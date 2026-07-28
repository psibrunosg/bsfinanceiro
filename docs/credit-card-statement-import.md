# Importação de fatura de cartão (infraestrutura experimental)

Os arquivos ficam no bucket privado `credit-card-statements`, limitado a 5 MB. O navegador nunca recebe uma chave `service_role`; ela é usada somente pelas Edge Functions para reclamar e finalizar jobs.

Neste estágio **não há suporte a PDF real, OCR, heurística, LLM, banco ou emissor**. Um PDF ou qualquer layout desconhecido termina em `failed / unsupported_format`, sem criar compra, parcela ou fatura.

O único formato aceito pelo worker é a fixture de texto sintética abaixo, enviada como `text/plain`:

```text
BSFINANCEIRO_STATEMENT_FIXTURE_V1
{"description":"Compra de teste","totalAmount":42.5,"purchasedOn":"2026-07-28","installmentCount":1,"categoryId":null,"notes":"fixture"}
```

O job é deduplicado por cartão + SHA-256 do arquivo, e o worker recalcula esse checksum depois de baixar o objeto. Jobs em `processing` podem ser reclamados novamente após 10 minutos, usando a mesma chave de idempotência de compra. Isso evita duplicação se a função for interrompida entre criar a compra e concluir o job.

Depois de `imported` ou `failed`, o worker tenta remover o objeto privado. A função `cleanup-credit-card-statement-imports` deve ser agendada com credencial de serviço: ela cobre também jobs `pending` e `processing` expirados, e só apaga o registro quando a remoção do objeto confirma sucesso; falhas permanecem para nova tentativa.
