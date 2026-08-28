FROM php:8.3-apache

# Instalar dependências de sistema necessárias para as extensões do PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite do Apache para roteamento customizado
RUN a2enmod rewrite

# Instalar extensões do PHP para o PostgreSQL (PDO e pgsql nativo)
RUN docker-php-ext-install pdo pdo_pgsql pgsql

# Configurar o DocumentRoot para a pasta public/
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html
