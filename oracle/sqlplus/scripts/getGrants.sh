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

echo '############ ALL PRIVILEGES ###########'

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
select * from session_privs;
EOF

echo '#######################################'
