# Openresty + php7 Docker

* PHP7 基础组件：Debug、FPM、phar、curl、dom、json、openssl、session、sockets、ctype、fileinfo、gettext、mbstring、iconv、mcrypt、bcmath、gd、zip、opcache
* 数据组件：pdo、mysql、redis、memcached、sasl2、amqp
* yaf 3.0.8、yar 2.0.5、swoole 4.3.1、xhprof 2.1.0、donkeyid 1.0、xxtea

## 路径

### nginx
* 主目录：/usr/local/openresty/nginx
* nginx主配置：/usr/local/openresty/nginx/conf/nginx.conf
* 站点配置：/etc/nginx/conf.d/*.conf
* nginx错误日志：/var/log/nginx/error.log
* web：/var/www/html
* xhprof：/var/www/xhprof
* nginx启动路径：/usr/local/openresty/nginx/sbin/nginx

### fpm
* fpm主配置：/etc/php7/php-fpm.conf
* 站点配置：/etc/php7/php-fpm.d/*.conf
* php-fpm启动路径：/usr/sbin/php-fpm7
* 默认配置：
```
pm = dynamic
pm.max_children = 5
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

### 启动脚本
* /usr/local/start.sh
