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
create or replace directory DUMP as '/home/oracle/dump';
select DIRECTORY_NAME from dba_directories where DIRECTORY_PATH = '/home/oracle/dump';
EOF


expdp "$USER/$PASSWORD@$SERVICE_NAME" network_link="$DB_LINK" directory=DUMP content=metadata_only;



impdp "$USER/$PASSWORD@$SERVICE_NAME" \
REMAP_SCHEMA=DOCKER3:$USER \
REMAP_TABLESPACE=USER:USER \
directory=DUMP \
table_exists_action = replace \
exclude=user

# impdp docker3/test@ORCLPDB1 \
# REMAP_SCHEMA=DOCKER3:DOCKER3 \
# REMAP_TABLESPACE=USER:USER \
# directory=DUMP

# SELECT USERNAME FROM ALL_DB_LINKS where DB_LINK = $DB_LINK;
# rm -rf tmp_obj.sql