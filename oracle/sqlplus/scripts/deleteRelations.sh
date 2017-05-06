#!/bin/sh

createSources() {
  key_1_flag=false
  COLUMNS=(`awk -v arg=$1 -F , '$1 == arg { print $2 }' objects.txt`)
  for col in "${COLUMNS[@]}"
  do
    if [ $col = ${relation_key_1} ]; then
      key_1_flag=true
      break
    fi
  done
  if $key_1_flag; then
    echo "delete from $1 where $relation_key_1 = '$relation_value_1';" >> $OUTPUT
  else
    for val2 in "${VALUE2[@]}"
    do
      echo "delete from $1 where $relation_key_2 = '$val2';" >> $OUTPUT
    done
  fi
}

while getopts r: OPT
do
  case $OPT in
    r)  relation_value_1=$OPTARG
        ;;
    \?) echo 'unexpected option'
        exit 1
        ;;
  esac
done
shift $((OPTIND - 1))

if [ -z $relation_value_1 ]; then
  echo "please set a '-r' parameter"
  exit 1
fi

relation_key_1='ID'
relation_key_2='NAME2'
echo "define target1=\"$relation_key_1\"" > target.sql
echo "define target2=\"$relation_key_2\"" >> target.sql
echo "define value1=\"$relation_value_1\"" >> target.sql

DATE=`date +%Y%m%d%H%M%S`

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

OUTPUT="delete_${USER}_${relation_key_1}_${relation_value_1}_${DATE}.sql"

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @target.sql
  spool objects.txt
  select DISTINCT columns.TABLE_NAME || ',' || columns.COLUMN_NAME 
  from USER_TAB_COLUMNS columns, 
  (select DISTINCT TABLE_NAME from USER_TAB_COLUMNS 
  where COLUMN_NAME in (UPPER('&target1'), UPPER('&target2'))) tables 
  where columns.TABLE_NAME = tables.TABLE_NAME;
EOF

if [ ! -f objects.txt ]; then
  echo 'failed'
  exit 1
fi

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @target.sql
  spool value2.txt
  select distinct name2 from spring_table_02 where id = '&value1';
EOF

VALUE2=(`cat value2.txt`)

TABLES=(`awk -F , '{ print $1 }' objects.txt | sort | uniq`)

for table in "${TABLES[@]}"
do
  createSources "$table"
done


rm -rf objects.txt target.sql value2.txt
