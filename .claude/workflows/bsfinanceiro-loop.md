# BSFinanceiro Recurring Dev Loop

## Âncora do cron

Este arquivo é apenas a âncora do agendamento recorrente. O workflow completo está em **`docs/dev-workflow.md`** (doc canônico: fases, roles SOL/TERRA/LUA, gates, skills, handoffs, deploy).

## Ciclo por disparo

Preparação → Brainstorm → Spec + Plano → Aprovação → Implementação → Gates → Review (LUA) → Commit + Handoff → Deploy. Um ciclo por fire; também executável sob demanda.

## Cron Schedule

Horário não-alinhado: `17 * * * *` (horária em :17). Sem trabalho elegível (issue `ready-for-agent`, item de roadmap ou pedido), encerrar o ciclo sem mensagem.

## Stop Conditions

- Manual: TaskStop no workflow.
- Auto: 7 dias de expiração do agendamento.
- Error: 3 ciclos consecutivos falhos → pausa + notificação.

*Edite `docs/dev-workflow.md` para ajustar fases, skills, gates ou agendamento.*
