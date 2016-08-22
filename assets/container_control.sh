#!/bin/bash

#########################################################################
#                          build_new_container.sh                       #
#    this script makes it easier to build a new egroupware container    #
# usage:        build_new_container.sh $name $pass1 $pass2 $port $action#
# Paramters:                                                            #
#               $action create/stop/delete/start/update/full-delete     #
#                       (full-delete deletes also database -all Your    #
#                       data will be lost- use with cation!)            #
#                       (start means existing container!)               # 
#               $name   exchange with Your favorite name   (needed)     #
#               $pass1  password for mysql admin    \   only used       #
#               $pass2  password for egroupware user >  with parameter  #
#               $port   which port should be used?  /   create!         #
#-----------------------------------------------------------------------#
#      V 2016-08-20-17-30  made by sneaky(x) or Rothaar Systems         #
#                        dedicated to my family                         #
#                   released under Apache 2.0 licence                   #
#               http://www.apache.org/licenses/LICENSE-2.0              #
#########################################################################

if  [ -z $2 ]  ; then
        echo >&2 'error: missing parameters'
        echo >&2 'usage: build_new_container.sh start/stop/update/create/delete/full-delete $name'
        exit 1
fi
case "$1" in
	stop)
		# just stops container
		docker stop mysql-egroupware-$2 egroupware-$2
		echo container was stoped
	;;
	start)
		# just starts container
		docker start mysql-egroupware-$2 egroupware-$2
		echo container was started
	;;
	delete)
		# stops and deletes container
		docker stop mysql-egroupware-$2 egroupware-$2
		docker rm mysql-egroupware-$2 egroupware-$2
		echo container was deleted, data is stored in /home/egroupware/$1
	;;
	
	full-delete)
		# stops and deletes container
		# deletes also all Your data stored in container!
		docker stop mysql-egroupware-$2 egroupware-$2
		docker rm mysql-egroupware-$2 egroupware-$2
		rm -r /home/egroupware/$2
		echo all Your data was deleted!
	;;
	update)
		# stops, deletes and updates the container.
		if  [ -z $3 ] && [ -z $4 ] && [ -z $5 ]; then
	        echo >&2 'error: missing parameters'
	        echo >&2 'usage: build_new_container.sh start/stop/update/create $name $root-pass $pass2 $port'
	        exit 1
		fi	

		docker pull mysql
		docker pull sneaky/egroupware
		docker stop mysql-egroupware-$2 egroupware-$2
		docker rm mysql-egroupware-$2 egroupware-$2
		
	;&
	
	create)
		# creates new images 
		if  [ -z $3 ] && [ -z $4 ] && [ -z $5 ]; then
	        echo >&2 'error: missing parameters'
	        echo >&2 'usage: build_new_container.sh start/stop/update/create $name $root-pass $pass2 $port'
	        exit 1
		fi	
		# creating folders
		mkdir -p /home/egroupware/$2/mysql /home/egroupware/$2/data
		
		# create and run mysql container
		
		docker run -d --name mysql-egroupware-$2 \
			-e MYSQL_ROOT_PASSWORD=$3 \
			-e MYSQL_DATABASE=egroupware \
			-e MYSQL_USER=egroupware \
			-e MYSQL_PASSWORD=$4 \
			-v /home/egroupware/$2/mysql:/var/lib/mysql mysql
		
		# create and run egroupware container
		
		docker run -d \
			--name egroupware-$2 \
			-p $5:80 \
			-v /home/egroupware/$2/data:/var/lib/egroupware \
			--link mysql-egroupware-$2:mysql \
			sneaky/egroupware
		echo container was created/ updated
	;;
	*)	
		echo >&2 'error: missing parameters'
        echo >&2 'usage: build_new_container.sh start/stop/update/create/delete/full-delete $name'
        	
esac