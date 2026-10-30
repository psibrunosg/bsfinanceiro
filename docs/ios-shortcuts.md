# Registro rápido no iPhone

O BS Financeiro usa a API PHP da VPS para receber lançamentos do app Atalhos do iOS.

## Arquitetura

```text
iPhone / Atalhos
      |
      v
https://financeiro.bssaude.com.br/api/shortcuts
      |
      v
Nginx -> container PHP -> PostgreSQL
```

Cada iPhone possui um token próprio. O token bruto é exibido apenas na criação; o banco armazena somente o hash SHA-256.
## Criar um dispositivo

1. Entre no BS Financeiro.
2. Abra **Configurações > Atalhos iOS**.
3. Escolha o nome do dispositivo.
4. Selecione a conta padrão.
5. Opcionalmente escolha uma categoria padrão.
6. Clique em **Criar token do iPhone**.
7. Copie o token imediatamente.

O dispositivo pode ser revogado na mesma tela. A revogação invalida novas requisições do token.
## Configuração do Atalho

Use a ação **Obter Conteúdo de URL**:

- URL: `https://financeiro.bssaude.com.br/api/shortcuts`
- Método: `POST`
- Header: `Authorization: Bearer SEU_TOKEN_DO_DISPOSITIVO`
- Corpo: JSON

Exemplo:

```json
{
  "amount": "39,90",
  "description": "Zaffari",
  "installments": 1,
  "type": "expense",
  "request_id": "UUID-UNICO-DA-EXECUCAO"
}
```
## Idempotência

Use um UUID novo em `request_id` em cada execução do Atalho.

Se o iPhone reenviar a mesma requisição com o mesmo `request_id`, a API devolve a resposta anterior em vez de criar outro lançamento.

## Regras do backend

- O workspace e o usuário são obtidos pelo token do dispositivo.
- A conta é a conta padrão associada ao dispositivo.
- IDs de outro usuário/workspace não são aceitos.
- A categoria padrão pode ser definida por dispositivo.
- Se não houver categoria padrão, a API tenta uma sugestão simples pelas categorias do workspace.
- O antigo token global foi removido.
- O endpoint Next.js duplicado foi removido; a implementação oficial é `public/api.php`.

## Migração da VPS

Para uma instalação existente, aplique `database/shortcut_devices.sql` antes do uso, ou publique a versão atual da API, que cria as tabelas defensivamente com `CREATE TABLE IF NOT EXISTS`.
