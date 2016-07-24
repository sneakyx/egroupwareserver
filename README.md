# Information

This dockerfile builds an eGroupware container. The installation is a manual installation. As You can see in the dockerfile, it is based on php 5.6.
You'll also need a MySQL or MariaDB container for the database. 

## Egroupware Version
installs Version 16.1.20160715 of egroupware
For more information on egroupware read here: www.egroupware.org

# Quick info
You can launch the image via terminal / command line using docker
(I'm going to add this next week.)

The following informations have to be put external, otherwise they will be lost after restarting or updating the image:
- header.inc.php
- folder for files (path depending on Your configuration)
- folder for backups (path depending on Your configuration)


