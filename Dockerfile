# 使用 PHP 7.4 和 Alpine 基礎映像
FROM php:7.4-fpm-alpine3.13

# 手動下載並安裝 Node.js 12.x 和 npm
RUN apk add --no-cache curl && \
    curl -o node-v12.22.12-linux-x64.tar.xz https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz && \
    tar -xf node-v12.22.12-linux-x64.tar.xz && \
    mv node-v12.22.12-linux-x64 /usr/local/node && \
    ln -s /usr/local/node/bin/node /usr/local/bin/node && \
    ln -s /usr/local/node/bin/npm /usr/local/bin/npm && \
    rm node-v12.22.12-linux-x64.tar.xz

# 驗證 Node.js 和 npm 是否成功安裝
RUN node -v && npm -v

# 安裝必要的工具和 PHP 擴展
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
    freetype-dev \
    libjpeg-turbo-dev \
    libpng \
    icu-dev \
    python2 \
    make \
    g++ \
    build-base && \
    ln -sf /usr/bin/python2 /usr/bin/python && \
    docker-php-ext-install pdo pdo_mysql

# 創建 nginx 所需的目錄
RUN mkdir -p /run/nginx

# 複製 nginx 配置檔案
COPY docker/nginx.conf /etc/nginx/nginx.conf

# 準備應用程式目錄
RUN mkdir -p /app
COPY . /app
COPY ./src /app

# 安裝 Composer
RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"

# 安裝 PHP 依賴
RUN cd /app && composer install --no-dev

# 安裝 Yarn 和 cross-env
RUN npm install -g yarn && yarn global add cross-env

# 更改應用程式目錄的擁有者
RUN chown -R www-data:www-data /app

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