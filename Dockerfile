# 使用 Node.js 官方 12-alpine 作為基礎映像構建 node_builder 階段
FROM node:12-alpine as node_builder

# PHP 環境構建
FROM php:7.4-fpm-alpine3.13

# 從 node_builder 階段拷貝完整的 Node.js 和 npm 目錄
COPY --from=node_builder /usr/local /usr/local

# 安裝必要的工具和依賴
RUN apk --no-cache update && \
    apk add --no-cache \
    bash \
    git \
    nginx \
    wget \
    curl \
    zlib-dev \
    libzip-dev \
    zip \
    libpng-dev \
    icu-dev \
    python2 \
    make \
    g++ \
    build-base && \
    ln -sf /usr/bin/python2 /usr/bin/python

# 安裝 PHP MySQL 擴展
RUN docker-php-ext-install pdo pdo_mysql

# 創建 nginx 所需的目錄
RUN mkdir -p /run/nginx

# 複製 nginx 配置檔案
COPY docker/nginx.conf /etc/nginx/nginx.conf

# 準備應用程式目錄
RUN mkdir -p /app
COPY . /app
COPY ./src /app

# 安裝 composer
RUN wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer

# 安裝 PHP 依賴
RUN cd /app && /usr/local/bin/composer install --no-dev

# 安裝 Yarn 和 cross-env
RUN npm install -g yarn && yarn global add cross-env

# 更改應用程式目錄的擁有者
RUN chown -R www-data: /app

USER www-data

# 安裝 Node 依賴並替換 node-sass
RUN cd /app && \
    yarn install && \
    yarn remove node-sass && \
    yarn add sass --dev

# 編譯前端資源
RUN cd /app && yarn run development

# 設定容器啟動時執行的指令
CMD ["sh", "/app/docker/startup.sh"]