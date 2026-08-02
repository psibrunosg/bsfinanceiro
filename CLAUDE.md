# BS Financeiro

Planejador e controlador financeiro pessoal — Next.js 15, React 19, TypeScript, Supabase (Postgres/RLS/Auth), Vitest, Playwright. Deploy estático via GitHub Pages. Projeto Supabase: `wgntlhzjyriwhncumjsv`.

## Workflow

- **Workflow canônico:** `docs/dev-workflow.md` — ciclo Preparação → Brainstorm → Spec+Plano → Aprovação → Implementação → Gates → Review (LUA) → Commit+Handoff → Deploy. Roles SOL/TERRA/LUA.
- **Fonte de candidatos:** `ROADMAP.md` (fases P0–P7) e `docs/PLAN-evolution.md`.
- **Planos/specs:** `docs/superpowers/plans/` e `docs/superpowers/specs/`. Handoffs em `work/handoffs/`.
- **Agente:** `docs/agents/`. Issues em GitHub (`ready-for-agent`).

## Gates mínimos

`npm run lint && npm test && npm run build` — sem erros, antes de integrar.

## Conservação e pausas

- Preservar alterações locais não relacionadas; nunca incluí-las no commit do ciclo.
- Pausar (pedir ao usuário) somente para: risco destrutivo, custo externo, credencial ausente, mudança de escopo ou decisão de negócio sem resposta segura. Decisões reversíveis e dentro do escopo: seguir sozinho.

## Deploy

Branch `main` publica no GitHub Pages. Secrets: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (nunca `service_role`). Migrations aplicadas e validadas no Supabase **antes** de publicar o frontend.
