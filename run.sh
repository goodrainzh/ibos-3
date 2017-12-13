#!/bin/bash

[ $DEBUG ] && set -x
sleep ${PAUSE:-0}

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini

sed -ri -e "s/^;extension=curl.so.*/extension=curl.so/" \
    -e "s/^;extension=php_gd2.so.*/extension=php_gd2.so/" /etc/php5/apache2/php.ini

# connect mysql use goodrain platform inject env 
sed -ri -e "s/-host-*/$MYSQL_HOST/" /app/system/config/config.php
sed -ri -e "s/-port-*/$MYSQL_PORT/" /app/system/config/config.php
sed -ri -e "s/-user-*/$MYSQL_USER/" /app/system/config/config.php
sed -ri -e "s/-pwd-*/$MYSQL_PASS/" /app/system/config/config.php
chmod -R 777 /app 

# first step
if [ ! -f /app/data/install.lock ]; then
    mkdir -p /data
    cp -r /app/data/* /data
    rm -rf /app/data
    chmod -R 777 /data
    ln -s /data /app/data

    #link config.php
    cp /app/system/config/config.php /data
fi

rm /app/system/config/config.php
ln -s /data/config.php /app/system/config/config.php

exec supervisord -n
