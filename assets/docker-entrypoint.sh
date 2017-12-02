#!/bin/bash
set -e
# this is a fork of docker-entrypoint.sh of jrenggli (see also visol/egroupware)
# made by sneaky of Rothaar Systems (Andre Scholz)
# V2016-12-29-07-40
  
  
# Replace {key} with value
set_config() {
	key="$1"
	value="$2"
	php_escaped_value="$(php -r 'var_export($argv[1]);' "$value")"
	sed_escaped_value="$(echo "$php_escaped_value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/(['\"])?$key(['\"]).*/\'$key\' => $sed_escaped_value,/" /var/lib/egroupware/header.inc.php

}

# database configuration
#

if [ -z "$MYSQL_PORT_3306_TCP" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

if [ -f /var/lib/egroupware/header.inc.php ] ;
# if header file exists correct the tcp-port and tcp address
# otherwise (first time startup) the data has to be add manually while installation
# read the necessary data from file /home/egroupware/xxx/data/db-info.txt 
# xxx - is the directory you used for storing data

then
	
	set_config 'db_host' "$MYSQL_PORT_3306_TCP_ADDR"
	set_config 'db_port' "$MYSQL_PORT_3306_TCP_PORT"

fi	
		
#
# data directories
#
	
mkdir --parents /var/lib/egroupware/default/backup
mkdir --parents /var/lib/egroupware/default/files

# create file with database infos
echo 'db_host = ' $MYSQL_PORT_3306_TCP_ADDR > /var/lib/egroupware/config-now.txt
echo 'db_port = ' $MYSQL_PORT_3306_TCP_PORT >> /var/lib/egroupware/config-now.txt  
echo 'www_dir = ' ${SUBFOLDER} >> /var/lib/egroupware/config-now.txt

chown -R www-data:www-data /var/lib/egroupware
# delete origin header.inc from container and use your header.inc
ln -sf /var/lib/egroupware/header.inc.php /usr/share/egroupware/header.inc.php
chmod 700 /var/lib/egroupware/header.inc.php

if [ ${SUBFOLDER: -1} == "/" ]; then
	# this is for leaving the last slash 
 	SUBFOLDER="${SUBFOLDER:0: -1}"
 	echo 'www_dir1 = ' ${SUBFOLDER} >> /var/lib/egroupware/config-now.txt
fi

if [ -z "$SUBFOLDER" ]; then
	# this is for the case that no subfolder is passed  
	rmdir /var/www/html
	echo 'www_dir 2= ' ${SUBFOLDER} >> /var/lib/egroupware/config-now.txt
elif [ ${SUBFOLDER:0:1} != "/" ]; then
	# this is for the case that the first slash is forgotten
	SUBFOLDER="/${SUBFOLDER}"
	echo 'www_dir3 = ' ${SUBFOLDER} >> /var/lib/egroupware/config-now.txt
fi

if  [ $1 != "update" ]; then  # if container isn't restarted
	echo 'www_dir4 = ' ${SUBFOLDER} >> /var/lib/egroupware/config-now.txt
	# Apache gets grumpy about PID files pre-existing
	rm -f /var/run/apache2/apache2.pid
	mkdir -p /var/www/html$SUBFOLDER
	ln -sf /usr/share/egroupware /var/www/html$SUBFOLDER$SUBFOLDER
	exec apache2 -DFOREGROUND
	 
fi
exit 0