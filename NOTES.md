# Notes

- Product: BS Financeiro, Next.js and Supabase personal-finance application.
- Work enters through GitHub Issues labelled `ready-for-agent`, roadmap items (`ROADMAP.md`) or user requests.
- **Workflow canônico:** `docs/dev-workflow.md` — ciclo recorrente (cron) com fases, gates, skills e deploy. Referenciado por `CLAUDE.md`.
- Roles: SOL is manager; TERRA is executor; LUA performs the reviewer role. One role never performs another role's work. Sem LUA disponível, o ciclo para em `WAITING_FOR_LUA`.
- O antigo gate de quota semanal do Codex desktop foi removido; o loop ancorado em GitHub Issues + quota está arquivado em `docs/archive/continuous-development-loop.md`.
