#!/bin/sh

createSources() {
  KEY_1_EXIST=false
  COLUMNS=(`awk -v arg=$1 -F , '$1 == arg { print $2 }' objects.txt`)
  for col in "${COLUMNS[@]}"
  do
    if [ $col = ${RELATION_KEY_1} ]; then
      KEY_1_EXIST=true
      break
    fi
  done
  echo 'SELECT * ' >> exec.sql
  echo "FROM $1 " >> exec.sql
  if $KEY_1_EXIST; then
    echo "WHERE ${RELATION_KEY_1} = '${RELATION_VALUE_1}';" >> exec.sql
  else
    RELATION_VALUE_2=`echo "${VALUE2[@]}" | sed -e "s/ /','/g"`
    echo "WHERE ${RELATION_KEY_2} in ('${RELATION_VALUE_2}');" >> exec.sql
  fi
}

cd `dirname $0`

while getopts k: OPT
do
  case $OPT in
    k)  RELATION_VALUE_1=$OPTARG
        ;;
    \?) echo 'unexpected option'
        exit 1
        ;;
  esac
done
shift $((OPTIND - 1))

if [ -z $RELATION_VALUE_1 ]; then
  echo "please set a '-k' parameter"
  exit 1
fi

CONNECTION_DIR='../connection_env'
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

# variable settings
DATE=`date +%Y%m%d%H%M%S`
OUTPUT="result_${DATE}.sql"
RELATION_TABLE='SPRING_TABLE_02'
RELATION_KEY_1='ID'
RELATION_KEY_2='NAME2'
echo "define target1=\"$RELATION_KEY_1\"" > target.sql
echo "define target2=\"$RELATION_KEY_2\"" >> target.sql
echo "define value1=\"$RELATION_VALUE_1\"" >> target.sql
echo "define table1=\"$RELATION_TABLE\"" >> target.sql


sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" > /dev/null <<EOF
  @preparation.sql
  @target.sql
  spool objects.txt
  select DISTINCT columns.TABLE_NAME || ',' || columns.COLUMN_NAME 
  from USER_TAB_COLUMNS columns, 
  (select DISTINCT TABLE_NAME from USER_TAB_COLUMNS 
  where COLUMN_NAME in (UPPER('&target1'), UPPER('&target2'))) tables 
  where columns.TABLE_NAME = tables.TABLE_NAME;
  spool value2.txt
  select distinct &target2 from &table1 where &target1 = '&value1';
EOF

if [ ! -f objects.txt ]; then
  echo 'failed'
  exit 1
fi

VALUE2=(`grep '' value2.txt`)

grep '' excluded_tables.txt | xargs -i sed -i "/^{},.*$/Id" objects.txt
grep '' excluded_columns.txt | xargs -i sed -n "s/^\(.*\),{}$/\1/Igp" objects.txt | xargs -i sed -i "/^{},.*$/Id" objects.txt
TABLES=(`awk -F , '{ print $1 }' objects.txt | sort | uniq`)

echo "set sqlformat insert" > exec.sql
echo "spool ${OUTPUT} app" >> exec.sql
for table in "${TABLES[@]}"
do
  createSources "$table"
done

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" > /dev/null <<EOF
  @preparation.sql
  @exec.sql
EOF


rm -rf target.sql value2.txt exec.sql objects.txt
mv -f "${OUTPUT}" /output/