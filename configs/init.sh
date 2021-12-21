#!/bin/bash

echo "Habilitando sitios de apache" &&\
a2ensite 000-landing backend &&\

echo "Ingresando a /var/www/web" &&\
pushd /var/www/web &&

echo "Inicializando Composer" &&\
rm -rf vendor &&\
composer install &&\

echo "Inicializando Yii" &&\
rm -rf  backend/config/codeception-local.php \
        backend/config/main-local.php \
        backend/config/params-local.php \
        backend/config/test-local.php \
        backend/web/index-test.php \
        backend/web/index.php \
        backend/web/robots.txt \
        common/config/codeception-local.php \
        common/config/main-local.php \
        common/config/params-local.php \
        common/config/test-local.php \
        console/config/main-local.php \
        console/config/params-local.php \
        console/config/test-local.php \
        frontend/config/codeception-local.php \
        frontend/config/main-local.php \
        frontend/config/params-local.php \
        frontend/config/test-local.php \
        frontend/web/index-test.php \
        frontend/web/index.php \
        frontend/web/robots.txt \
        yii \
        yii_test \
        yii_test.bat &&\
echo '0' > cmds && echo 'yes' >> cmds && ./init < cmds && rm cmds &&\

echo "Saliendo de /var/www/web" &&\
popd &&\

echo "Iniciando el servicio de apache" &&\
service apache2 start &&\

echo "Iniciando el servicio de mysql" &&\
service mysql start &&\

echo "Iniciando el servicio de redis" &&\
service redis-server start &&\

export DB_USER_EXISTS=$(mysql -e 'SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = "yiiuser") as "";')

if [[ $DB_USER_EXISTS -eq 0 ]]
then
    echo "Creando usuario de mysql" &&\
    mysql -e 'CREATE USER IF NOT EXISTS "yiiuser"@"%" identified by "GestionX2019";' &&\

    mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "yiiuser"@"%";' &&\

    mysql -e 'FLUSH PRIVILEGES;'
fi

export SCHEMA_EXISTS=$(mysql -e 'SELECT EXISTS (select schema_name from information_schema.schemata where schema_name = "gestionx") as "";')

if [[ $SCHEMA_EXISTS -eq 0 ]]
then
    echo "Creando schema de mysql"
    echo "CREATE SCHEMA IF NOT EXISTS gestionx; USE gestionx;" > create_schema.sql
    cat create_schema.sql /root/sql/models/Tablas.sql /root/sql/triggers/*.sql /root/sql/procedures/*.sql /root/sql/Init.sql > create_db.sql
    mysql < create_db.sql
    rm create_db.sql create_schema.sql
fi

echo "Setup inicial finalizado" &&\

echo "Serving http://backend.127.0.0.1.nip.io:8050" &&\
echo "Serving http://frontend.127.0.0.1.nip.io:8050" &&\

sleep infinity
