#!/bin/sh

cd `dirname $0`

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
  spool ignore.txt
  select INDEX_NAME from user_constraints where INDEX_NAME is not null;
EOF

DATE=`date +%Y%m%d%H%M%S`

OUTPUT="drop_${USER}_objects_${DATE}.sql"
echo "define output=$OUTPUT" > output.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @output.sql
  spool &output
  select 'drop '||object_type||' '|| object_name||  DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS PURGE;',';') 
  from user_objects;
EOF

awk '$2 == "TABLE"' $OUTPUT > tables.txt
sed -i -e "/^drop TABLE.*CASCADE CONSTRAINTS PURGE;$/d" $OUTPUT
cat tables.txt >> $OUTPUT

cat ignore.txt | while read -r line
do
  sed -i -e "/^drop INDEX $line;$/d" $OUTPUT
done

sed -i -e "/^drop INDEX.*\$\$;$/d" $OUTPUT
sed -i -e "/^drop LOB.*\$\$;$/d" $OUTPUT


rm -rf output.sql tables.txt ignore.txt
