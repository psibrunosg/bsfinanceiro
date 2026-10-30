# Deploy na VPS (Produção)

Este guia descreve como hospedar o BS Financeiro PHP Vanilla em uma VPS Ubuntu utilizando o Docker.

## Pré-requisitos na VPS
1. **Ubuntu 22.04 LTS** (recomendado).
2. **Docker e Docker Compose** instalados.
3. **Nginx** (para servir como Proxy Reverso).
4. Domínio apontando para o IP da VPS.

## 1. Enviando o Projeto para a VPS
Use Git para clonar o repositório na VPS:
```bash
git clone https://github.com/seu-usuario/bsfinanceiro.git
cd bsfinanceiro
```

## 2. Configurando o Ambiente
Crie um arquivo `.env` local na VPS. Ele já está ignorado pelo Git e não deve ser versionado:

```bash
cp .env.example .env
nano .env
```

Defina pelo menos:

```dotenv
BSFINANCEIRO_DB_PASSWORD=senha_atual_do_postgresql
APP_AUTH_SECRET=segredo_aleatorio_com_pelo_menos_32_caracteres
```

Em uma VPS já existente, `BSFINANCEIRO_DB_PASSWORD` deve receber a senha que o PostgreSQL já usa antes do primeiro rebuild. A rotação dessa senha deve ser feita de forma coordenada no banco e nos containers.

## 3. Subindo os Containers
Inicie a orquestração do frontend Nginx, API PHP 8.3 e PostgreSQL 16:
```bash
docker compose up -d --build
```

O frontend fica publicado localmente em `127.0.0.1:8082`; o Nginx externo da VPS encaminha o domínio HTTPS para o container `bsfinanceiro-frontend`.

## 4. Banco de Dados

Em uma instalação nova, `database/full_production_schema.sql` é aplicado na inicialização do volume PostgreSQL.

Para atualizar uma VPS existente com o registro rápido por dispositivo, aplique:

```bash
docker exec -i bsfinanceiro-db psql -U bstrainer -d bsfinanceiro < database/shortcut_devices.sql
```

A API também executa `CREATE TABLE IF NOT EXISTS` defensivamente ao acessar os endpoints de Atalhos, mas manter o schema aplicado explicitamente facilita auditoria e recuperação.

## 5. Configurando Nginx e SSL (Certbot)
Instale o Nginx e o Certbot:
```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx
```

Crie o arquivo de configuração do site: `sudo nano /etc/nginx/sites-available/bsfinanceiro`
```nginx
server {
    server_name seu-dominio.com.br;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Ative e garanta o SSL:
```bash
sudo ln -s /etc/nginx/sites-available/bsfinanceiro /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d seu-dominio.com.br
```

Pronto! Seu sistema está no ar, seguro e isolado!
