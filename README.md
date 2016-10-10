# 1. General info

This dockerfile builds an eGroupware container. As You can see in the dockerfile, it is based on php 5.6.
You'll also need a MySQL or MariaDB container for the database.
I wanted to install for personal use the visol/egroupware container, but I couldn't reach jrenggli at visol and it seems he doesn't update his egroupware dockerfile- so I made my own and not just updated his file. 

See also my [extended image](https://hub.docker.com/r/sneaky/egroupware-extended/), which is an extended egroupware (extended by my own apps)!


# 2. Egroupware
### General
Egroupware is a very powerful open source groupware programm. It consists of a calendar app, contacts, infolog, project manager, ticket system and more.
If you need more information on egroupware, just take a look here: [www.egroupware.org](http://www.egroupware.org)
Although this is a unofficial dockerfile, it uses just the official sources! 

### Version
This dockerfile installs Version 16.1.20161006 of egroupware

# 3. Installation / Configuration
## a) helpful script 
For starting, stopping and updating my egroupware containers, I use my script container_control.sh, which You can download from 
[github](https://github.com/sneakyx/egroupwareserver/blob/master/assets/container_control.sh)

## b)  without script

### b) 1. Data directories (storage)
First, it would be wise to create directories for storing everything in place. I usually pack everything into subfolders under the same superior directory. This way it's easier to create a backup using rsync. (Remember to stop the database before creating a backup!)
I suggest the following directory hierarchy:

/home/egroupware/xxx/mysql  	-> Database
/home/egroupware/xxx/data  	-> Egroupware Files, backups and header.inc

	mkdir -p /home/egroupware/xxx/mysql /home/egroupware/xxx/data
-> Please replace xxx with Your favourite name! <-

### b) 2. start mysql container

	docker run -d --name mysql-egroupware-xxx \
	-e MYSQL_ROOT_PASSWORD=123456 \
	-e MYSQL_DATABASE=egroupware \
	-e MYSQL_USER=egroupware \
	-e MYSQL_PASSWORD=123456 \
	-v /home/egroupware/xxx/mysql:/var/lib/mysql mysql
	
-> Please replace xxx with Your favourite name and 123456 with Your password! <-

### b) 3. start egroupware container 
To start the egroupware container, just use:
basic version:

	docker run -d \
	--name egroupware-xxx \
	-p 4321:80 \
	-v /home/egroupware/xxx/data:/var/lib/egroupware \
	--link mysql-egroupware-xxx:mysql \
	sneaky/egroupware	
	
-> Please replace xxx with Your favourite name and 4321 with the port projected for using. If You don't want to map the port, just leave the line "-p 4321:80"<-

## 3.3 Setup Egroupware
### a) First time logging in?
If You started the image for first time, You have to login via
	
	http://ipOfYourServer:4321/

You don't have to add database info during installation manually - I updated the files 
- class.setup_header.inc.php
- class.setup_process.inc.php
this way the installation is a bit more automated.
Now the installation imports also an existing database backup from egroupware! 
   
### b) Logging in with existing database and data? 

If the file header.inc.php already exists (former installation), the docker-entrypoint.sh updates the database host ip and port in the header.inc.php automaticly!
 
If there's a new version of egroupware, You have to start the setup and update the database! (But egroupware will tell You this!) 

# Additional info
Change all passwords from 123456 to Your own password. 

Remember to put the following informations external, otherwise all data will be lost after updating the image:
- folder for egroupware
- Mysql Database files
(see above for example directory hierarchy!)

If You restart the docker container (former stoped with "docker stop xxx" and now start with "docker start xxx") don't forget to update the mysql-IP-adress by using

	docker exec -it xxx /docker-entrypoint.sh update


If you have any suggestions, questions or You need a special egroupware application, just contact me via: info@rothaarsystems.de

[![](https://images.microbadger.com/badges/image/sneaky/egroupware.svg)](https://microbadger.com/images/sneaky/egroupware "Get your own image badge on microbadger.com") [Get your own image badge on microbadger.com!](https://microbadger.com)