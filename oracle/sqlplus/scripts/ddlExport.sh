#!/bin/sh

createSources() {
  echo "define obj=$1" > tmp_obj.sql
  echo "define obj_name=$1_NAME" >> tmp_obj.sql
  if [ ${1: -1} = 'X' ]; then
    echo "define obj_users=USER_$1ES" >> tmp_obj.sql
  else
    echo "define obj_users=USER_$1S" >> tmp_obj.sql
  fi
  echo "define obj_spool_file=$1.spool" >> tmp_obj.sql
}

if [ -f "./normal_env/$1.sh" ]; then
  source "./normal_env/$1.sh"
else
  echo '####### please input info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
spool objects.txt
SELECT DISTINCT OBJECT_TYPE FROM USER_OBJECTS;
EOF

if [ ! -f objects.txt ]; then
  echo 'failed'
  exit 1
fi

cat objects.txt | while read -r line
do
  createSources "$line"
sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
spool &obj_spool_file
SELECT DBMS_METADATA.GET_DDL('&obj',&obj_name) FROM &obj_users;
EOF
done

DATE=`date +%Y%m%d%H%M%S`
OUTPUT="all_ddl_${USER}_${DATE}.sql"
touch $OUTPUT
if [ -f TABLE.spool ]; then
  cat TABLE.spool >> $OUTPUT
  rm -f TABLE.spool
fi
if [ -f VIEW.spool ]; then
  cat VIEW.spool >> $OUTPUT
  rm -f VIEW.spool
fi
for spool in *.spool
do
  cat "$spool" >> $OUTPUT
done

rm -rf *.spool objects.txt tmp_obj.sql
