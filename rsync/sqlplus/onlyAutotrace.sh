#!/bin/sh

cd `dirname $0`
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

sqlplus "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" @autotrace_preparation.sql
