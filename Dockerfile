FROM php:7.4-fpm-alpine

# 安裝必要的工具和 nginx，以及 nodejs 和 yarn
RUN apk add --no-cache nginx wget nodejs npm

# 使用 npm 安裝 yarn
RUN npm install -g yarn

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

# 安裝 PHP 依賴
RUN cd /app && \
    /usr/local/bin/composer install --no-dev

# 安裝 nodejs 依賴
RUN cd /app && yarn install && yarn run development

# 更改應用程式目錄的擁有者
RUN chown -R www-data: /app

# 設定容器啟動時執行的指令
CMD sh /app/docker/startup.sh