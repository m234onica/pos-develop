#!/bin/sh

sed -i "s,LISTEN_PORT,${PORT:-80},g" /etc/nginx/nginx.conf

php-fpm -D

while ! nc -w 1 -z 0.0.0.0 9000; do sleep 0.1; done;

if ! nginx; then
  echo "Nginx failed to start."
  exit 1
fi

nginx
