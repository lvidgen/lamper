#!/bin/bash 

#need sudo for later stuff        
if [ ! $EUID = 0 ]; then
    echo "Script must be run with root privileges. Aborting."
    exit 2
fi

read -sp "Choose password for root mysql user: " passvar
echo ""
while [[ $choice != "n" && $choice != "y" ]];
    do
    read -p "Set up virtual host? (y/n) " choice
done

if [[ $choice == "y" ]];
    then
    read -p "Enter virtual host domain name: " vhost
    sudo mkdir -p /var/www/html/$vhost/public_html
fi

echo -n "Preparing installation."
sleep 1
echo -n "."
sleep 1
echo "."
sleep 1

sudo apt install apache2 mysql-server php-mysql libapache2-mod-php* -y

#firewall config
sudo ufw app info "Apache Full"
sudo ufw allow in "Apache Full"

#php.ini logging settings
inifile=$(sudo find /etc/ -name php.ini | grep 'apache2')
sudo sed -i 's@;error_log = php_errors.log@error_log = /var/log/php/error.log@g' $inifile 
sudo sed -i 's@error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT@error_reporting = E_COMPILE_ERROR | E_RECOVERABLE_ERROR | E_ERROR | E_CORE_ERROR@g' $inifile 

#make logging directory and give access
sudo mkdir /var/log/php
sudo chown www-data /var/log/php

#change password for root account in mysql
sudo mysql -u root<<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$passvar';
EOF

#set up virtual host
if [ $vhost ]
    then
    CONFILE=/etc/apache2/sites-available/"$vhost".conf
    sudo sh -c cat <<EOM >$CONFILE
<Directory /var/www/html/$vhost/public_html>
        Require all granted
</Directory>
<VirtualHost *:80>
        ServerName $vhost
        ServerAlias www.$vhost
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/$vhost/public_html

        ErrorLog /var/www/html/$vhost/logs/error.log
        CustomLog /var/www/html/$vhost/logs/access.log combined

</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOM

    sudo mkdir -p /var/www/html/$vhost/{public_html,logs}

#give permissions to user (not root)
    me=$(logname)
    rootdir=/var/www/html/$vhost/public_html
    sudo chown -R $me:$me $rootdir
    sudo chmod -R 755 $rootdir

#enable virtual host and disable default site
    sudo a2ensite $vhost > /dev/null 2>&1
    sudo a2dissite 000-default.conf > /dev/null 2>&1

    else
        rootdir=/var/www/html
fi

#make test page
FILE="$rootdir/lamptest.php"
sudo sh -c cat <<EOM >$FILE
<html>
<head>
<title>LAMP Test</title>
<style>
</style>
</head>
    <body>
    <h1>Connected successfully to Apache server</h1>
    <h3 id="phpstatus"></h3>
    <p id="mysqlstatus"></p>
    <?php
    \$servername = "localhost";
    \$username = "root"; 
    \$conn = mysqli_connect(\$servername, \$username, "$passvar");
    \$errno = mysqli_connect_errno();
    phpinfo();    
?>
<script>
var php = "<?php echo 1 ?>";
document.getElementById("phpstatus").textContent = php=="1"?"PHP working correctly (see below for details)":"PHP did not install correctly";
var conn = "<?php echo \$errno ?>";
document.getElementById("mysqlstatus").textContent = conn=="0"?"MySQL Connected successfully":"MySQL Connection failed";
</script>
</body>
</html>
EOM

#restart so that new config kicks in
sudo apachectl -k restart
echo ""
echo "Setup complete. Your root web folder is located at $rootdir"
echo "Open a browser at localhost/lamptest.php to confirm installation."