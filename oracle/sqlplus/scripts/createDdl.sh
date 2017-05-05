#!/bin/sh

while getopts f:t: OPT
do
  case $OPT in
    f)  FROM=$OPTARG
        ;;
    t)  TO=$OPTARG
        ;;
    \?) echo 'unexpected option'
        exit 1
        ;;
  esac
done

DDL_BACKUP_DIR='./ddl_sqls/ddl_backup'

echo 'original DDL info'
echo "$FROM"
source ./ddlExport.sh ${FROM}

if [ ! -f $OUTPUT ]; then
  echo 'failed'
  exit 1
fi
if [ ! -f "./normal_env/$TO.sh" ]; then
  read -p 'GOAL USER : ' TO_USER
else
  TO_USER=`awk -F = '$1 == "USER" { print $NF }' "./normal_env/$TO.sh"`
fi

TO_OUTPUT=`ls $OUTPUT | sed -e "s/_${USER}_/_${TO_USER}_/"`
USER=`echo "$USER" | tr '[a-z]' '[A-Z]'`
TO_USER=`echo "$TO_USER" | tr '[a-z]' '[A-Z]'`

sed -e "s/$USER/$TO_USER/g" $OUTPUT > $TO_OUTPUT

LATEST_BACKUP=`ls -lr "$DDL_BACKUP_DIR" | fgrep -i "_${TO_USER}_" | head -1 | awk '{ print $NF }'`
if [ `echo "$LATEST_BACKUP" | wc -c | awk '{ print $NF }'` -gt 1 ]; then
  DIFF_FILE="${TO_USER}_${DATE}.diff"
  diff -u "$DDL_BACKUP_DIR/$LATEST_BACKUP" "$TO_OUTPUT" > $DIFF_FILE
  if [ `cat "$DIFF_FILE" | wc -c | awk '{ print $NF }'` -gt 1 ]; then
    echo "DIFF exist, FILE outputed ($DIFF_FILE)"
  else
    echo "DIFF is nothing !"
    rm -rf $DIFF_FILE
  fi
else
  echo 'first backup'
fi

cp $OUTPUT $TO_OUTPUT "$DDL_BACKUP_DIR"
