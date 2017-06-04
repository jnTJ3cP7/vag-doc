#!/bin/sh

cd `dirname $0`

DATE=`date +%Y%m%d%H%M%S`
CONNECTION_DIR='../normal_env'

while getopts s: OPT
do
  case $OPT in
    s)  SQL_FILE_PATH=$OPTARG
        ;;
    \?) echo 'unexpected option'
        exit 1
        ;;
  esac
done
shift $((OPTIND - 1))

if [ -f "${CONNECTION_DIR}/$1.sh" ]; then
  source "${CONNECTION_DIR}/$1.sh"
else
  echo '####### please input DB info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

# variable settings
SPOOL_NAME="result_${DATE}.csv"
echo "define target_sql=$SQL_FILE_PATH" >> tmp_obj.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @tmp_obj.sql
  WHENEVER SQLERROR EXIT 1 ROLLBACK;
  WHENEVER OSERROR EXIT 1 ROLLBACK;
  VARIABLE code NUMBER;
  BEGIN
  :code:=0;
  @&target_sql
  COMMIT;
  END;
  /
  EXIT:code
EOF

if [ $? -ne 0 ]; then
  echo "fail"
fi

rm -rf tmp_obj.sql
