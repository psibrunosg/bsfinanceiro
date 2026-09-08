# Guia de Integração: Atalhos do iPhone (iOS Shortcuts) & BS Financeiro

Este guia descreve como configurar a automação no aplicativo **Atalhos (Shortcuts)** do iOS para registrar despesas no **BS Financeiro** através de micromodais nativos, com suporte a parcelamento, registro silencioso em segundo plano e fallback automático com abertura de modal em caso de falha.

---

## 1. Visão Geral do Fluxo

```mermaid
flowchart TD
    A["Acionar Atalho no iPhone"] --> B["Micromodal 1: 'Qual o valor?'\n(Valor padrão editável)"]
    B --> C["Micromodal 2: 'Qual o estabelecimento?'\n(Nome da loja padrão editável)"]
    C --> D{"Micromodal 3: 'Forma de Pagamento?'"}
    D -->|"À vista"| E["Parcelas = 1"]
    D -->|"Parcelado"| F["Micromodal 4: 'Quantas parcelas?'\n(2x a 12x)"]
    E --> G["POST em segundo plano\n(https://financeiro.bssaude.com.br/api/shortcuts)"]
    F --> G
    G --> H{"Status HTTP == 200?"}
    H -->|"Sim (Sucesso)"| I["Notificação nativa no iOS:\n'✅ Gasto registrado no BS Financeiro!'"]
    H -->|"Não / Erro / Offline"| J["Abre o navegador automaticamente:\nModal do BS Financeiro na tela para ajustar e salvar!"]
```

---

## 2. Dados de Acesso e Endpoints

* **URL da API (POST em segundo plano):**  
  `https://financeiro.bssaude.com.br/api/shortcuts`
* **Chave de Segurança (Token de Autorização):**  
  `bsf_shortcut_token_2026`
* **Cabeçalho HTTP:**  
  `Authorization: Bearer bsf_shortcut_token_2026`
* **URL de Fallback (Navegador):**  
  `https://financeiro.bssaude.com.br/movimentacoes?amount=[VALOR]&desc=[ESTABELECIMENTO]&installments=[PARCELAS]&open=true`

> **Onde encontrar no app:** Acesse **Configurações** > aba **"Atalhos iOS"** para copiar as credenciais e o modelo de configuração.

---

## 3. Passo a Passo no App Atalhos (iPhone)

1. Abra o app **Atalhos (Shortcuts)** no iOS.
2. Toque no botão **`+`** no canto superior direito para criar um novo atalho.
3. Nomeie o atalho como **"Registrar Gasto"** (você pode colocar um ícone de cartão ou dinheiro).
4. Adicione as seguintes ações na ordem:

### Ação 1: Micromodal de Valor (com valor pré-preenchido e editável)
* Busque por **"Solicitar Entrada"** (*Ask for Input*).
* **Tipo:** *Número*.
* **Pergunta:** *"Qual o valor da compra?"*.
* Toque na setinha de detalhes da ação e defina o campo **Padrão** com o valor detectado na notificação ou área de transferência.

### Ação 2: Micromodal de Estabelecimento / Descrição
* Busque por **"Solicitar Entrada"**.
* **Tipo:** *Texto*.
* **Pergunta:** *"Onde foi a compra?"*.
* Defina o campo **Padrão** com a descrição/nome do estabelecimento capturado.

### Ação 3: Micromodal de Parcelamento (Menu com botões)
* Busque por **"Escolher do Menu"** (*Choose from Menu*).
* **Pergunta:** *"Forma de Pagamento?"*.
* Configure duas opções:
  1. **À vista:** adicione a ação **Definir Variável** `parcelas = 1`.
  2. **Parcelado:** adicione a ação **"Solicitar Entrada"** (*Tipo: Número*, *Pergunta: "Quantas parcelas? (2 a 12)"*) e defina a variável `parcelas` com a resposta do usuário.

### Ação 4: Envio em Segundo Plano (Requisição Silenciosa)
* Busque por **"Obter Conteúdo do URL"** (*Get Contents of URL*).
* **URL:** `https://financeiro.bssaude.com.br/api/shortcuts`
* **Método:** `POST`
* **Cabeçalhos:**
  * Nome: `Authorization`
  * Valor: `Bearer bsf_shortcut_token_2026`
* **Corpo da Requisição (JSON):**
  * `amount`: Variável do **Valor** (da Ação 1)
  * `description`: Variável do **Estabelecimento** (da Ação 2)
  * `installments`: Variável **parcelas** (da Ação 3)
  * `type`: `expense`

### Ação 5: Condicional de Fallback (Abertura do Modal se der erro)
* Busque por **"Se"** (*If*):
* **Condição:** Se o *Código de Status HTTP* **não for 200** (ou em caso de timeout/falha de conexão):
  * Adicione a ação **"Abrir URLs"** (*Open URLs*) com o link de fallback:
    ```text
    https://financeiro.bssaude.com.br/movimentacoes?amount=[Valor]&desc=[Estabelecimento]&installments=[Parcelas]&open=true
    ```
    *(Dessa forma, se houver qualquer erro na API ou falta de internet, o modal abre na tela com tudo preenchido para conferência e salvamento manual)*.
* **Senão (Se status for 200):**
  * Adicione a ação **"Mostrar Notificação"**:
    *"✅ Gasto registrado no BS Financeiro!"*

---

## 4. Exemplo de Payload JSON Enviado

```json
{
  "amount": 300.00,
  "description": "Restaurante Coco Bambu",
  "installments": 3,
  "type": "expense"
}
```

### Resposta da API em Sucesso (HTTP 200):
```json
{
  "success": true,
  "count": 3,
  "amount": 300,
  "installments": 3,
  "message": "3 parcelas de Restaurante Coco Bambu registradas com sucesso!"
}
```
* O backend divide o valor em 3 parcelas de R$ 100,00 e agenda cada parcela mês a mês no histórico com a descrição:
  * `Restaurante Coco Bambu (1/3)`
  * `Restaurante Coco Bambu (2/3)`
  * `Restaurante Coco Bambu (3/3)`

---

## 5. Recursos e Arquivos no Repositório

* **Endpoint da API:** [`src/app/api/shortcuts/route.ts`](../src/app/api/shortcuts/route.ts)
* **Página de Configurações:** [`src/app/SettingsPage.tsx`](../src/app/SettingsPage.tsx) (aba *"Atalhos iOS"*)
* **Página de Movimentações & Fallback:** [`src/app/TransactionsPage.tsx`](../src/app/TransactionsPage.tsx)
* **Middleware de Autorização:** [`src/lib/supabase/middleware.ts`](../src/lib/supabase/middleware.ts)
