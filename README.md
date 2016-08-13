# General info

This dockerfile builds an eGroupware container. The installation is a manual installation. As You can see in the dockerfile, it is based on php 5.6.
You'll also need a MySQL or MariaDB container for the database.
I wanted to install for personal use the visol/egroupware container, but I couldn't reach jrenggli at visol and it seems he doesn't update his egroupware dockerfile- so I made my own and just updated his file. 

# Egroupware
### General
Egroupware is a very powerful open source groupware programm. It consists of a  calendar app, contacts, infolog, project manager, ticket system and more.
If you need more information on egroupware, just take a look here: www.egroupware.org
Although this is a unofficial dockerfile, it uses just the official sources! 

### Version
This dockerfile installs Version 16.1.20160810 of egroupware

# Installation / Configuration
### Data directories (storage)
First, it would be wise to create directories for storing everything in place. I usually pack everything into subfolders under the same superior directory. This way it's easier to create a backup using rsync. (Remember to stop the database before creating a backup!)
I suggest the following directory hierarchy:

/home/egroupware/xxx/mysql  	-> Database
/home/egroupware/xxx/data  	-> Egroupware Files, backups and header.inc


	mkdir -p /home/egroupware/xxx/mysql /home/egroupware/xxx/data
-> Please replace xxx with Your favourite name! <-

### start mysql container

	docker run -d --name mysql-egroupware-xxx \
	-e MYSQL_ROOT_PASSWORD= 1234 \
	-e MYSQL_DATABASE=egroupware \
	-e MYSQL_USER=egroupware \
	-e MYSQL_PASSWORD=1234 \
	-v /home/egroupware/xxx/mysql:/var/lib/mysql mysql
	
-> Please replace xxx with Your favourite name and 1234 with Your password! <-

### start egroupware container
If all variables are set or You want to run the normal setup, just use

	docker run -d \
	--name egroupware-xxx \
	-p 4321:80 \
	-v /home/egroupware/xxx/data:/var/lib/egroupware \
	--link mysql-egroupware-xxx:mysql \
	sneaky/egroupware	


Otherwise use

	docker run -d \
	--name egroupware-xxx \
	-e EGROUPWARE_HEADER_ADMIN_USER=admin \
	-e EGROUPWARE_HEADER_ADMIN_PASSWORD=123456 \
	-e EGROUPWARE_CONFIG_USER=admin \
	-e EGROUPWARE_CONFIG_PASSWD=123456 \
	-p 4321:80 \
	-v /home/egroupware/xxx/data:/var/lib/egroupware \
	--link mysql-egroupware-xxx:mysql \
	sneaky/egroupware

-> Please replace xxx with Your favourite name, 123456 with Your favourite password and 4321 with the port projected for using. If You don't want to map the port, just leave this line <-
### Logging in
If You started the image for first time, You have to login via
	
	http://ipOfYourServer:4321/egroupware
For normal setup (without header information- see above) or
	
	http://ipOfYourServer:4321/egroupware/setup
For setup with provided header information. Please change header and config password- this is a security thing! The Setup admin and Header admin can change Your whole installation!

If Your header.inc.php is still the same, You don't have to do anything- just login. 
If there's a new version of egroupware, You have to start the setup and update the database! (But egroupware will tell You this!) 

# Additional info
Change alle passwords from 1234 to Your own password. 

Remember to put the following informations external, otherwise all data will be lost after restarting or updating the image:
- folder for egroupware
- Mysql Database files
(see above for example directory hierarchy!)

If you have any suggestions, just contact me via: info@rothaarsystems.de
