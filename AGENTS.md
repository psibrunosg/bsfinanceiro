## Agent skills

### Issue tracker

Issues and PRDs live in GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

The repository uses the default five-role triage vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs

This is a single-context repository: use root `CONTEXT.md` and `docs/adr/` when they exist. See `docs/agents/domain.md`.

### Planos de desenvolvimento

Sempre que o usuário pedir um plano de desenvolvimento:

1. Investigue primeiro o repositório, o domínio, as migrations, as alterações locais e a documentação existente.
2. Organize o plano por entregas verticais, com critérios de aceite, dependências, riscos e ordem de execução.
3. Inclua uma seção chamada "Skills previstas", relacionando cada skill à etapa em que será usada e à evidência que deverá produzir.
4. Inclua um workflow autônomo com preparação, execução, testes, banco, versionamento, deploy, recuperação de falhas e definição de pronto.
5. Defina os gates mínimos: lint, testes, build, acessibilidade, responsividade, segurança, migrations e verificação de produção.
6. Autorize o agente a seguir sozinho em decisões reversíveis e dentro do escopo. Exija pausa somente para risco destrutivo, custo externo, credencial ausente, mudança de escopo ou decisão de negócio sem resposta segura.
7. Preserve alterações locais não relacionadas e nunca as inclua no commit do plano ou da implementação.
8. Depois da aprovação, salve o plano na pasta de auditoria do projeto e atualize o handoff.
