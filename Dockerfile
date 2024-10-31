# 使用 Node.js 官方 12-alpine 作為基礎映像構建 node_builder 階段
FROM node:12-alpine as builder

# 安裝 PHP 和必要的依賴
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
    build-base \
    php7 \
    php7-fpm \
    php7-opcache \
    php7-mysqli \
    php7-pdo \
    php7-pdo_mysql \
    php7-json \
    php7-mbstring \
    php7-session && \
    ln -sf /usr/bin/php7 /usr/bin/php && \
    ln -sf /usr/sbin/php-fpm7 /usr/bin/php-fpm

# 安裝 Composer
RUN wget https://getcomposer.org/composer-stable.phar && \
    chmod +x composer-stable.phar && \
    mv composer-stable.phar /usr/local/bin/composer

# 準備應用程式目錄
WORKDIR /app
COPY . /app

# 安裝 PHP 依賴
RUN composer install --no-dev

# 安裝 Node.js 依賴和編譯資源
RUN yarn install && \
    yarn remove node-sass && \
    yarn add sass --dev && \
    yarn run development

# 更改應用程式目錄的擁有者
RUN chown -R www-data:www-data /app

# 設置 PATH 環境變量
ENV PATH="/usr/local/node/bin:$PATH"

# Nginx 配置和啟動腳本
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

# 暴露端口
EXPOSE 80

# 啟動容器時執行的指令
CMD ["sh", "/app/startup.sh"]