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
  if $KEY_1_EXIST; then
    echo "DELETE FROM $1 WHERE ${RELATION_KEY_1} = '${RELATION_VALUE_1}';" >> $OUTPUT
  else
    RELATION_VALUE_2=`echo "${VALUE2[@]}" | sed -e "s/ /','/g"`
    echo "DELETE FROM $1 WHERE ${RELATION_KEY_2} IN ('${RELATION_VALUE_2}');" >> $OUTPUT
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
  echo "please set a '-r' parameter"
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
RELATION_TABLE='SPRING_TABLE_02'
RELATION_KEY_1='ID'
RELATION_KEY_2='NAME2'
echo "define target1=\"$RELATION_KEY_1\"" > target.sql
echo "define target2=\"$RELATION_KEY_2\"" >> target.sql
echo "define value1=\"$RELATION_VALUE_1\"" >> target.sql
echo "define table1=\"$RELATION_TABLE\"" >> target.sql
OUTPUT="delete_${USER}_${RELATION_KEY_1}_${RELATION_VALUE_1}_${DATE}.sql"


sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @target.sql
  spool objects.txt
  select DISTINCT TABLE_NAME || ',' || COLUMN_NAME 
  from USER_TAB_COLUMNS 
  where COLUMN_NAME in (UPPER('&target1'), UPPER('&target2'));
  spool value2.txt
  select distinct &target2 from &table1 where &target1 = '&value1';
EOF

if [ ! -f objects.txt ]; then
  echo 'failed'
  exit 1
fi

VALUE2=(`cat value2.txt`)

TABLES=(`awk -F , '{ print $1 }' objects.txt | sort | uniq`)

for table in "${TABLES[@]}"
do
  createSources "$table"
done


rm -rf objects.txt target.sql value2.txt
mv -f "${OUTPUT}" /output/