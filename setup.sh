#!/bin/bash

echo "Updating"
apt-get -qq -y update

export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mysql-server-10.0 mysql-server/root_password password #MYSQL_ROOT_PASSWORD'
debconf-set-selections <<< 'mysql-server-10.0 mysql-server/root_password_again password #MYSQL_ROOT_PASSWORD'
echo "Installing MySQL & Apache"
apt-get install -y -q mysql-server apache2

a2enmod ssl proxy proxy_http proxy_wstunnel rewrite

sed -i 's/MATTERMOST_PASSWORD/#MATTERMOST_PASSWORD/' /vagrant/db_setup.sql
echo "Setting up database"
mysql -uroot -p#MYSQL_ROOT_PASSWORD < /vagrant/db_setup.sql

rm -rf /opt/mattermost

wget -q https://releases.mattermost.com/5.5.0/mattermost-5.5.0-linux-amd64.tar.gz

tar -xzf mattermost*.gz

rm mattermost*.gz
mv mattermost /opt

mkdir /opt/mattermost/data
rm /opt/mattermost/config/config.json

cp /vagrant/license.txt /opt/mattermost/license.txt

ln -s /vagrant/config.json /opt/mattermost/config/config.json

useradd --system --user-group mattermost
chown -R mattermost:mattermost /opt/mattermost
chmod -R g+w /opt/mattermost

cp /vagrant/mattermost.service /lib/systemd/system/mattermost.service
systemctl daemon-reload

cd /opt/mattermost
bin/mattermost user create --email admin@bandicootsrus.com --username admin --password admin
bin/mattermost team create --name bandicoots --display_name "Bandicoots R Us" --email "admin@bandicootsrus.com"
bin/mattermost team add bandicoots admin@bandicootsrus.com
bin/mattermost sampledata --seed 10 --teams 4 --users 30

mkdir -p /etc/apache2/certs
ln -s /vagrant/certs/mattermost.internal.bandicootsrus.com/mattermost.internal.bandicootsrus.com.crt /etc/apache2/certs/mattermost.internal.bandicootsrus.com.crt
ln -s /vagrant/certs/mattermost.internal.bandicootsrus.com/mattermost.internal.bandicootsrus.com.key /etc/apache2/certs/mattermost.internal.bandicootsrus.com.key
ln -s /vagrant/internal_apache.conf /etc/apache2/sites-available/mattermost.internal.bandicootsrus.com.conf

sed -i '/Include ports.conf/d' /etc/apache2/apache2.conf
a2ensite mattermost.internal.bandicootsrus.com.conf

cp /vagrant/certs/root_CA.pem /usr/local/share/ca-certificates/root_CA.crt
update-ca-certificates

service mysql start
service mattermost start
service apache2 restart

printf '=%.0s' {1..80}
echo 
echo '                     VAGRANT UP!'
echo "GO TO https://www.bandicootsrus.com/mattermost and log in with \`admin\`"
echo
printf '=%.0s' {1..80}
