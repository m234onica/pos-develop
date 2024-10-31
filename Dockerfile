ROM php:7.4-fpm-alpine

ENV COMPOSER_ALLOW_SUPERUSER 1

# Install Node.js and npm
RUN apk add --update nodejs npm

COPY composer.json composer.lock ./
COPY . .
# Add laravel user and group
RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

# Create necessary directories and set permissions
RUN mkdir -p /app \
    && chown -R laravel:laravel /app

# Set working directory
WORKDIR /app

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Copy Composer from the official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Composer dependencies
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Install Node dependencies
COPY package.json ./
RUN npm install
RUN npm run production

# Copy application files
COPY . .

# Set permissions for application files
RUN chown -R laravel:laravel /app

# Copy and execute the permissions script
COPY set_permissions.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/set_permissions.sh
RUN /usr/local/bin/set_permissions.sh

# 編譯前端資源
RUN cd /app && yarn run development

# 設定容器啟動時執行的指令
CMD ["sh", "/app/docker/startup.sh"]