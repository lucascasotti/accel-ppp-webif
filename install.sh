#!/bin/sh

if ! [ $(id -u) = 0 ]; then
   echo "Execute como root para prosseguir!"
   exit 1
fi

sudo apt-get update
sudo apt-get -y install git
sudo apt-get -y install ifstat
sudo apt -y install wget unzip unzip
sudo apt-get -y install apache2 php php-common libapache2-mod-php
sudo apt -y install php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath
wget -O composer-setup.php https://getcomposer.org/installer
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
sudo composer self-update
sudo apt -y install libapache2-mod-php
sudo a2enmod php7.*
sudo rm -rf /etc/apache2/conf-available/disable-env.conf
sudo touch /etc/apache2/conf-available/disable-env.conf
sudo chmod 777 /etc/apache2/conf-available/disable-env.conf
sudo echo "<Directory /var/www/html>
  # Disable Directory listing
  Options -Indexes

  # block files which needs to be hidden // in here specify .example extension of the file
  <Files ~ \"\.(env|json|config.js|md|gitignore|gitattributes|lock)$\">
      Order allow,deny
      Deny from all
  </Files>

  # in here specify full file name sperator '|'
  <Files ~ \"(artisan)$\">
      Order allow,deny
      Deny from all
  </Files>
</Directory>" >> /etc/apache2/conf-available/disable-env.conf
sudo chmod 644 /etc/apache2/conf-available/disable-env.conf
sudo a2enconf disable-env.conf 
sudo systemctl restart apache2
sudo rm -rf /var/www/html/*
sudo rm -rf /var/www/html/.*
sudo git clone https://github.com/lucascasotti/accel-ppp-webif.git /var/www/html
sudo chown -R www-data:www-data /var/www/html/
sudo su www-data -s /bin/bash -c "COMPOSER=/var/www/html/composer.json composer --working-dir=/var/www/html/ install"
sudo su www-data -s /bin/bash -c "/usr/bin/php /var/www/html/data.php --password $1"
sudo touch /var/www/html/eth_interface.cache
sudo chmod 777 /var/www/html/eth_interface.cache
sudo echo "ETHERNET=\"$(sudo ifconfig | cut -d " " -f1 | cut -d ":" -f1 | awk 'NR==1{print $1}')\"" >> /var/www/html/eth_interface.cache
sudo chown -R www-data:www-data /var/www/html/eth_interface.cache
sudo su www-data -s /bin/bash -c "cat /var/www/html/eth_interface.cache >> /var/www/html/.env"
sudo rm /var/www/html/eth_interface.cache
