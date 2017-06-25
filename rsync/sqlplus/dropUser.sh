#!/bin/sh

createSources() {
  echo "define drop_user=$1" > tmp_obj.sql
  echo "define obj_name=$1_NAME" >> tmp_obj.sql
  if [ ${1: -1} = 'X' ]; then
    echo "define obj_users=USER_$1ES" >> tmp_obj.sql
  else
    echo "define obj_users=USER_$1S" >> tmp_obj.sql
  fi
  echo "define obj_spool_file=$1.spool" >> tmp_obj.sql
}

DATE=`date +%Y%m%d%H%M%S`
CONNECTION_DIR='../connection_env'

if [ -f "${CONNECTION_DIR}/$1.sh" ]; then
  source "${CONNECTION_DIR}/$1.sh"
else
  echo '####### please input DB info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

echo '####### please input drop USER info #########'
read -p 'USER : ' DROP_USER
echo "define drop_user=$DROP_USER" > tmp_obj.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
DROP USER &drop_user CASCADE;
EOF

rm -rf tmp_obj.sql