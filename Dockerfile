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