#!/bin/bash
set -e
# this is a fork of docker-entrypoint.sh of jrenggli (see also visol/egroupware)
# made by sneaky of Rothaar Systems (Andre Scholz)
# V2016-08-20-15-50
  
  
# Replace {key} with value
set_config() {
	key="$1"
	value="$2"
	php_escaped_value="$(php -r 'var_export($argv[1]);' "$value")"
	sed_escaped_value="$(echo "$php_escaped_value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/(['\"])?$key(['\"]).*/\'$key\' => $sed_escaped_value/" /var/lib/egroupware/header.inc.php

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

# create empty header file, if not exists
touch /var/lib/egroupware/header.inc.php

# create file with database infos
echo 'db_host = ' $MYSQL_PORT_3306_TCP_ADDR > /var/lib/egroupware/db-config.txt
echo 'db_port = ' $MYSQL_PORT_3306_TCP_PORT >> /var/lib/egroupware/db-config.txt  

chown -R www-data:www-data /var/lib/egroupware

ln -sf /var/lib/egroupware/header.inc.php /var/www/html/egroupware/header.inc.php
chmod 700 /var/lib/egroupware/header.inc.php

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid
exec apache2 -DFOREGROUND 

exit 0