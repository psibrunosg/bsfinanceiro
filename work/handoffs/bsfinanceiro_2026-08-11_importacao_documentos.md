# Handoff — importação segura de documentos — 2026-08-11

READY_FOR_DEPLOY | issue= #7; related=#8,#10 | goal=importação revisável de fatura Santander e contracheque textual | scope=segurança E2E, extração Edge, revisão/aplicação idempotente, documentação | out_of_scope=OCR, Open Finance, layouts universais, reescrita de histórico Git | dependencies=Supabase remoto e credencial E2E rotacionada | risks=migrations/Edge/smoke ainda não executados no remoto

## Mudanças entregues no branch

- Credenciais E2E removidas do HEAD; specs autenticadas só entram quando `E2E_EMAIL` e `E2E_PASSWORD` externos existem. A senha previamente exposta ainda requer rotação e revogação de sessões fora do código.
- `npm audit` foi reduzido a **0 vulnerabilidades**.
- Extrator PDF Edge compartilhado valida cabeçalho, tamanho, páginas e texto selecionável; não persiste texto bruto.
- Fatura Santander textual cria candidatos revisáveis e aplica fatura/compras/parcelas em uma RPC transacional e idempotente. Importar não paga a fatura nem lança caixa.
- Contracheque textual cria draft revisável. Receita é opcional e só é criada junto ao contracheque quando data e conta de recebimento são confirmadas.
- Jobs e objetos temporários mantêm rastreabilidade para limpeza/retry e preservam identidade durável após importação.

## Evidências locais registradas

- `npm audit`: 0 vulnerabilidades.
- `npm run lint`: verde.
- `npm test`: 37 arquivos / 209 testes verdes **antes do último fix** deste ciclo; repetir a suíte completa no HEAD antes do deploy.
- `npm run build`: verde, 19 rotas estáticas.
- Reviews finais: Task 3 (fatura) **OK** e Task 4 (contracheque) **OK**.
- `git diff --check`: verde no escopo revisado.

## Gates ainda obrigatórios — não executar frontend antes deles

1. Conferir `supabase migration list` e alinhar o histórico local/remoto.
2. Aplicar migrations `20260811000000` a `20260811000005` no Supabase remoto.
3. Publicar/validar as Edge Functions e o import map de `unpdf` no runtime Edge.
4. Executar `supabase/rls-smoke-test.sql` contra o banco remoto e revisar advisors relevantes.
5. Repetir audit, lint, testes, build, Playwright público e `git diff --check` no HEAD final.
6. Com credencial externa já rotacionada, executar Playwright autenticado para P2.7 e hubs em 375/1440 px; sem ela, registrar bloqueio sem reutilizar o segredo antigo.
7. Só após os gates de banco e frontend, integrar em `main`, aguardar GitHub Pages e verificar produção.

## Estado de produção

**Não concluído.** Banco, Edge Functions, smoke remoto e deploy do frontend continuam pendentes neste handoff. OCR continua nas issues #8 e #10.
