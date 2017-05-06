#!/bin/sh

createSources() {
  echo "define new_user=$1" > tmp_obj.sql
  echo "define obj_name=$1_NAME" >> tmp_obj.sql
  if [ ${1: -1} = 'X' ]; then
    echo "define obj_users=USER_$1ES" >> tmp_obj.sql
  else
    echo "define obj_users=USER_$1S" >> tmp_obj.sql
  fi
  echo "define obj_spool_file=$1.spool" >> tmp_obj.sql
}

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