FROM ubuntu:18.04
MAINTAINER josean1968@gmail.com

ENV TZ="Europe/Madrid"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

ARG CSDK_TMPDIR=/tmp/informix
ARG CSDK=ibm.csdk.4.50.FC1.LNX.tar

RUN apt update \
    && apt -y upgrade \
    && apt -y install \
        apache2 \
        libapache2-mod-php \
        language-pack-es \
        php-dev \
        php-mbstring \
        gcc \
        make \
    && apt-get clean \
    && apt-get autoremove


# Get Informix Client SDK (v4.50) from:
# https://www-01.ibm.com/marketing/iwm/iwm/web/preLogin.do?source=ifxdl&S_PKG=450FC1linux&lang=en_US
COPY /files/informix/${CSDK} /tmp/
ENV INFORMIXDIR /opt/IBM/Informix_Client-SDK
RUN mkdir -p ${CSDK_TMPDIR} \
    && tar -xf /tmp/${CSDK} -C ${CSDK_TMPDIR} \
    && rm -f /tmp/${CSDK} \
    && ${CSDK_TMPDIR}/installclientsdk -i silent -DLICENSE_ACCEPTED=TRUE -r ${CSDK_TMPDIR} \
    && rm -rf ${CSDK_TMPDIR} \
    && echo ${INFORMIXDIR}/lib > /etc/ld.so.conf.d/informix.conf \
    && echo ${INFORMIXDIR}/lib/esql >> /etc/ld.so.conf.d/informix.conf \
    && ldconfig


# Install the PDO_INFORMIX extension
# The symbolic link is created to help PDO_INFORMIX finding the necessary headers
# ln -s $(php-config --include-dir)/ext /usr/include/php/ext
# Otherwise, the configure script will show this error:
# On error: checking for PDO includes... configure: error: Cannot find php_pdo_driver.h
RUN curl https://pecl.php.net/get/PDO_INFORMIX-1.3.3.tgz \
    | tar -xzC /usr/local/src/ \
    && cd /usr/local/src/PDO_INFORMIX-1.3.3/ \
    && phpize \
    && ln -s $(php-config --include-dir)/ext /usr/include/php/ext \
    && ./configure \
    && make install \
    && cd \
    && rm -rf /usr/local/src/PDO_INFORMIX-1.3.3/ \
    && echo extension=pdo_informix.so > /etc/php/7.2/mods-available/pdo_informix.ini \
    && phpenmod pdo_informix


COPY /files/informix/sqlhosts ${INFORMIXDIR}/etc/
ENV DBDATE DMY4/
ENV PATH $PATH:$INFORMIXDIR/bin
ENV CLIENT_LOCALE=es_ES.819
ENV DB_LOCALE=es_ES.819


COPY /files/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
WORKDIR /var/local/www/
RUN mkdir /var/local/www/public/ \
    && echo "<?php phpinfo();" > /var/local/www/public/info.php


# CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
