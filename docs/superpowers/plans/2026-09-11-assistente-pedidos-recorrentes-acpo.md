# Plano de Desenvolvimento: Assistente de Pedidos Recorrentes ACPO (Frutas & Doces no n8n)

Implementação e deploy no n8n do workflow de suprimentos recorrentes da ACPO Empreendimentos, integrando agendamento automatizado, validação de calendário mensal, mensageria via WhatsApp (OpenWA) e aprovação inteligente com IA (Human-in-the-loop).

---

## 1. Contexto e Objetivos

O usuário solicitou a automação de duas compras corporativas recorrentes da ACPO:
1. **Frutas (Semanal):** Toda segunda-feira às 09:00, consulta de aprovação no WhatsApp do gestor (Bruno) e posterior envio ao Hortifruti (`55 53 9147-6380`) para entrega na terça-feira às 09:30.
2. **Doces (Mensal):** Na segunda-feira que antecede a última sexta-feira do mês, consulta no WhatsApp do gestor e envio à Doceria (`55 53 9192-2138`) para entrega na sexta-feira às 10h/10:30 na ACPO (Rua Siqueira Campos, 289), com dados de faturamento (CNPJ 10.351.894/0001-18 e e-mail `gestaodepessoas@acpo.com.br`).

---

## 2. Entregas Verticais

### Entrega 1: Workflow Agendador & Lógica de Calendário no n8n
- **Critério de Aceite:**
  - Schedule Trigger configurado para segundas-feiras às 09:00 (America/Sao_Paulo).
  - Cálculo de data dinâmica para terça-feira seguinte (Frutas).
  - Verificação algorítmica se a sexta-feira da mesma semana é a última sexta-feira do mês corrente (Doces).
  - Geração de mensagem clara e concisa para o WhatsApp do gestor (`55 53 9813-19473`).
- **Dependências:** Conexão com OpenWA na VPS (`http://172.17.0.1:2785`).
- **Riscos:** Virada de mês em anos bissextos ou semanas quebradas (coberto com cálculo por `Date` nativo do JavaScript).

### Entrega 2: Sub-fluxo de Recepção, IA e Disparo aos Fornecedores
- **Critério de Aceite:**
  - Webhook receptor conectado ao OpenWA escutando respostas do gestor.
  - Filtro restrito ao número do gestor para evitar acionamentos indevidos.
  - Nó de IA (DeepSeek / Gemini) com prompt determinístico para diferenciar aprovação simples de solicitações de alteração de itens.
  - Roteamento correto da mensagem final para o Hortifruti ou Doceria com os dados completos da ACPO.
  - Mensagem de confirmação de volta ao WhatsApp do gestor.
- **Dependências:** Sessão ativa do OpenWA na VPS e chaves de API da IA.
- **Riscos:** Respostas ambíguas do usuário (mitigado com fallback que pede confirmação antes de disparar).

---

## 3. Skills Previstas

| Skill / Ferramenta | Etapa de Uso | Evidência a Produzir |
| :--- | :--- | :--- |
| `n8n REST API` | Criação e publicação do workflow | Workflow visível em `https://n8n.bssaude.com.br/home/workflows` com ID gerado |
| `OpenWA API` | Envio de mensagens e escuta de webhooks | Log de teste com status 200 e `messageId` válido |
| `JavaScript / Code Nodes` | Cálculo de datas e calendário da última sexta | Execução dos nós retornando as datas corretas |
| `DeepSeek / Gemini API` | Interpretação de texto e ajustes de quantidades | Payload JSON estruturado com `{ tipo, aprovado, mensagemFinal }` |

---

## 4. Workflow Autônomo de Execução

1. **Preparação:** Validar credenciais da API do n8n na VPS e montar o payload JSON completo do workflow com nós, posições e conexões.
2. **Execução:** Enviar requisição `POST https://n8n.bssaude.com.br/api/v1/workflows` criando o workflow com nome:
   `"ACPO - Pedidos Recorrentes (Frutas & Doces)"`.
3. **Testes Unitários de Nós:** Testar a lógica de data da última sexta-feira do mês com casos de teste (meses com 4 e 5 sextas-feiras).
4. **Deploy & Ativação:** Ativar o workflow no n8n.
5. **Recuperação de Falhas:** Caso o envio ao fornecedor falhe, notificar imediatamente o WhatsApp do gestor com o erro ocorrido (`onError: continueRegularOutput`).
6. **Definição de Pronto (DoD):**
   - Workflow criado e listado no n8n da VPS.
   - Visualização dos nós clara no painel web.
   - Notificação de teste enviada ao WhatsApp do gestor com sucesso.

---

## 5. Gates Mínimos

1. **Lint / Sintaxe:** Código JavaScript dos nós livre de erros de sintaxe.
2. **Segurança:** Apenas mensagens vindas do WhatsApp do gestor (`5553981319473`) têm permissão de aprovar pedidos.
3. **Limites de Mensagem:** Garantir payloads < 4096 caracteres no OpenWA.
4. **Resiliência:** Preservar estado pendente sem perda de mensagens.

---

## 6. Autonomia e Escopo

O agente está autorizado a:
- Criar e configurar o novo workflow no n8n via API.
- Testar os nós com dados simulados.
- Salvar e versionar a documentação correspondente no repositório.
- Pausar apenas caso haja falha de credenciais externas ou necessidade de novo número de telefone.
