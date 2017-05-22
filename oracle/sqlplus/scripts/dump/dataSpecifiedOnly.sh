#!/bin/sh

cd `dirname $0`

DATE=`date +%Y%m%d%H%M%S`
BASE_SETTINGS_DIR='..'

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
if [ -z $TO_USER ] || [ ! -f "$BASE_SETTINGS_DIR/normal_env/$TO_USER.sh" ]; then
  echo "please set a '-t' parameter"
  exit 1
fi
if [ -z $FROM_USER ] || [ ! -f "../normal_env/$FROM_USER.sh" ]; then
  echo "please set a '-f' parameter"
  exit 1
fi

source "../normal_env/$FROM_USER.sh"

NEW_LINK_NAME="DP$DATE"
echo "define new_link_name=$NEW_LINK_NAME" > tmp_obj.sql
NEW_USER="$USER"
echo "define new_user=$NEW_USER" >> tmp_obj.sql
echo "define new_password=$PASSWORD" >> tmp_obj.sql
echo "define new_host=$HOST" >> tmp_obj.sql
echo "define new_port=$PORT" >> tmp_obj.sql
echo "define new_service_name=$SERVICE_NAME" >> tmp_obj.sql

rm -rf /home/oracle/dump
mkdir /home/oracle/dump
source "../normal_env/$TO_USER.sh"
sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
CREATE PUBLIC DATABASE LINK &new_link_name CONNECT TO &new_user IDENTIFIED BY &new_password USING '&new_host:$new_port/&new_service_name';
create or replace directory DUMP as '/home/oracle/dump';
EOF

TARGET=`egrep '^[^#]+' dataSpecifiedOnly.env | sed -z -e 's/\n/,/g'`
expdp "$USER/$PASSWORD@$SERVICE_NAME" network_link="$NEW_LINK_NAME" directory=DUMP content=data_only tables="${TARGET:0:-1}";

impdp "$USER/$PASSWORD@$SERVICE_NAME" \
REMAP_SCHEMA=${NEW_USER}:${USER} \
REMAP_TABLESPACE=USER:USER \
directory=DUMP

sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
@preparation.sql
@tmp_obj.sql
DROP PUBLIC DATABASE LINK &new_link_name;
EOF

rm -rf tmp_obj.sql