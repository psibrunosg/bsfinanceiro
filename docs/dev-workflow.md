# Workflow de desenvolvimento — BS Financeiro

> Doc canônico do ciclo de desenvolvimento. Referenciado por `CLAUDE.md` (raiz), `AGENTS.md` e `.claude/workflows/bsfinanceiro-loop.md`. Substitui os antigos loops (`workflows/continuous-development-loop.md` arquivado em `docs/archive/`).

## Visão geral

Pipeline de um ciclo: **Preparação → Brainstorm → Spec + Plano → Aprovação → Implementação → Verificação/Gates → Review (LUA) → Commit + Handoff → Deploy**. Um ciclo por disparo; também executável sob demanda.

```
Preparação
   │ (lê docs/, ROADMAP, git status, migrations)
   ▼
Brainstorm ──▶ Spec + Plano ──▶ Aprovação ──▶ Implementação ──▶ Gates
   │  (2-3 candidatos)   (vertical, AC,       │ (usuário)   (testes-first)   │
   │                      skills previstas)   ▼                              ▼
   └────────────────────────────── TERRA  ◀── Aprova        Review (LUA) ──▶ Commit
                                              │              (ACCEPTED/       + Handoff
                                              │              CHANGES_REQUESTED)│
                                              │                              ▼
                                              └────────────── TERRA corrige ◀─ Deploy
```

## Roles (separação estrita)

| Role | Papel | Não pode |
|------|-------|----------|
| **SOL** | Manager: investiga repositório, define escopo/brief, agrega findings, commita | editar código, revisar diffs |
| **TERRA** | Executor: implementa testes-first, verifica gates, prepara `READY_FOR_LUA` | mudar escopo, aprovar próprio trabalho |
| **LUA** | Reviewer: `ponytail-review`, correção; `impeccable` + `ui-ux-pro-max` em UI | implementar, repriorizar |

Uma role nunca executa a tarefa de outra. Sem LUA disponível, o ciclo para em `WAITING_FOR_LUA`; SOL/TERRA não substituem o papel.

## Gatilho e agendamento

- **Loop recorrente (cron)** — horário não-alinhado (ex.: `17 * * * *`, ajustável em `.claude/workflows/bsfinanceiro-loop.md`).
- Cada ciclo inicia com a fase de **Preparação** (nunca pula).
- Também disparável manualmente por SOL ou pelo usuário.

## Fases

### 1. Preparação
- Ler `docs/PLAN-evolution.md`, `ROADMAP.md`, specs/plans recentes em `docs/superpowers/`.
- `git status` e `git log` recente; conferir migrations locais vs. remotas.
- **Preservar alterações locais não relacionadas** — nunca entram no commit do ciclo.
- Decidir se o disparo tem trabalho elegível (issues `ready-for-agent`, item de roadmap, pedido do usuário). Sem trabalho → encerrar o ciclo sem mensagem.

### 2. Brainstorm
- Skill: `brainstorming`.
- Saída: 2–3 candidatos de feature/melhoria vindos de `ROADMAP.md` e itens não concluídos do `PLAN-evolution.md` (ex.: gráficos/alertas P4, importação P5).

### 3. Spec + Plano
- Skills: `writing-plans`.
- Entregas **verticais**, cada uma com critérios de aceite, dependências, riscos e ordem de execução.
- Seção obrigatória **"Skills previstas"**: skill → etapa → evidência produzida.
- Artefatos: `docs/superpowers/specs/<data>-<slug>-design.md` e `docs/superpowers/plans/<data>-<slug>.md`.

### 4. Aprovação
- Apresentar plano ao usuário. **Pausa obrigatória** antes de TERRA quando houver:
  1. risco destrutivo (reset/drop/rollback destrutivo),
  2. custo externo (serviço pago, quota),
  3. credencial ausente (ex.: acesso ao Supabase remoto),
  4. mudança de escopo,
  5. decisão de negócio sem resposta segura.
