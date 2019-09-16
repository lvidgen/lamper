# lamper
## A bash script to install, configure and test a fresh LAMP stack

### Features
Only tested on Ubuntu but should work anywhere that uses apt.

Prompts to set a password for root account on mysql. 

Asks if you want to set up a virtual host (uses Apache's default /var/www/html if not)

Installs:
* [Apache2 server](https://httpd.apache.org)
* [MySQL](https://www.mysql.com/)
* [php](https://www.php.net/)
* php-mysql mod
* libapache2-mod-php mod


Configures:
* ufw firewall
* php error logs
* permissions on virtual host folder

If you asked to set up a virtual host it enables that and disables Apache's default.

Restarts Apache so the new config kicks in.

Places lamptest.php in your root folder which tells you if Apache, PHP and MySQL are functioning correctly - just browse to localhost/lamptest.php to see the results (requires JavaScript).

### Usage
Same as any bash script - save it wherever, cd to that directory and set it to executable by running 

`sudo chmod u+x lamper.sh`

Run it by calling

`sudo ./lamper.sh`

### A one-liner alternative
If you just want a basic installation with no firewall, no error logging and no virtual host, you can run

`sudo apt install apache2 mysql-server php-mysql libapache2-mod-php -y`

from the command line
