#!/bin/sh

cd `dirname $0`

if [ $# -ne 2 ]; then
  echo '引数が足りません'
  exit 1
fi

if [ -f "./normal_env/$1.sh" ]; then
  source "./normal_env/$1.sh"
else
  echo '####### please input DB info #########'
  read -p 'USER : ' USER
  read -p 'PASSWORD : ' PASSWORD
  read -p 'HOST : ' HOST
  read -p 'PORT : ' PORT
  read -p 'SERVICE_NAME : ' SERVICE_NAME
fi

FILE_HEAD=`basename $2 | sed -e "s/^\(.*\)\.sql$/\1/"`
DATE=`date +%Y%m%d%H%M%S`
SPOOL_NAME="${FILE_HEAD}_${DATE}.csv"
echo "define spool_name=$SPOOL_NAME" > tmp_obj.sql
echo "define target_sql=$2" >> tmp_obj.sql
sqlplus -s "$USER/$PASSWORD@$HOST:$PORT/$SERVICE_NAME" <<EOF
  @preparation.sql
  @tmp_obj.sql
  spool &spool_name
  @&target_sql
EOF

HEADER=`head -1 \`dirname $2\`"/${FILE_HEAD}_base.csv"`
sed -i -e "1 i $HEADER" "$SPOOL_NAME"

rm -rf tmp_obj.sql
