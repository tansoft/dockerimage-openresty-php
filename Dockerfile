#FROM php:fpm-alpine
#support plugin list：ls /usr/src/php/ext/
#RUN docker-php-ext-install bcmath gd gettext mysqli opcache pcntl pdo pdo_mysql sysvmsg
#RUN echo "opcache.file_cache=/tmp" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

FROM openresty/openresty:alpine

COPY ./dependents /usr/local/

RUN mkdir /var/www; \
    mkdir /var/log/nginx; \
    mkdir /var/log/php7; \
    mkdir /var/log/applogs; \
    chmod 777 /var/log/applogs; \
    apk add php7 php7-phpdbg php7-fpm php7-dev php7-phar \
    php7-curl php7-dom php7-json php7-openssl php7-session php7-sockets \
    php7-ctype php7-fileinfo libmagic php7-gettext php7-mbstring php7-iconv \
    php7-mcrypt php7-bcmath php7-gd php7-zip \
    #db
    php7-pdo php7-pdo_mysql php7-mysqlnd \
    php7-redis php7-memcached php7-pear-auth_sasl2 libmemcached-libs \
    #opcache
    php7-opcache \
    #amqp
    php7-amqp; \
    rm -f /etc/php7/php-fpm.d/www.conf \
    && echo "memcached.use_sasl = 1" >> /etc/php7/conf.d/20_memcached.ini; \
    \
    #source builder
    apk add gcc gcc-objc g++ make; \
    cd /usr/local \
    \
    #yaf
    && wget https://pecl.php.net/get/yaf-3.0.8.tgz \
    && tar zxvf yaf-3.0.8.tgz && cd yaf-3.0.8/ && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/yaf-3.0.8.tgz /usr/local/yaf-3.0.8 \
    && cd /usr/local && echo "extension=yaf.so" > /etc/php7/conf.d/yaf.ini \
    \
    #yar
    && apk add curl-dev \
    && wget https://pecl.php.net/get/yar-2.0.5.tgz \
    && tar zxvf yar-2.0.5.tgz && cd yar-2.0.5/ && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/yar-2.0.5.tgz /usr/local/yar-2.0.5 \
    && apk del curl-dev \
    && cd /usr/local && echo "extension=yar.so" > /etc/php7/conf.d/yar.ini \
    \
    #swoole
    && wget https://pecl.php.net/get/swoole-4.3.1.tgz \
    && tar zxvf swoole-4.3.1.tgz && cd swoole-4.3.1/ && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/swoole-4.3.1.tgz /usr/local/swoole-4.3.1 \
    && cd /usr/local && echo "extension=swoole.so" > /etc/php7/conf.d/swoole.ini \
    \
    #xhprof
    wget http://pecl.php.net/get/xhprof-2.3.5.tgz \
    && tar zxvf xhprof-2.3.5.tgz && rm -rf /usr/local/xhprof-2.3.5.tgz \
    && mv /usr/local/xhprof-2.3.5 /var/www/xhprof \
    && cd /var/www/xhprof/extension && phpize \
    && ./configure && make && make install \
    && mkdir -p /var/log/xhprof && chmod 777 /var/log/xhprof \
    && cd /usr/local && echo -e "[xhprof]\nextension = xhprof.so\nxhprof.output_dir = /var/log/xhprof" > /etc/php7/conf.d/xhprof.ini \
    \
    #donkeyid
    && wget https://github.com/osgochina/donkeyid/archive/donkeyid-1.0.tar.gz \
    && tar zxvf donkeyid-1.0.tar.gz && cd donkeyid-donkeyid-1.0/donkeyid && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/donkeyid-1.0.tar.gz /usr/local/donkeyid-donkeyid-1.0 \
    && cd /usr/local && echo -e "[DonkeyId]\nextension=donkeyid.so\n;0-4095\ndonkeyid.node_id=0\n;0-current-timestamp\ndonkeyid.epoch=0" > /etc/php7/conf.d/donkeyid.ini \
    \
    #xxtea
    && cd /usr/local/xxtea-php && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/xxtea-php \
    && cd /usr/local && echo "extension=xxtea.so" > /etc/php7/conf.d/xxtea.ini \
    \
    #memcached
    && apk add memcached \
    \
    #supervisord
    && apk add supervisor \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /var/log/supervisord \
    && echo -e "[supervisord]\ndaemon=true\nuser=root\nlogfile=/var/log/supervisord/supervisord.log\n[include]\nfiles = /etc/supervisor/conf.d/*.conf" > /etc/supervisord.conf \
    \
    #global cleanup
    && apk del gcc gcc-objc g++ make \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/* \
        /etc/ssl/certs/*.pem /etc/ssl/certs/*.0 \
        /usr/share/ca-certificates/mozilla/* \
        /usr/include/*;

COPY ./files /usr/local/

RUN \
    #default settings
    mkdir -p /var/www/html \
    && mv /usr/local/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf \
    && mv /usr/local/nginx/*.conf /etc/nginx/conf.d/ \
    && mv /usr/local/fpm/*.conf /etc/php7/php-fpm.d/ \
    && mv /usr/local/xhprof_enable.php /var/www/xhprof/xhprof_enable.php; \
    \
    #System parameter optimization
    sed -i 's/; process.max = 128/process.max = 512/' /etc/php7/php-fpm.conf \
    && sed -i 's/;rlimit_files = 1024/rlimit_files = 65535/' /etc/php7/php-fpm.conf \
    && sed -i 's/;rlimit_core = 0/rlimit_core = 67108864/' /etc/php7/php-fpm.conf \
    && sed -i 's/;emergency_restart_threshold = 0/emergency_restart_threshold = 60/' /etc/php7/php-fpm.conf \
    && sed -i 's/;emergency_restart_interval = 0/emergency_restart_interval = 60s/' /etc/php7/php-fpm.conf \
    && sed -i 's/post_max_size = 8M/post_max_size = 256M/' /etc/php7/php.ini \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/' /etc/php7/php.ini;

CMD ["sh","/usr/local/start.sh"]
