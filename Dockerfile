FROM debian:stretch
MAINTAINER André Scholz <info@rothaarsystems.de>
# Version 2017-12-29-20-30

ENV DEBIAN_FRONTEND noninteractive
ARG egr_timezone=Europe/Berlin
RUN apt-get update \
		&& apt-get upgrade -y \
		&& apt-get install wget gnupg -y
# start egroupware installation
RUN echo "Package: mariadb*" >> /etc/apt/preferences \
	&& echo "Pin: release *" >> /etc/apt/preferences \
	&& echo "Pin-Priority: -1" >> /etc/apt/preferences \
	&& apt-get install    apache2 apache2-bin apache2-data apache2-utils bzip2  file fontconfig-config fonts-dejavu-core \
  libapache2-mod-php libapache2-mod-php7.0 libapr1 libaprutil1 \
  libaprutil1-dbd-sqlite3 libaprutil1-ldap libbsd0 libedit2 libexpat1 \
  libfontconfig1 libfreetype6 libgd3 libgdbm3 libgpm2 libicu57 libjbig0 \
  libjpeg62-turbo liblua5.2-0 libmagic-mgc libmagic1 libncurses5 libnghttp2-14 \
  libperl5.24 libpng16-16 libprocps6 libssl1.0.2 libtidy5 libtiff5 libwebp6 \
  libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxml2 libxpm4 libxslt1.1 \
  libzip4 mime-support perl perl-modules-5.24 php-apcu php-apcu-bc php-bcmath \
  php-bz2 php-common php-gd php-ldap php-mbstring php-mysql php-tidy php-zip \
  php7.0-bcmath php7.0-bz2 php7.0-cli php7.0-common php7.0-gd php7.0-json \
  php7.0-ldap php7.0-mbstring php7.0-mysql php7.0-opcache php7.0-readline \
  php7.0-tidy php7.0-xml php7.0-zip procps psmisc rename sgml-base ssl-cert \
  ucf xml-core xz-utils cifs-utils -y
	
	
# edit php.ini
RUN mv /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini~ \
	&& cat /etc/php/7.0/apache2/php.ini~ | grep -v upload_max_file > /etc/php/7.0/apache2/php.ini \
	&& echo date.timezone = $egr_timezone >> /etc/php/7.0/apache2/php.ini \
    && echo session.save_path = /var/tmp  >> /etc/php/7.0/apache2/php.ini \
    && echo upload_max_filesize = 60M  >> /etc/php/7.0/apache2/php.ini

COPY assets/docker-entrypoint.sh /bin/entrypoint.sh 

# there are two updated files
# because manual installation of egroupware leaves some infos blank
COPY assets/class*.* /usr/share/egroupware/setup/inc/

RUN chmod +x /bin/entrypoint.sh 

EXPOSE 80 443

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["app:start"]