#!/bin/sh

cd `dirname $0`

DATE=`date +%Y%m%d%H%M%S`
CONNECTION_DIR='../connection_env'
OUTPUT="single_ddl_${DATE}.sql"

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

echo '####### please input table for ddl export #########'
read -p 'TABLE : ' TABLE

echo "spool ${OUTPUT}" > exec.sql
echo "ddl ${TABLE}" >> exec.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" > /dev/null <<EOF
  @single_ddl_preparation.sql
  @exec.sql
EOF

rm -f exec.sql
mv "${OUTPUT}" /output