#!/bin/sh

#sysctl -w net.core.somaxconn=4096

/usr/sbin/php-fpm7

/usr/local/openresty/nginx/sbin/nginx

while true
do
    sleep 1
done

