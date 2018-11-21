#!/bin/bash

apt-get -y update

apt-get -y -q install apache2

# Install CA because reasons
cp /vagrant/certs/root_CA.pem /usr/local/share/ca-certificates/root_CA.crt
update-ca-certificates

# enable mods
a2enmod ssl proxy proxy_http proxy_wstunnel rewrite headers deflate proxy_html

cp -R /vagrant/home/{logs,www.bandicootsrus.com} /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/{logs,www.bandicootsrus.com}
echo '' > /home/vagrant/logs/www.bandicootsrus.com/error.log
echo '' > /home/vagrant/logs/www.bandicootsrus.com/access.log
chmod 777 /home/vagrant/logs/www.bandicootsrus.com/*.log
chmod -R 777 /home/vagrant/www.bandicootsrus.com

mkdir -p /etc/apache2/certs
ln -s /vagrant/certs/www.bandicootsrus.com/www.bandicootsrus.com.crt /etc/apache2/certs/www.bandicootsrus.com.crt
ln -s /vagrant/certs/www.bandicootsrus.com/www.bandicootsrus.com.key /etc/apache2/certs/www.bandicootsrus.com.key
ln -s /vagrant/external_apache.conf /etc/apache2/sites-available/www.bandicootsrus.com.conf
a2ensite www.bandicootsrus.com.conf

echo '' >> /etc/hosts

echo '192.168.33.102 mattermost.internal.bandicootsrus.com' >> /etc/hosts	

service apache2 restart