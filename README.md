# OpenResty + PHP7 Docker

* PHP7 基础组件：Debug、FPM、phar、curl、dom、json、openssl、session、sockets、ctype、fileinfo、gettext、mbstring、iconv、mcrypt、bcmath、gd、zip、opcache
* PHP7 数据组件：pdo、mysql、redis、memcached、sasl2、amqp
* yaf 3.0.8、yar 2.0.5、swoole 4.3.1、xhprof 2.1.0、donkeyid 1.0、xxtea
* supervisord
* memcached

## 版本
* 生产环境使用：tansoft/openresty-php:latest
* 调试环境使用：tansoft/openresty-php:debug
```
docker run -d -v `pwd`:/var/www/html --name debugversion -p8000:80 tansoft/openresty-php:debug
docker exec -it debugversion /bin/sh -c "tail -F /var/log/*/*"
docker rm -f -v debugversion
```

## 路径

### nginx
* 主目录：/usr/local/openresty/nginx
* nginx主配置：/usr/local/openresty/nginx/conf/nginx.conf
* 站点配置：/etc/nginx/conf.d/*.conf
* nginx错误日志：/var/log/nginx/error.log
* 默认站点访问日志：/var/log/nginx/default.access.log
* 默认站点错误日志：/var/log/nginx/default.error.log
* web：/var/www/html
* xhprof：/var/www/xhprof
* nginx启动路径：/usr/local/openresty/nginx/sbin/nginx

### fpm
* fpm主配置：/etc/php7/php-fpm.conf
* 站点配置：/etc/php7/php-fpm.d/*.conf
* php-fpm启动路径：/usr/sbin/php-fpm7
* 错误日志：/var/log/php7/error.log
* php权限可以写入：/var/log/applogs/*
* 默认配置：
```
pm = dynamic
pm.max_children = 5
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

### supervisord
* 主配置：/etc/supervisord.conf
* 服务配置：/etc/supervisor/conf.d/*.conf
* 启动路径：/usr/bin/supervisord -c /etc/supervisord.conf
* 日志：/var/log/supervisord/supervisord.log

### memcached
* 默认本地缓存：/usr/bin/memcached -p 12000 -l 127.0.0.1 -d -u root -m 64m

### 启动脚本
* /usr/local/start.sh

### 调试环境
* PHP错误日志：/var/log/php7/php_error.log
* FPM错误日志：/var/log/php7/fpm_error.log
* SlowLog：10秒 /var/log/php7/www_slow.log