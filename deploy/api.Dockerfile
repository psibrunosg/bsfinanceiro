FROM php:8.3-cli-alpine

RUN apk add --no-cache postgresql-dev nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql

WORKDIR /var/www/html

COPY server ./server
RUN cd server && npm ci --omit=dev --omit=optional --ignore-scripts && npm cache clean --force

EXPOSE 8000

CMD ["php", "-d", "upload_max_filesize=11M", "-d", "post_max_size=12M", "-S", "0.0.0.0:8000", "server/api.php"]
