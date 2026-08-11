# Importação segura de documentos financeiros — Design

## Objetivo

Eliminar credenciais versionadas e transformar PDFs com texto selecionável em dados financeiros revisáveis, preservando privacidade, atomicidade, idempotência e a semântica de faturas/parcelas.

## Escopo aprovado

1. Remover credenciais do teste P2.7 e executar testes autenticados somente com `E2E_EMAIL` e `E2E_PASSWORD` externos ao Git.
2. Corrigir dependências com advisories altos sem salto de versão major.
3. Processar PDFs temporários em Edge Functions autenticadas. O texto bruto nunca é persistido; o objeto temporário é removido após estado terminal.
4. Interpretar inicialmente faturas Santander com texto selecionável e contracheques com rótulos financeiros reconhecíveis. Layout ambíguo falha fechado.
5. Persistir apenas candidatos estruturados em estado `pending_review`; o usuário revisa antes da aplicação financeira.
6. Aplicar uma fatura inteira por RPC transacional e idempotente, preservando compra, parcela observada e fatura. Importar não equivale a pagar.
7. Aplicar um contracheque por RPC transacional e idempotente. Receita de caixa só nasce quando data e conta de recebimento forem confirmadas.
8. Manter OCR fora deste ciclo. PDFs escaneados recebem erro recuperável e continuam cobertos pelas issues #8 e #10.

## Arquitetura

O frontend estático cria um job, envia o PDF a um bucket privado e invoca a Edge Function. Um módulo Edge compartilhado, usando `unpdf` pinado, valida `%PDF-`, tamanho, páginas e texto selecionável. Parsers puros convertem o texto em candidatos allow-listed. O texto extraído existe apenas em memória.

O pipeline de fatura amplia `credit_card_statement_imports` com metadados do parser e uma tabela filha de itens estruturados. A Edge Function termina em `pending_review`; a confirmação chama `apply_credit_card_statement_import`, que bloqueia o job, valida todos os itens, cria/reutiliza fatura, compras e parcelas e termina em `imported` na mesma transação.

O contracheque ganha `payslip_document_imports` e um bucket/prefixo temporário separado do anexo permanente já existente. A Edge Function produz um draft estruturado `pending_review`; o usuário completa/corrige campos e chama `apply_payslip_document_import`. O fluxo manual e os anexos privados atuais continuam disponíveis.

## Estados

```text
pending -> processing -> pending_review -> imported
                        \-> failed
pending/processing expirado -> failed
pending_review -> discarded
```

`failed` pode voltar a `pending` com o mesmo checksum e chaves idempotentes. `imported` não volta. Falha de limpeza do objeto mantém o job para retry da limpeza, sem reprocessar dados.

## Contratos estruturados

```ts
type CardStatementCandidate = {
  ordinal: number;
  purchasedOn: string;
  description: string;
  installmentAmountCents: number;
  installmentNumber: number;
  installmentCount: number;
  totalAmountCents: number | null;
  sourceFingerprint: string;
};

type PayslipCandidate = {
  employer: string;
  competence: string;
  grossAmountCents: number;
  discountsAmountCents: number;
  netAmountCents: number;
};
```

Datas são ISO locais. Valores financeiros são inteiros em centavos até a fronteira SQL. Ausência de total original numa compra parcelada gera warning e exige correção humana antes da confirmação.

## Segurança e privacidade

- Nenhuma credencial, token, `storageState`, PDF, imagem ou texto extraído entra no Git.
- Buckets temporários são privados, limitados e isolados por prefixo do proprietário e job pendente.
- Service role permanece somente nas Edge Functions.
- RPCs de aplicação derivam `auth.uid()`, validam workspace/cartão/conta/contexto e usam `security invoker` quando possível; qualquer `security definer` usa `search_path = ''` e não confia em owner enviado.
- Chaves idempotentes derivam do job e do fingerprint estruturado. Repetir o mesmo arquivo não duplica compras, parcelas, contracheques ou receitas.
- A senha já exposta deve ser trocada e sessões revogadas fora do código. Reescrita de histórico e force-push exigem autorização separada.

## Erros observáveis

- `pdf_without_selectable_text`: PDF escaneado ou vazio; OCR indisponível.
- `unsupported_layout`: emissor/layout não reconhecido.
- `ambiguous_financial_fields`: valores/datas conflitantes.
- `statement_total_mismatch`: total declarado difere dos itens.
- `duplicate_payslip`: empregador + competência já existem.
- `processing_failed`: falha recuperável sem persistência parcial.

## Critérios de aceite

- O HEAD não contém `TEST_EMAIL`/`TEST_PASSWORD`; sem credenciais externas, specs autenticadas são omitidas com segurança.
- Com credenciais externas, P2.7 e snapshots usam o mesmo `storageState`.
- Um PDF textual real é extraído no runtime Edge ou em teste compatível; PDFs inválidos, vazios, escaneados, grandes ou extensos falham fechado.
- Jobs persistem apenas candidatos estruturados, checksum, versão do parser e erro curto; nunca texto bruto.
- Fatura multi-item é all-or-nothing e idempotente; pagamento permanece separado.
- Contracheque importado não cria receita sem data e conta confirmadas.
- RLS bloqueia acesso cruzado e mutação direta de estados/itens protegidos.
- `npm audit`, lint, testes, build, smoke SQL/RLS e viewports 375/768/1440 não têm falhas bloqueantes.

## Fora do escopo

OCR, Open Finance, e-mail, classificação por IA, suporte universal a emissores, retenção do texto bruto e reescrita destrutiva do histórico Git.
