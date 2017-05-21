#!/bin/sh


DATE=`date +%Y%m%d%H%M%S`

if [ -f "./normal_env/$1.sh" ]; then
  source "./normal_env/$1.sh"
else
  echo '####### please input DB info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

echo '####### please input create LINK info #########'
read -p 'LINK_NAME : ' NEW_LINK_NAME
echo "define new_link_name=$NEW_LINK_NAME" > tmp_obj.sql
read -p 'USER : ' NEW_USER
echo "define new_user=$NEW_USER" >> tmp_obj.sql
read -p 'PASSWORD : ' NEW_PASSWORD
echo "define new_password=$NEW_PASSWORD" >> tmp_obj.sql
read -p 'HOST : ' NEW_HOST
echo "define new_host=$NEW_HOST" >> tmp_obj.sql
read -p 'PORT : ' NEW_PORT
echo "define new_port=$NEW_PORT" >> tmp_obj.sql
read -p 'SERVICE_NAME : ' NEW_SERVICE_NAME
echo "define new_service_name=$NEW_SERVICE_NAME" >> tmp_obj.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
CREATE PUBLIC DATABASE LINK &new_link_name CONNECT TO &new_user IDENTIFIED BY &new_password USING '&new_host:$new_port/&new_service_name';
SELECT DB_LINK FROM ALL_DB_LINKS;
EOF

rm -rf tmp_obj.sql