#!/bin/bash

echo "Habilitando sitios de apache"
a2ensite 000-landing backend

echo "Iniciando el servicio de apache"
service apache2 start

echo "Iniciando el servicio de mysql"
service mysql start

echo "Iniciando el servicio de redis"
service redis-server start

DB_USER_EXISTS=$(mysql -e 'SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = "yiiuser") as "";')

if [[ $DB_USER_EXISTS -eq 0 ]]
then
    echo "Creando usuario de mysql"
    mysql -e 'CREATE USER IF NOT EXISTS "yiiuser"@"%" identified by "GestionX2019";'

    mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "yiiuser"@"%";'

    mysql -e 'FLUSH PRIVILEGES;'
fi

SCHEMA_EXISTS=$(mysql -e 'SELECT EXISTS (select schema_name from information_schema.schemata where schema_name = "gestionx") as "";')

if [[ $SCHEMA_EXISTS -eq 0 ]]
then
    echo "Creando schema de mysql"
    echo "CREATE SCHEMA IF NOT EXISTS gestionx; USE gestionx;" > create_schema.sql
    cat create_schema.sql /root/sql/models/Tablas.sql /root/sql/triggers/*.sql /root/sql/procedures/*.sql /root/sql/Init.sql > create_db.sql
    mysql < create_db.sql
    rm create_db.sql create_schema.sql
fi

echo "Setup inicial finalizado"

echo "Serving http://backend.127.0.0.1.xip.io:5000"
echo "Serving http://frontend.127.0.0.1.xip.io:5000"

sleep infinity
