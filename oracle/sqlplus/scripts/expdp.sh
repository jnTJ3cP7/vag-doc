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

read -p 'DB LINK: ' DB_LINK

rm -rf /home/oracle/dump
mkdir /home/oracle/dump

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
create or replace directory DUMP as '/home/oracle/dump';
select * from dba_directories where DIRECTORY_PATH = '/home/oracle/dump';
EOF


expdp "$USER/$PASSWORD@$SERVICE_NAME" network_link="$DB_LINK" directory=DUMP;

# impdp "$USER/$PASSWORD@$SERVICE_NAME" \
# REMAP_SCHEMA=DOCKER3:MY_USER \
# REMAP_TABLESPACE=USER:USER \
# directory=DUMP

# impdp docker3/test@ORCLPDB1 \
# REMAP_SCHEMA=DOCKER3:DOCKER3 \
# REMAP_TABLESPACE=USER:USER \
# directory=DUMP


rm -rf tmp_obj.sql