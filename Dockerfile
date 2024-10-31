# 使用 PHP 7.4 和 Debian Bullseye 作為基礎映像
FROM php:7.4.33-fpm-bullseye

# 安裝必要的工具和依賴
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    git \
    nginx \
    wget \
    curl \
    zlib1g-dev \
    libzip-dev \
    zip \
    libpng-dev \
    libicu-dev \
    python2 \
    make \
    g++ \
    build-essential && \
    ln -sf /usr/bin/python2 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

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

# 安裝 Composer
RUN wget https://getcomposer.org/composer-stable.phar && \
    chmod +x composer-stable.phar && \
    mv composer-stable.phar /usr/local/bin/composer

# 安裝 PHP 依賴
RUN cd /app && \
    composer install --no-dev

# 設置 Node.js 12.x 和 npm 存儲庫，並安裝 Node.js 和 npm
RUN curl -fsSL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

# 安裝 NVM
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# 設置 NVM 環境變數
ENV NODE_VERSION 10.24.1
ENV NVM_DIR /root/.nvm
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# 使用 NVM 安裝和使用特定版本的 Node.js 和 npm
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION"

# 確認 Node.js 和 npm 安裝成功
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && node -v"
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && npm -v"

# 安裝 yarn & BS3 所需特別的設定、套件
RUN npm install -g yarn --python=python2.7 \
    && yarn install --target_arch=x64 \
    && yarn global add cross-env

# 更改應用程式目錄的擁有者
RUN chown -R www-data: /app

# 安裝 Node 依賴並替換 node-sass
RUN cd /app && yarn install

# 編譯前端資源
RUN cd /app && yarn run development
USER www-data

# 設定容器啟動時執行的指令
CMD ["sh", "/app/docker/startup.sh"]