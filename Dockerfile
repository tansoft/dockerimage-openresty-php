#FROM php:fpm-alpine
#支持的插件列表：ls /usr/src/php/ext/
#RUN docker-php-ext-install bcmath gd gettext mysqli opcache pcntl pdo pdo_mysql sysvmsg
#RUN echo "opcache.file_cache=/tmp" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

FROM openresty/openresty:alpine

COPY ./dependents /usr/local/

RUN mkdir /var/www; \
    mkdir /var/log/nginx; \
    mkdir /var/log/applogs; \
    chmod 777 /var/log/applogs; \
    apk add --no-cache php7 php7-phpdbg php7-fpm php7-dev php7-phar \
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
    echo "memcached.use_sasl = 1" >> /etc/php7/conf.d/20_memcached.ini; \

    #source builder
    apk add --no-cache gcc gcc-objc g++ make; \
    cd /usr/local \

    #yaf
    && wget https://pecl.php.net/get/yaf-3.0.8.tgz \
    && tar zxvf yaf-3.0.8.tgz && cd yaf-3.0.8/ && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/yaf-3.0.8.tgz /usr/local/yaf-3.0.8 \
    && cd /usr/local && echo "extension=yaf.so" > /etc/php7/conf.d/yaf.ini \

    #yar
    && apk add curl-dev \
    && wget https://pecl.php.net/get/yar-2.0.5.tgz \
    && tar zxvf yar-2.0.5.tgz && cd yar-2.0.5/ && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/yar-2.0.5.tgz /usr/local/yar-2.0.5 \
    && apk del curl-dev \
    && cd /usr/local && echo "extension=yar.so" > /etc/php7/conf.d/yar.ini \

    #swoole
    && wget https://pecl.php.net/get/swoole-4.3.1.tgz \
    && tar zxvf swoole-4.3.1.tgz && cd swoole-4.3.1/ && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/swoole-4.3.1.tgz /usr/local/swoole-4.3.1 \
    && cd /usr/local && echo "extension=swoole.so" > /etc/php7/conf.d/swoole.ini \

    #xhprof
    && wget https://github.com/longxinH/xhprof/archive/v2.1.0.tar.gz \
    && tar zxvf v2.1.0.tar.gz && cd xhprof-2.1.0/extension && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/v2.1.0.tar.gz /usr/local/xhprof-2.1.0/extension \
    && mv /usr/local/xhprof-2.1.0 /var/www/xhprof \
    && cd /usr/local && echo -e "[xhprof]\nextension = xhprof.so\nxhprof.output_dir = /tmp/xhprof" > /etc/php7/conf.d/xhprof.ini \

    #donkeyid
    && wget https://github.com/osgochina/donkeyid/archive/donkeyid-1.0.tar.gz \
    && tar zxvf donkeyid-1.0.tar.gz && cd donkeyid-donkeyid-1.0/donkeyid && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/donkeyid-1.0.tar.gz /usr/local/donkeyid-donkeyid-1.0 \
    && cd /usr/local && echo -e "[DonkeyId]\nextension=donkeyid.so\n;0-4095\ndonkeyid.node_id=0\n;0-当前时间戳\ndonkeyid.epoch=0" > /etc/php7/conf.d/donkeyid.ini \

    #xxtea
    && cd /usr/local/xxtea-php && phpize \
    && ./configure && make && make install \
    && rm -rf /usr/local/xxtea-php \
    && cd /usr/local && echo "extension=xxtea.so" > /etc/php7/conf.d/xxtea.ini \

    #global cleanup
    && apk del gcc gcc-objc g++ make \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/* \
        /etc/ssl/certs/*.pem /etc/ssl/certs/*.0 \
        /usr/share/ca-certificates/mozilla/* \
        /usr/include/*;

COPY ./files /usr/local/

RUN \
    #default settings
    mkdir -p /var/www/html; \
    mv /usr/local/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf; \
    mv /usr/local/nginx/*.conf /etc/nginx/conf.d/; \
    mv /usr/local/fpm/*.conf /etc/php7/php-fpm.d/; \

    #系统参数调整
    sed -i 's/; process.max = 128/process.max = 512/' /etc/php7/php-fpm.conf; \
    sed -i 's/;rlimit_files = 1024/rlimit_files = 65535/' /etc/php7/php-fpm.conf; \
    sed -i 's/;rlimit_core = 0/rlimit_core = 67108864/' /etc/php7/php-fpm.conf;

CMD ["sh","/usr/local/start.sh"]
