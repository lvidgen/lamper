# lamper
## A bash script to install, configure and test a fresh LAMP stack

### Features
Only tested on Ubuntu but should work anywhere that uses apt.

Prompts to set a password for root account on mysql. 

Asks if you want to set up a virtual host (uses Apache's default /var/www/html if not)

Configures:
* ufw firewall
* php error logs
* permissions on virtual host folder

If you asked to set up a host site it enables that and disables Apache's default site.

Restarts Apache so that new config kicks in.

Places lamptest.php in your root folder which tells you if Apache, PHP and MySQL are functioning correctly - just browse to localhost/lamptest.php to see the results (requires JavaScript).

### Usage
Same as any bash script - save it wherever, cd to that directory and set it to executable by running 

`sudo chmod u+x lamper.sh`

Run it by calling

`sudo ./lamper.sh`