- Decisões reversíveis e dentro do escopo: agente segue sozinho (autorizado por padrão).

### 5. Implementação (TERRA)
- Skills: `executing-plans` (ou `subagent-driven-development` quando houver paralelismo).
- Testes primeiro quando aplicável; arquivos disjuntos por executor quando em paralelo.
- Nunca inserir em `transactions`/novas tabelas fora das RPCs/RPCs idempotentes definidas.

### 6. Verificação / Gates mínimos
1. `npm run lint` — 0 erros.
2. `npm test` — passando; preservar os existentes, adicionar para mudanças.
3. `npm run build` — exit 0 (`output: "export"`, sem rotas dinâmicas).
4. **Acessibilidade** — estados de processamento/erro com texto e semântica (ex.: `role=status`, `fieldset disabled`), nunca só cor.
5. **Responsividade** — 375 / 768 / 1024 / 1440 px, claro/escuro, teclado e movimento reduzido.
6. **Segurança** — RLS por `owner_id`/`workspace_id` em toda tabela nova, grants explícitos, advisors de segurança/desempenho sem issues.
7. **Migrations** — criadas pelo CLI, rollback revisado, aplicadas e validadas **no Supabase antes** do frontend.
8. **Verificação de produção** — cenário manual do `README.md` ou Playwright com Supabase simulado.

### 7. Review (LUA)
- Skills: `ponytail-review`, `code-review`, `security-and-hardening`, `ponytail-audit` (só se simplificação repo-wide), `impeccable` + `ui-ux-pro-max` (UI afetada).
- Retorna **somente** `ACCEPTED` ou `CHANGES_REQUESTED`.
- `CHANGES_REQUESTED` → TERRA corrige apenas os findings listados e repete passos 5–7.

### 8. Commit + Handoff
- Commit com tag do ciclo; mensagem descreve a entrega vertical.
- Atualizar `work/handoffs/bsfinanceiro_<timestamp>.md` com: mudanças, evidências (lint/test/build), dependências, riscos, `READY_FOR_*`.
- **Recuperação de falhas:** 3 ciclos consecutivos falhos → pausa + notificação ao usuário. Falha pontual → registrar no handoff e retomar no próximo disparo.

### 9. Deploy
- Migrations: `supabase db push` (após revisão de rollback + advisors) → validar consultas no remote.
- Frontend: branch `main` publica no GitHub Pages; secrets `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (nunca `service_role`).

## Skills previstas (mapa)

| Skill | Etapa | Evidência |
|-------|-------|-----------|
| `brainstorming` | 2 | lista de candidatos |
| `writing-plans` | 3 | spec + plano com AC/dependências/riscos |
| `executing-plans` / `subagent-driven-development` | 5 | diffs em árvore de trabalho |
| `verification-before-completion`, `qa` | 6 | saída dos gates |
| `ponytail-review`, `code-review`, `security-and-hardening`, `ponytail-audit`, `impeccable`, `ui-ux-pro-max` | 7 | veredito `ACCEPTED`/`CHANGES_REQUESTED` |

Nomes resolvidos na lista de skills disponíveis da sessão.

## Handoffs

```text
READY_FOR_EXECUTOR | issue= | goal= | scope= | out_of_scope= | acceptance= | risks= | dependencies=
READY_FOR_LUA     | issue= | commit= | files= | evidence= | ux_a11y= | dependencies= | risks=
CHANGES_REQUESTED | severity= | finding= | location= | expected_fix=
ACCEPTED          | issue= | coverage= | residual_risks=
```

## Definição de pronto

Ciclo concluído quando: gates 1–8 passam, LUA retorna `ACCEPTED`, commit + handoff atualizado, migrations aplicadas/validadas no Supabase, frontend publicado (ou decisão explícita de postergar deploy). Trabalho sem issue ou sem aprovação não é executado.

*Edite este arquivo para ajustar fases, skills, agendamento ou gates.*
