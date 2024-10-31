FROM php:7.4-fpm-alpine

USER root
# Apk install
# hadolint ignore=DL3018
RUN apk --no-cache update && \
    apk --no-cache add bash git && \
    apk add --update --no-cache yarn curl zlib-dev libzip-dev zip libpng-dev icu-dev

# Install pdo
RUN docker-php-ext-install pdo_mysql gd intl zip

# Symfony CLI
RUN wget -q https://get.symfony.com/cli/installer -O - | bash && mv /root/.symfony/bin/symfony /usr/local/bin/symfony

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /app

COPY . /app/
VOLUME /app/vendor
VOLUME /app/public/build
VOLUME /app/node_modules
VOLUME /app/var

RUN chown -R www-data:www-data /app

USER www-data

RUN php composer.phar install
RUN yarn install --dev

# 設定容器啟動時執行的指令
CMD sh /app/docker/startup.sh