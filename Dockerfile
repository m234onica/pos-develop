FROM php:7.4-fpm-alpine3.13

# Install necessary packages
RUN apk add --no-cache nginx wget nodejs npm

# Create directories for nginx
RUN mkdir -p /run/nginx

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Set the working directory
WORKDIR /app

# Copy the application files
COPY . .

# Install Composer and PHP dependencies
RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"
RUN composer install --no-dev

# Install Yarn and Node.js dependencies
RUN npm install -g yarn && yarn global add cross-env
RUN yarn install
RUN yarn dev

# Ensure proper ownership of application files
RUN chown -R www-data: /app

# 設定容器啟動時執行的指令
CMD ["sh", "/app/docker/startup.sh"]