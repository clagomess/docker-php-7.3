FROM debian:10

RUN apt update
RUN apt install build-essential -y
RUN apt install apache2 php php-mbstring php-pgsql php-soap php-pear php-dev vim wget -y

# php xdebug
RUN pecl channel-update pecl.php.net
RUN pecl install xdebug
RUN echo "zend_extension=xdebug.so" > /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_enable=1" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_handler=dbgp" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_mode=req" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_host=host.docker.internal" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_port=9000" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_autostart=1" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.extended_info=1" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& echo "xdebug.remote_connect_back = 0" >> /etc/php/7.3/apache2/conf.d/xdebug.ini \
&& cp /etc/php/7.3/apache2/conf.d/xdebug.ini /etc/php/7.3/cli/conf.d/

# config httpd
RUN sed -i -- "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf \
&& sed -i -- "s/AllowOverride none/AllowOverride All/g" /etc/apache2/apache2.conf

# config php
RUN echo "date.timezone = America/Sao_Paulo" > /etc/php/7.3/apache2/conf.d/sistemas.ini \
&& echo "short_open_tag=On" >> /etc/php/7.3/apache2/conf.d/sistemas.ini \
&& echo "display_errors = On" >> /etc/php/7.3/apache2/conf.d/sistemas.ini \
&& echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" >> /etc/php/7.3/apache2/conf.d/sistemas.ini \
&& cp /etc/php/7.3/apache2/conf.d/sistemas.ini /etc/php/7.3/cli/conf.d/

# config oracle
RUN apt install unzip libaio-dev -y && mkdir /opt/oracle
RUN wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip -P /opt/oracle \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip -P /opt/oracle
RUN unzip /opt/oracle/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip -d /opt/oracle \
&& unzip /opt/oracle/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip -d /opt/oracle
RUN echo 'instantclient,/opt/oracle/instantclient_19_6' | pecl install oci8
RUN echo "extension=oci8.so" > /etc/php/7.3/apache2/conf.d/oci8.ini \
&& cp /etc/php/7.3/apache2/conf.d/oci8.ini /etc/php/7.3/cli/conf.d/
RUN echo "/opt/oracle/instantclient_19_6" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# config log
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
&& ln -sf /dev/stderr /var/log/apache2/error.log