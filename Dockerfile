FROM php:7.4-fpm-alpine3.13

# 安裝必要的工具和依賴
RUN apk --no-cache update && \
    apk add --no-cache \
    bash \
    git \
    nginx \
    wget \
    yarn \
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
    ln -sf /usr/bin/python2 /usr/bin/python  # 指向 python2

# 使用 npm 安裝 yarn 和 cross-env
RUN yarn global add cross-env

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
RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"

# Install PHP dependencies
RUN cd /app && \
    /usr/local/bin/composer install --no-dev


# 更改應用程式目錄的擁有者
RUN chown -R www-data: /app

# 下載並安裝 Node.js 12.x
RUN wget https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz && \
    tar -xf node-v12.22.12-linux-x64.tar.xz && \
    mv node-v12.22.12-linux-x64 /usr/local/node && \
    ln -s /usr/local/node/bin/node /usr/local/bin/node && \
    ln -s /usr/local/node/bin/npm /usr/local/bin/npm && \
    rm node-v12.22.12-linux-x64.tar.xz

# 安裝 Node 依賴並替換 node-sass
RUN cd /app && \
    yarn install && \
    yarn why node-sass && \
    yarn remove node-sass && \
    yarn add sass --dev

RUN cd /app && \
    yarn run development

# 設定容器啟動時執行的指令
CMD sh /app/docker/startup.sh
