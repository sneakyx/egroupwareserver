FROM debian:stretch
MAINTAINER André Scholz <info@rothaarsystems.de>
# Version 2017-12-02-17-00

ENV DEBIAN_FRONTEND noninteractive
ARG egr_timezone=Europe/Berlin
RUN echo 'deb http://download.opensuse.org/repositories/server:/eGroupWare/Debian_9.0/ /' > /etc/apt/sources.list.d/egroupware-epl.list \
		&& apt-get update \
		&& apt-get upgrade -y \
		&& apt-get install wget gnupg -y
# start egroupware installation
RUN wget -nv https://download.opensuse.org/repositories/server:eGroupWare/Debian_9.0/Release.key -O Release.key \
	&& apt-key add - < Release.key \
	&& apt-get update 
RUN echo "Package: mariadb*" >> /etc/apt/preferences \
	&& echo "Pin: release *" >> /etc/apt/preferences \
	&& echo "Pin-Priority: -1" >> /etc/apt/preferences \
	&& apt-get install -y egroupware-epl 	
	
# edit php.ini
RUN mv /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini~ \
	&& cat /etc/php/7.0/apache2/php.ini~ | grep -v upload_max_file > /etc/php/7.0/apache2/php.ini \
	&& echo date.timezone = $egr_timezone >> /etc/php/7.0/apache2/php.ini \
    && echo session.save_path = /var/tmp  >> /etc/php/7.0/apache2/php.ini \
    && echo upload_max_filesize = 60M  >> /etc/php/7.0/apache2/php.ini

COPY assets/docker-entrypoint.sh /bin/entrypoint.sh 
#RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf~ \
#	&& mkdir /var/www/html/egroupware
#COPY assets/apache.conf /etc/apache2/apache2.conf
# there are two updated files
# because manual installation of egroupware leaves some infos blank
COPY assets/class*.* /usr/share/egroupware/setup/inc/

RUN chmod +x /bin/entrypoint.sh 

EXPOSE 80 443

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["app:start"]