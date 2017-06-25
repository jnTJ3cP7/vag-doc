#!/bin/sh
# 同サーバDBでのメタデータのコピー

cd `dirname $0`

DATE=`date +%Y%m%d%H%M%S`
CONNECTION_DIR='../connection_env'

while getopts f:t: OPT
do
  case $OPT in
    t)  TO_USER=$OPTARG
        ;;
    f)  FROM_USER=$OPTARG
        ;;
    \?) echo 'unexpected option'
        exit 1
        ;;
  esac
done
shift $((OPTIND - 1))
if [ -z $TO_USER ] || [ ! -f "${CONNECTION_DIR}/$TO_USER.sh" ]; then
  echo "please set a '-t' parameter"
  exit 1
fi
if [ -z $FROM_USER ] || [ ! -f "${CONNECTION_DIR}/$FROM_USER.sh" ]; then
  echo "please set a '-f' parameter"
  exit 1
fi

source "${CONNECTION_DIR}/$FROM_USER.sh"

NEW_LINK_NAME="DATA_PUMP_$DATE"
echo "define new_link_name=$NEW_LINK_NAME" > tmp_obj.sql
FROM_USER="$USER"
echo "define from_user=$FROM_USER" >> tmp_obj.sql
echo "define from_password=$PASSWORD" >> tmp_obj.sql
echo "define from_host=$HOST" >> tmp_obj.sql
echo "define from_port=$PORT" >> tmp_obj.sql
echo "define from_service_name=$SERVICE_NAME" >> tmp_obj.sql

rm -rf /home/oracle/dump
mkdir /home/oracle/dump
source "${CONNECTION_DIR}/$TO_USER.sh"
sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
CREATE PUBLIC DATABASE LINK &new_link_name CONNECT TO &from_user IDENTIFIED BY &from_password USING '&from_host:$from_port/&from_service_name';
create or replace directory DUMP as '/home/oracle/dump';
EOF

expdp "$USER/$PASSWORD@$SERVICE_NAME" network_link="$NEW_LINK_NAME" directory=DUMP content=metadata_only;

impdp "$USER/$PASSWORD@$SERVICE_NAME" \
REMAP_SCHEMA=${FROM_USER}:${USER} \
REMAP_TABLESPACE=USER:USER \
directory=DUMP \
table_exists_action = replace \
exclude=user

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
DROP PUBLIC DATABASE LINK &new_link_name;
EOF

rm -rf tmp_obj.sql