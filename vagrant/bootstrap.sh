#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apache2 gnupg2 python3-pip npm php php-redis php-curl php-mbstring php-xml composer redis-server
npm -g install pm2
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
percona-release setup ps80
rm -rf /var/lib/mysql
apt-get install percona-server-server -y

rm percona-release_latest.$(lsb_release -sc)_all.deb

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

echo "CREATE SCHEMA IF NOT EXISTS gestionx;" > create_db.sql
echo "USE gestionx;" >> create_db.sql
cat create_db.sql /var/www/sql/models/Tablas.sql /var/www/sql/models/CargaValores.sql /var/www/sql/procedures/*.sql > init.sql
mysql < init.sql

rm create_db.sql init.sql

rm -rf /etc/apache2/sites-enabled/*
rm -rf /etc/apache2/sites-available/*

cp /var/www/vagrant/apache/*.conf /etc/apache2/sites-available/

a2ensite 000-landing backend
a2enmod rewrite
systemctl restart apache2

pushd /var/www/web
echo "0" > deploy
echo "yes" >> deploy
php init < deploy
rm deploy
rm -rf vendor
su vagrant -c 'composer install'
popd
