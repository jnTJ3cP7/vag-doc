#!/bin/sh

DATE=`date +%Y%m%d%H%M%S`
CONNECTION_DIR='./connection_env'

if [ -f "${CONNECTION_DIR}/$1.sh" ]; then
  source "${CONNECTION_DIR}/$1.sh"
else
  echo '####### please input info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

echo '####### please input create USER info #########'
read -p 'USER : ' NEW_USER
echo "define new_user=$NEW_USER" > tmp_obj.sql
read -p 'PASSWORD : ' NEW_PASSWORD
echo "define new_password=$NEW_PASSWORD" >> tmp_obj.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @tmp_obj.sql
  CREATE USER &new_user IDENTIFIED BY &new_password;
  GRANT DBA TO &new_user;
  select * from dba_users where UPPER(USERNAME) = UPPER('&new_user');
EOF

rm -rf tmp_obj.sql