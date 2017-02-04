FROM php:5.6-apache
MAINTAINER André Scholz <info@rothaarsystems.de>
# Version 2017-02-04-17-16

ENV DEBIAN_FRONTEND noninteractive
ARG egr_timezone=Europe/Berlin
RUN apt-get update \
        && apt-get install -y wget bzip2 libbz2-dev zlib1g-dev re2c libmcrypt-dev pwgen \
        && wget -P /usr/share https://github.com/EGroupware/egroupware/releases/download/16.1.20170203/egroupware-epl-16.1.20170203.tar.bz2\
        && mv /usr/share/egroupware*.tar.bz2 /usr/share/egroupware.tar.bz2 \
        && tar -xjf /usr/share/egroupware.tar.bz2 -C /usr/share \
        && rm /usr/share/egroupware.tar.bz2
# start manual installation

RUN docker-php-ext-install mysqli \
		&& docker-php-ext-install bz2 \
        && docker-php-ext-install pdo_mysql \
        && docker-php-ext-install zip \
        && docker-php-ext-install mcrypt \
        && docker-php-ext-install mbstring \
        && apt-get -y install libtidy-dev libjpeg62-turbo-dev libpng12-dev libldap2-dev \
        && docker-php-ext-install tidy \
        && docker-php-ext-install bcmath \
        && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
        && docker-php-ext-install gd \
        && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/  \
        && docker-php-ext-install ldap
# edit php.ini

RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo date.timezone = $egr_timezone  >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo session.save_path = /var/tmp  >> /usr/local/etc/php/conf.d/uploads.ini


COPY assets/docker-entrypoint.sh /bin/entrypoint.sh 
COPY assets/apache.conf /etc/apache2/apache2.conf
# there are two updated files
# because manual installation of egroupware leaves some infos blank
COPY assets/class*.* /usr/share/egroupware/setup/inc/

RUN chmod +x /bin/entrypoint.sh \
	&& chmod 644 /usr/share/egroupware/setup/inc/*.* 

EXPOSE 80 443

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["app:start"]