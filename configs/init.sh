#!/bin/sh

a2ensite 000-landing backend

service apache2 start

service mysql start

service redis-server start

mysql -e 'CREATE USER IF NOT EXISTS "yiiuser"@"%" identified by "GestionX2019";'

mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "yiiuser"@"%";'

mysql -e 'FLUSH PRIVILEGES;'

# echo "CREATE SCHEMA IF NOT EXISTS gestionx;" > create_db.sql
# echo "USE gestionx;" >> create_db.sql
# cat create_db.sql /var/www/sql/models/Tablas.sql /var/www/sql/models/CargaValores.sql /var/www/sql/procedures/*.sql > init.sql
# mysql < init.sql

sleep infinity
