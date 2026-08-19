# Handoff — importação segura de documentos — 2026-08-11

DEPLOYED | issues=#7,#9; related=#3,#8,#10 | production=https://psibrunosg.github.io/bsfinanceiro/ | commit=c4b8c49 | supabase=wgntlhzjyriwhncumjsv

## Entrega publicada

- Fatura Santander textual e contracheque textual passam por PDF temporário privado, extração sem persistência do texto bruto, revisão humana e aplicação financeira transacional/idempotente.
- Importar fatura não paga nem movimenta caixa. Receita de contracheque só nasce quando conta e data são confirmadas.
- Migrations remotas alinhadas até `20260811000010`.
- Quatro Edge Functions ativas com JWT obrigatório e import map; dois jobs horários de limpeza ativos.
- RPCs legadas `create_credit_card` e `receive_patient_earning` endurecidas: `search_path=''`, proprietário/workspace validados, `anon` revogado.
- GitHub Pages publicou `c4b8c49`; `/`, `/entrar`, `/cadastro`, `/cartoes` e `/ganhos` responderam `200` com assets do build.

## Evidências finais

- `npm audit --audit-level=high`: 0 vulnerabilidades.
- `npm run lint`: verde.
- `npm test`: 40 arquivos / 229 testes verdes.
- `npm run build`: 19 rotas estáticas.
- Playwright público: 60/60 em mobile, tablet e desktop.
- Smoke RLS/RPC remoto: verde com roles SQL reais, incluindo owner/cross-owner/anon nas RPCs endurecidas.
- Jobs de limpeza invocados via `pg_net`: ambos `200`, sem pendências no momento da prova.
- Revisão final independente: OK.

## Pendências externas e fora do escopo

- Rotacionar a senha E2E previamente exposta e revogar as sessões correspondentes. Não reutilizar a credencial antiga; só então executar o Playwright autenticado.
- OCR, Open Finance e layouts universais permanecem fora deste ciclo e seguem nas issues #8 e #10.
- Findings legados de lint/advisors não relacionados a esta entrega permanecem dívida separada; nenhum Critical ativo nos dois caminhos financeiros auditados ficou aberto.
