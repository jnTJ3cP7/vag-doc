#!/bin/sh

EXECUTE_DIR='/execute'
SYNC_DIR='/app'
RESOURCE='src/main/resources/config/application.yml'


rm -f $EXECUTE_DIR/$RESOURCE
cp -f $SYNC_DIR/$RESOURCE $EXECUTE_DIR/$RESOURCE


sed -i "s/^\(.*\)url: jdbc:oracle:thin:\@.*$/\1url: jdbc:oracle:thin:@oracle:1521\/ORCLPDB1/g" $EXECUTE_DIR/$RESOURCE