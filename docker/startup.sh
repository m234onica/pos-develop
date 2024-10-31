#!/bin/sh

sed -i "s,LISTEN_PORT,$PORT,g" /etc/nginx/nginx.conf

php-fpm -D

while ! nc -w 1 -z 0.0.0.0 9000; do sleep 0.1; done;

# 啟動 Nginx
nginx -g 'daemon off;'
