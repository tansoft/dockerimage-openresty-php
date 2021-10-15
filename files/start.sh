#!/bin/sh

#sysctl -w net.core.somaxconn=4096

/usr/bin/memcached -p 12000 -l 127.0.0.1 -d -u root -m 64m

/usr/sbin/php-fpm7

/usr/bin/supervisord -c /etc/supervisord.conf

/usr/local/openresty/nginx/sbin/nginx

while true
do
    sleep 1
done
