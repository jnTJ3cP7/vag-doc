#!/bin/sh


DATE=`date +%Y%m%d%H%M%S`
CONNECTION_DIR='../connection_env'

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

SQL_ABSOLUTE_PATH=`cd $(dirname $SQL_FILE_PATH); pwd`/`basename $SQL_FILE_PATH`

cd `dirname $0`

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
echo "define target_sql=$SQL_ABSOLUTE_PATH" >> tmp_obj.sql

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @tmp_obj.sql
  @&target_sql
EOF

rm -rf tmp_obj.sql
