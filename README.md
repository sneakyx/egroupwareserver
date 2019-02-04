# 1. General info

Works now with mysql 8.0

And by using apt update && apt upgrade -y you can update now even egroupware!

This dockerfile builds an eGroupware container. 

You'll also need a MySQL or MariaDB container for the database.

See also my [extended image](https://hub.docker.com/r/sneaky/egroupware-extended/), which is an extended egroupware (extended by my own apps)!

With Samba Support!

# 2. Egroupware
### General
Egroupware is a very powerful open source groupware programm. It consists of a calendar app, contacts, infolog, project manager, ticket system and more.
If you need more information on egroupware, just take a look here: [www.egroupware.org](http://www.egroupware.org)
Although this is a unofficial dockerfile, it uses just the official sources! 

### Version
This dockerfile installs Version 17.1 of egroupware (and works with apt update && apt upgrade)

# 3. Installation / Configuration
## a) helpful script 
For starting, stopping and updating my egroupware containers, I use my script container_control.sh, which You can download from 
[github](https://github.com/sneakyx/egroupwareserver/blob/master/assets/container_control.sh)

## b)  without script
I don't recommend that, but if You want to do this on own own, you have to write the following lines to get this egroupware container to running:

    Variables for this script:
    
    $2= where to put all egroupware container data
    $3= mysql root database password
    $4= mysql egroupware password
    $5= which port external

Script: (run this script aus sudo!)

        # creating folders
		mkdir -p /home/egroupware/$2/mysql /home/egroupware/$2/data/default/backup /home/egroupware/$2/data/default/files
		touch /home/egroupware/$2/data/header.inc.php
        chown -R www-data:www-data /home/egroupware/$2/data
        chmod 0700 /home/egroupware/$2/data/header.inc.php
        # mysql config for egroupware, problems with new mysql 8.0
        if [ ! -f "/home/egroupware/$2/mysql.cnf" ]; then
            touch /home/egroupware/$2/mysql.cnf
            echo -e "[mysqld]\ndefault_authentication_plugin= mysql_native_password" > /home/egroupware/$2/mysql.cnf
        fi


		# create and run mysql container

		docker run -d --name mysql-egroupware-$2 \
			-e MYSQL_ROOT_PASSWORD=$3 \
			-e MYSQL_DATABASE=egroupware \
			-e MYSQL_USER=egroupware \
			-e MYSQL_PASSWORD=$4 \
			-v /home/egroupware/$2/mysql:/var/lib/mysql \
			-v /home/egroupware/$2/mysql.cnf:/etc/mysql/conf.d/egroupware.cnf \
			mysql
		
		# create and run egroupware container
		
		docker run -d \
			--name egroupware-$2 \
			-p $5:80 \
			-v /home/egroupware/$2/data:/var/lib/egroupware \
			--link mysql-egroupware-$2:mysql \
			-e SUBFOLDER=$6 \
			sneaky/egroupware
		echo container was created/ updated 

## 3.3 Setup Egroupware
### a) First time logging in?
If You started the image for first time, You have to login via
	
	http://ipOfYourServer:4321/
or

	http://ifOfYourServer:4321/egroupware

depending on Your subfolder variable!

You don't have to add database info during installation manually - I updated the files 
- class.setup_header.inc.php
- class.setup_process.inc.php
this way the installation is a bit more automated.
If You have another subfolder than "/egroupware" please make sure that Your data directory is set to "/var/lib/egroupware/default/files" and Your backup is set to "/var/lib/egroupware/default/backup" - otherwise You will loose Your data!
 
Now the installation imports also an existing database backup from egroupware! 
   
### b) Logging in with existing database and data? 

If the file header.inc.php already exists (former installation), the docker-entrypoint.sh updates the database host ip and port in the header.inc.php automaticly!
 
If You updated to a new version of egroupware, don't forget to start the setup and update the database! 

	http://ipOfYourServer:4321/egroupware/setup 

# 4. Additional info
Change all passwords from 123456 to Your own password. 

Remember to put the following informations external, otherwise all data will be lost after updating the image:
- folder for egroupware
- Mysql Database files
(see above for example directory hierarchy!)

If You restart the docker container (former stoped with "docker stop xxx" and now start with "docker start xxx") don't forget to update the mysql-IP-adress by using

	docker exec -it xxx /bin/docker-entrypoint.sh update

# 5. Mount Your Samba Folders
Login to Your docker container with

	docker exec -it egroupware-xxx /bin/bash
then create Your mount points with

	filemanager/cli.php mount --user root_admin --password 123456 'smb://Workgroup\$user:$pass@adressOfServer/path' '/whereToMountInFilemanager'



[![](https://images.microbadger.com/badges/image/sneaky/egroupware.svg)](https://microbadger.com/images/sneaky/egroupware "Get your own image badge on microbadger.com") [Get your own image badge on microbadger.com!](https://microbadger.com)
