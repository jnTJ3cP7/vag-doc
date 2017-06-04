#!/bin/sh

createSources() {
  KEY_1_EXIST=false
  SELECT_COLUMNS=''
  COLUMNS=(`awk -v arg=$1 -F , '$1 == arg { print $2 }' objects.txt`)
  for col in "${COLUMNS[@]}"
  do
    if [ $col = ${RELATION_KEY_1} ]; then
      KEY_1_EXIST=true
    fi
    SELECT_COLUMNS="${SELECT_COLUMNS}${col}${SELECT_CSV}"
  done
  SELECT_COLUMNS=`echo "$SELECT_COLUMNS" | sed -e "s/^\(.*\)${SELECT_CSV}$/\1/"`
  echo "$1=${SELECT_COLUMNS}" >> queries.txt
  echo "spool $1.${DATE}_spool" >> exec.sql
  echo "SELECT $SELECT_COLUMNS " >> exec.sql
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

CONNECTION_DIR='../normal_env'
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
SELECT_CSV=" || ',' || "
RELATION_TABLE='SPRING_TABLE_02'
RELATION_KEY_1='ID'
RELATION_KEY_2='NAME2'
echo "define target1=\"$RELATION_KEY_1\"" > target.sql
echo "define target2=\"$RELATION_KEY_2\"" >> target.sql
echo "define value1=\"$RELATION_VALUE_1\"" >> target.sql
echo "define table1=\"$RELATION_TABLE\"" >> target.sql
OUTPUT="insert_${USER}_${RELATION_KEY_1}_${RELATION_VALUE_1}_${DATE}.sql"


sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
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

VALUE2=(`cat value2.txt`)

grep '' excluded_tables.txt | xargs -i sed -i "/^{},.*$/Id" objects.txt
TABLES=(`awk -F , '{ print $1 }' objects.txt | sort | uniq`)

echo -n > exec.sql
echo -n > queries.txt
for table in "${TABLES[@]}"
do
  createSources "$table"
done

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  set long 100000000
  set longchunksize 100000000
  @exec.sql
EOF

find . -maxdepth 1 -name "*.${DATE}_spool" -type f | sed "s/^.\/\(.*\)\.${DATE}_spool/\1/g" | while read -r line
  do
    QUERY=`awk -v arg=$line -F = '$1 == arg {print $2}' queries.txt`
    INSERT_COLUMNS=`echo "($QUERY)" | sed -e "s/$SELECT_CSV/,/g"`
    grep '' "${line}.${DATE}_spool" | while read -r data
    do
      echo "insert into $line $INSERT_COLUMNS values ('`echo $data | sed -e "s/,/','/g"`');" >> $OUTPUT
    done
  done


rm -rf objects.txt target.sql value2.txt *.${DATE}_spool queries.txt exec.sql
