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
  if [ $line != 'LOB' ]; then
    createSources "$line"
    sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
      @preparation.sql
      set long 100000000
      set longchunksize 100000000
      @tmp_obj.sql
      spool &obj_spool_file
      SELECT DBMS_METADATA.GET_DDL('&obj',&obj_name) FROM &obj_users;
EOF
  fi
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

egrep -n 'CONSTRAINT.*PRIMARY KEY \(".*\)' $OUTPUT > pk.txt
egrep -n 'CREATE TABLE' $OUTPUT > ct.txt
egrep -vn '^.+' $OUTPUT | awk -F : '{ print $1 }' > no.txt

cat pk.txt | while read -r line
do
  TARGET_LINE=`echo "$line" | awk -F : '{ print $1 }'`
  TARGET_TABLE=`awk -v base="$TARGET_LINE" -F : '$1 < base { print $2 }' ct.txt | tail -1 | sed -e 's/^.*\.\(".*"\)$/\1/'`
  TARGET_KEY=`echo "$line" | awk -F : '{ print $2 }' | sed -e 's/^.*(\("[^)]*"\))$/\1/'`
  DELETE_BASE_LINE=`grep -n "CREATE UNIQUE INDEX.*\.$TARGET_TABLE ($TARGET_KEY)" $OUTPUT | awk -F : '{ print $1 }'`
  DELETE_TMP_LINE=`awk -v base="$DELETE_BASE_LINE" '$1 > base' no.txt | head -1`
  DELETE_UNTIL_LINE=`expr $DELETE_TMP_LINE - 1`
  if [ $? -gt 1 ]; then
    echo "${DELETE_BASE_LINE}d;" >> delete.txt
  else
    echo "${DELETE_BASE_LINE},${DELETE_UNTIL_LINE}d;" >> delete.txt
  fi
done

grep -n "CREATE UNIQUE INDEX.*\.\"SYS_.*\$\$\"" $OUTPUT | awk -F : '{ print $1 }' > lob.txt
cat lob.txt | while read -r line
do
  DELETE_TMP_LINE=`awk -v base="$line" '$1 > base' no.txt | head -1`
  DELETE_UNTIL_LINE=`expr $DELETE_TMP_LINE - 1`
  if [ $? -gt 1 ]; then
    echo "${line}d;" >> delete.txt
  else
    echo "${line},${DELETE_UNTIL_LINE}d;" >> delete.txt
  fi
done

DELETE_LINE=''
cat delete.txt | while read -r line
do
  DELETE_LINE="${DELETE_LINE}${line}"
  echo "$DELETE_LINE" > delCmd.txt
done
DEL_CMD=`cat delCmd.txt`

sed -i -e "${DEL_CMD%;}" $OUTPUT


rm -rf *.spool objects.txt tmp_obj.sql pk.txt ct.txt no.txt delete.txt delCmd.txt lob.txt