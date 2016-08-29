FROM sneaky/egroupware:latest
MAINTAINER André Scholz <info@rothaarsystems.de>
# still beta
# V 2016-08-29-207-30

# load newest version of apps
RUN apt-get update \
	&& apt-get install unzip \
	&& wget -P /var/www http://downloads.sourceforge.net/project/rosin/current/rosine-2016-08-27-21-45.zip \
	&& mv /var/www/rosine*.zip /var/www/html/egroupware/rosine.zip \
	&& unzip /var/www/html/egroupware/rosine.zip -d /var/www/html/egroupware/ \
	&& mv /var/www/html/egroupware/ROSInE /var/www/html/egroupware/rosine \
	&& rm /var/www/html/egroupware/rosine.zip \
	&& chmod -R +r+x /var/www/html/egroupware/rosine  
	
# overwrite standard html from Egroupware because my apps use HTML5 and chmod all changed egroupware files
RUN		sed -i -e 1c"<!-- BEGIN head --><!DOCTYPE html>" /var/www/html/egroupware/pixelegg/head.tpl \
	&& 	sed -i -e 2c"<html>" /var/www/html/egroupware/pixelegg/head.tpl 
# overwrite docker-entrypoint.sh
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"] 