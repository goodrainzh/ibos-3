FROM ubuntu:precise

MAINTAINER tan min <tanm@goodrain.com>

RUN apt-get update && \
    apt-get install -y supervisor git curl

# install php5.3,module and apache
RUN apt-get install -y \
      apache2 \
      php5 \
      php5-cli \
      php5-gd \
      php5-ldap \
      php5-mysql \
      php-apc \
      php5-mcrypt \
      php5-curl \
      libcurl3 \
      libcurl3-dev \
      libapache2-mod-php5 && \
      echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/default
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN apt-get -y install unzip
ADD IBOS_3.7Pro7698.zip /tmp/IBOS_3.7PRO.zip
RUN unzip -d /app/ /tmp/IBOS_3.7PRO.zip

ADD ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz /app
ADD zend.ini /etc/php5/mods-available/zend.ini
RUN ln -s /etc/php5/mods-available/zend.ini /etc/php5/apache2/conf.d/zend.ini

RUN chmod -R 777 /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD config.php /app/system/config/config.php
RUN chmod -R 777 /app

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 50M
ENV PHP_POST_MAX_SIZE 50M

VOLUME /data
EXPOSE 80

ENTRYPOINT /run.sh
