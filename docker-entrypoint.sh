#!/bin/bash
set -e
# this is a copy of docker-entrypoint.sh of jrenggli (see also visol/egroupware)

# Replace {key} with value
set_config() {
	key="$1"
	value="$2"
	php_escaped_value="$(php -r 'var_export($argv[1]);' "$value")"
	sed_escaped_value="$(echo "$php_escaped_value" | sed 's/[\/&]/\\&/g')"
	sed -ri "s/(['\"])?\{$key\}(['\"])?/$sed_escaped_value/" /var/www/html/egroupware/header.inc.php
}



#
# Initialization vector for mcrypt
#

# Ensure mcrypt_iv exists. Generate if necessary
if [ ! -f /var/lib/egroupware/mcrypt_iv ]; then
	echo Generate the initialization vector for mcrypt
	echo
	echo      Except from egroupware documentation:
	echo      This is a random string used as the initialization vector for mcrypt
	echo      feel free to change it when setting up eGrouWare on a clean database,
	echo      but you must not change it after that point!
	echo      It should be around 30 bytes in length.
	echo

	pwgen -s 30 > /var/lib/egroupware/mcrypt_iv
fi

set_config 'MCRYPT_IV' "`cat /var/lib/egroupware/mcrypt_iv`"



#
# database configuration
#

if [ -z "$MYSQL_PORT_3306_TCP" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

set_config 'DB_HOST' "$MYSQL_PORT_3306_TCP_ADDR"
set_config 'DB_PORT' "$MYSQL_PORT_3306_TCP_PORT"
set_config 'DB_NAME' "$MYSQL_ENV_MYSQL_DATABASE"
set_config 'DB_USER' "$MYSQL_ENV_MYSQL_USER"
set_config 'DB_PASS' "$MYSQL_ENV_MYSQL_PASSWORD"



#
# header admin / config password
#

hash_password() {
	password="$1"
	php -r "echo('{crypt}' . crypt('${password}', '\$2a\$12\$' . substr(trim(file_get_contents('/var/lib/egroupware/mcrypt_iv')), 0, 22)));"
}


EGROUPWARE_HEADER_ADMIN_USER=${EGROUPWARE_HEADER_ADMIN_USER-"admin"}
EGROUPWARE_HEADER_ADMIN_PASSWORD=${EGROUPWARE_HEADER_ADMIN_PASSWORD-"password"}
EGROUPWARE_CONFIG_USER=${EGROUPWARE_CONFIG_USER-"admin"}
EGROUPWARE_CONFIG_PASSWD=${EGROUPWARE_CONFIG_PASSWD-"password"}

set_config 'HEADER_ADMIN_USER' "$EGROUPWARE_HEADER_ADMIN_USER"
set_config 'HEADER_ADMIN_PASSWORD' "$(hash_password $EGROUPWARE_HEADER_ADMIN_PASSWORD)"
set_config 'CONFIG_USER' "$EGROUPWARE_CONFIG_USER"
set_config 'CONFIG_PASSWD' "$(hash_password $EGROUPWARE_CONFIG_PASSWD)"



#
# data directories
#

mkdir -p /var/lib/egroupware/default/backup
mkdir -p /var/lib/egroupware/default/files
chown -R www-data:www-data /var/lib/egroupware



case "$1" in
	app:start)
		# Apache gets grumpy about PID files pre-existing
		rm -f /var/run/apache2/apache2.pid
		exec apache2 -DFOREGROUND
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0