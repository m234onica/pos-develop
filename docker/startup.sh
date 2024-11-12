#!/bin/sh
# 確保 www-data 擁有 /app/storage 和 /app/bootstrap/cache 的權限
chown -R www-data:www-data /app/storage /app/bootstrap/cache
chmod -R 775 /app/storage /app/bootstrap/cache

sed -i "s,LISTEN_PORT,$PORT,g" /etc/nginx/nginx.conf

php-fpm -D

# while ! nc -w 1 -z 0.0.0.0 9000; do sleep 0.1; done;

# 執行 Laravel 遷移和資料填充
php /app/artisan migrate --force
php /app/artisan db:seed --force

# 啟動 Nginx
nginx
