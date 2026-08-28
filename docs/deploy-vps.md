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
Crie as pastas necessárias e garanta as permissões:
```bash
# Se houver uma pasta storage no futuro
# chmod -R 777 storage
```

Edite o arquivo `docker-compose.yml` e altere a senha padrao do PostgreSQL (`POSTGRES_PASSWORD` e `DB_PASS`) para uma senha forte.

## 3. Subindo os Containers
Inicie a orquestração do PHP 8.3 com Apache + PostgreSQL 16:
```bash
docker compose up -d --build
```
*O sistema estará rodando na porta 8080 interna da VPS.*

## 4. Banco de Dados Inicial
Como a VPS usará o PostgreSQL de dentro do Docker, execute a migração inicial rodando nosso script dentro do container do PHP:
```bash
docker exec -it bsfinanceiro_app php /var/www/html/database/migrate.php
```

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
