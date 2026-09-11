# Design: Assistente de Pedidos Recorrentes ACPO (Frutas & Doces)

## 1. Visão Geral e Contexto
O objetivo deste subsistema no n8n é automatizar duas rotinas recorrentes de compras da empresa ACPO Empreendimentos:
1. **Pedido Semanal de Frutas:** Toda segunda-feira de manhã para entrega na terça-feira no Hortifruti.
2. **Pedido Mensal de Doces:** Na segunda-feira que antecede a última sexta-feira do mês, para entrega na última sexta na Confeitaria/Doceria.

Ambos os fluxos operam no modelo **Human-in-the-Loop com IA**: o sistema consulta o usuário (Bruno) via WhatsApp antes de disparar o pedido. O usuário pode aprovar imediatamente com uma resposta afirmativa ("Sim", "OK") ou ditar/digitar alterações ("Trocar 1kg de banana por maçã"), que são interpretadas por IA (DeepSeek / Gemini) para gerar a mensagem final formatada antes do envio ao fornecedor.

---

## 2. Parâmetros de Negócio

### 2.1. Pedido de Frutas (Semanal)
- **Frequência:** Toda segunda-feira às 09:00.
- **Data de Entrega Solicitada:** Terça-feira (dia seguinte) às 09:30.
- **Destinatário Fornecedor:** Hortifruti (`+55 53 9147-6380` -> `555391476380@c.us`).
- **Lista Padrão:**
  - 2Kg Banana
  - 25 Maçãs
  - 18 Peras
- **Assinatura:** ACPO.
- **Formato Final:**
  ```text
  Olá.
  Bom dia. Como estão ?
  Pedido de frutas para amanhã, {DATA_AMANHA} ás 9:30.
  2Kg Banana
  25 Maças
  18 Peras

  ACPO
  ```

### 2.2. Pedido de Doces (Mensal)
- **Frequência:** Na segunda-feira que antecede a última sexta-feira do mês, às 09:05.
- **Cálculo da Regra:**
  - Seja $S$ a sexta-feira da semana atual (`hoje + 4 dias`).
  - Se $S + 7\text{ dias}$ estiver no mês seguinte, então $S$ é a **última sexta-feira do mês**.
  - O pedido é disparado nesta segunda-feira.
- **Data de Entrega Solicitada:** Sexta-feira $S$ até as 10:30 (horário de entrega às 10h).
- **Destinatário Fornecedor:** Doceria (`+55 53 9192-2138` -> `555391922138@c.us`).
- **Lista Padrão:**
  - 60 quindim
  - 60 bombom morango
  - 60 bombom trufa preto
  - 60 bombom de branquinho
- **Dados de Faturamento & Entrega:**
  - Local de entrega: ACPO Empreendimentos (Rua Siqueira Campos, 289 - Fragata), às 10h.
  - Envio de NF e boleto: `gestaodepessoas@acpo.com.br`
  - CNPJ: 10.351.894/0001-18
- **Formato Final:**
  ```text
  Olá, bom dia.
  Tudo bem?

  Pedido para {DATA_ULTIMA_SEXTA}, para entrega até as 10:30.
  60 quindim
  60 bombom morango
  60 bombom trufa preto
  60 bombom de branquinho

  Entrega na empresa, ACPO Empreendimentos (Rua Siqueira Campos, 289 - Fragata), às 10h, pode enviar a nota fiscal e boleto para o e-mail: gestaodepessoas@acpo.com.br

  Nota no CNPJ 10.351.894/0001-18
  ```

---

## 3. Arquitetura Técnica no n8n

### 3.1. Workflow 1: Agendador e Notificador de Proposta (`acpo-pedidos-agendador`)
1. **Schedule Trigger:** Disparo toda segunda-feira às 09:00 (timezone: America/Sao_Paulo).
2. **Code Node (Calendário & Propostas):**
   - Calcula a data de terça-feira (`DD/MM`).
   - Avalia a regra da última sexta-feira do mês.
   - Monta a(s) proposta(s) para o Bruno.
3. **Persistência de Estado (n8n Data Storage / Internal State):**
   - Armazena os pedidos pendentes com flags:
     - `frutas_pendente: true`, `frutas_padrao: "..."`, `data_entrega_frutas: "..."`
     - `doces_pendente: boolean`, `doces_padrao: "..."`, `data_entrega_doces: "..."`
4. **HTTP Request Node (OpenWA Enviar WhatsApp):**
   - Envia a mensagem de consulta para Bruno (`5553981319473@c.us`) via OpenWA na VPS (`http://172.17.0.1:2785`).

### 3.2. Workflow 2: Recepção, IA e Disparo aos Fornecedores (`acpo-pedidos-processador`)
1. **Webhook Trigger (OpenWA Incoming Message):**
   - Escuta mensagens recebidas no WhatsApp.
   - Filtra apenas mensagens enviadas pelo Bruno (`5553981319473@c.us`).
2. **Code Node (Validador de Contexto):**
   - Verifica se há algum pedido em status `PENDENTE`.
   - Se não houver, ignora silenciosamente.
3. **LLM Node (DeepSeek OpenCode / Gemini):**
   - Prompt de decisão estruturada:
     - Detecta se a resposta se refere a Frutas, Doces ou Ambos.
     - Detecta se foi aprovação direta ou alteração.
     - Se houve alteração, aplica os ajustes mantendo a formatação estrita da ACPO.
     - Retorna JSON estruturado: `{ tipo: 'frutas'|'doces'|'ambos', mensagemFornecedor: string, aprovado: true }`.
4. **HTTP Request Nodes (Envio aos Fornecedores):**
   - Dispara para o Hortifruti (`555391476380@c.us`) ou Doceria (`555391922138@c.us`) usando a sessão configurada (Gestão / Clínica) no OpenWA.
5. **HTTP Request Node (Confirmação ao Solicitante):**
   - Envia mensagem para o Bruno confirmando a conclusão e exibindo o que foi enviado ao fornecedor.
6. **Code Node (Atualizador de Estado):**
   - Marca o pedido como `CONCLUIDO` para evitar disparos repetidos.

---

## 4. Gerenciamento de Sessões do WhatsApp
- **Sessão Notificadora (Atual):** `bc1da7b6-d9c3-492d-aea8-ddf0aafe35cd` (Sessão `clinica`).
- **Sessão Telefone da Gestão:** Variável parametrizável no n8n. Enquanto o telefone da gestão não estiver conectado no OpenWA, o nó utiliza como fallback a sessão ativa atual, permitindo transição sem interrupção de serviço.

---

## 5. Tratamento de Erros e Casos de Borda
1. **Mensagem fora de hora:** Respostas do Bruno enviadas quando não há pedido pendente não acionam envio a fornecedores.
2. **Limite de Caracteres WhatsApp:** Todas as mensagens montadas têm menos de 1.000 caracteres, bem abaixo do limite de 4.096 caracteres do WhatsApp.
3. **Respostas Parciais:** Se na mesma semana houver frutas e doces e o usuário aprovar apenas um, a IA identifica e despacha o pedido aprovado mantendo o outro pendente até manifestação.
