#!/bin/sh

cd `dirname $0`

if [ -f "./connection_env/$1.sh" ]; then
  source "./connection_env/$1.sh"
else
  echo '####### please input info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

sqlplus "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" @normal_preparation.sql
