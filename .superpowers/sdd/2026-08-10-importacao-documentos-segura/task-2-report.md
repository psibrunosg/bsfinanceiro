# Task 2 — extractor PDF compartilhado

## RED

- Antes de criar `pdf-text.ts`, foram criados um fixture PDF real com objetos, xref e stream de texto (`pdf-test-fixture.ts`) e cinco cenários em `pdf-text.test.ts`.
- Comando: `npx vitest run supabase/functions/_shared/pdf-text.test.ts`
- Resultado: falhou como esperado, `5 failed`; todos os cenários informaram `expected null not to be null` porque `./pdf-text` ainda não existia. Os cenários especificam PDF textual de uma página, header inválido, mais de 10 MiB, 21 páginas e PDF sem texto.

## GREEN

- Implementado `extractSelectablePdfText(bytes)` no módulo Edge compartilhado: header `%PDF-`, limite de 10 MiB antes do parser, extração com `unpdf`, limite de 20 páginas, normalização de whitespace e códigos exatos.
- O texto bruto não é persistido. `rawText` é uma referência local descartada após a normalização; JavaScript não permite zeroizar strings imutáveis.
- Primeiro GREEN revelou `TypeError: document?.destroy is not a function`. A investigação no tipo instalado mostrou que `destroy()` pertence a `PDFDocumentLoadingTask`, enquanto `PDFDocumentProxy` expõe `cleanup()`. Corrigido para ambos os métodos; não houve mudança nos pipelines de cartão ou contracheque.
- Comando: `npx vitest run supabase/functions/_shared/pdf-text.test.ts`
- Resultado final: `1 passed`, `5 passed` (121 ms).

## Dependência e runtime

- `unpdf` está pinado como `devDependency` exata `1.8.0` em `package.json` e lockfile; não foi adicionada a `dependencies` do Next.
- `supabase/functions/import_map.json` mapeia o import bare `unpdf` para `npm:unpdf@1.8.0`. O módulo compartilhado importa `from "unpdf"`, portanto o teste Node executa o mesmo nome de módulo que o Edge resolverá.
- Evidência estática: `npm ls unpdf --depth=0` retornou `unpdf@1.8.0`; a checagem JSON do import map retornou `EDGE_IMPORT_MAP_OK`.

## Runtime Edge

- `deno` e `docker` não estão instalados: `DENO_UNAVAILABLE` e `DOCKER_UNAVAILABLE`.
- A CLI Supabase disponível é 2.110.0. `supabase functions deploy --dry-run` retornou `Unrecognized flag: --dry-run`; `supabase functions deploy --help` confirma `--import-map`, mas não um modo dry-run/bundle local.
- Nenhum deploy foi tentado, pois o único caminho de bundle oferecido pela CLI publica uma Function. Portanto, não há verificação de execução/deploy Edge; a evidência disponível é o teste Node do módulo bare-import, o import map validado e o build Next sem `unpdf` nas dependências de produção.

## Gates e auto-revisão

- `npm audit`: `found 0 vulnerabilities`.
- `npm run lint`: exit 0.
- `npm test`: `33 passed`, `173 passed`.
- `npx tsc --noEmit --pretty false`: exit 0.
- `npm run build`: exit 0 com `NEXT_PUBLIC_SUPABASE_URL=https://example.supabase.co` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=test-publishable-key`, usados somente para satisfazer o pré-render estático sem acesso externo. Sem essas variáveis, o build falha no pré-render de `/investimentos` pela configuração já existente.
- `git diff --check`: exit 0.
- Revisão de escopo: somente o módulo/fixture/teste PDF, import map, devDependency/lock e este relatório foram alterados; os pipelines de cartão e contracheque permanecem intocados.

## Correção da revisão 1

- RED: `npx vitest run supabase/functions/_shared/pdf-text.test.ts` resultou em `3 failed`, provando que um documento com `numPages: 21` entrava em `extractText` e que rejeições de `cleanup()`/`destroy()` substituíam tanto o resultado quanto `pdf_too_many_pages`.
- GREEN: `document.numPages` agora é validado logo após `getDocumentProxy`, antes de `extractText`. Limpeza e destruição são best-effort, com rejeições suprimidas para preservar sucesso e os códigos PDF primários.
- Os novos testes usam um mock estreito de `unpdf` somente para o contrato de ordem e falhas de limpeza; o fixture PDF real continua cobrindo o caminho de integração Node.
- Verificação final: scoped `8 passed`; `npm audit` sem vulnerabilidades; lint e `npx tsc --noEmit --pretty false` com exit 0; `npm test` com `33 passed`, `176 passed`; build com variáveis públicas sintéticas exit 0; `git diff --check` exit 0.
