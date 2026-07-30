# BSFinanceiro Recurring Dev Loop

## Overview
Cron-triggered cycle: **Brainstorm → Plan → Build → Review → Commit**. One cycle per fire.

## Role Separation (Strict)
| Role | Agents | Must NOT |
|------|--------|----------|
| **Manager** | 1 (`planner` agent) | write code, review |
| **Executors** | 2-3 (`coder` agents, parallel) | review own work |
| **Reviewers** | 2-3 (`reviewer` agents, parallel) | write code, merge |

## Cycle Flow

```
1. BRAINSTORM (manager)
   skill: superpowers:brainstorming
   input: repo state, last cycle outcomes
   output: 2-3 feature/improvement candidates
       |
       v
2. PLAN (manager)
   skill: superpowers:writing-plans
   output: cycle-<N>-plan.md (spec + task breakdown + file map)
       |
       v
3. BUILD (executors, parallel)
   each executor: disjoint file set from plan
   skill: ecc:feature-dev
   output: diffs in working tree
       |
       v
4. REVIEW (reviewers, parallel)
   A: superpowers:code-review (high)
   B: ecc:security-scan
   C: ecc:ponytail-audit
   D: ui-ux-pro-max (if UI touched)
   manager aggregates findings
   gate: block on CRITICAL, warn on MAJOR
       |
       v
5. COMMIT (manager)
   pass: commit with cycle tag
   fail: create issue, revert diffs
       |
       v
   LOOP (cron re-fires)
```

## Skill Mapping
| Need | Skill/Tool |
|------|------------|
| Ideation | superpowers:brainstorming |
| Spec/plan | superpowers:writing-plans |
| Implementation | ecc:feature-dev |
| Code review | superpowers:code-review |
| Security scan | ecc:security-scan |
| Simplification | ecc:ponytail-audit / ponytail:ponytail |
| UI/UX review | ui-ux-pro-max:ui-ux-pro-max |
| Skill discovery | search available-skills list |

## Stop Conditions
- Manual: TaskStop on workflow task ID
- Auto: 7-day cron expiry
- Error: 3 consecutive failed cycles -> pause + notify

## Cron Schedule
Non-aligned minute: `17 * * * *` (hourly at :17).

*Edit this file to adjust phases/agents/skills.*