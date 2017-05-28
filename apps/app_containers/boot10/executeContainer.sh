#!/bin/sh

EXECUTE_DIR='/execute'
SYNC_DIR='/app'
RESOURCE='src/main/resources/config/application.yml'


rm -rf $EXECUTE_DIR
mkdir -p $EXECUTE_DIR/${RESOURCE%/*}

find $SYNC_DIR -mindepth 1 -maxdepth 1 | egrep -v "/${RESOURCE%%/*}$" | xargs -i ln -sfn {} $EXECUTE_DIR
find $SYNC_DIR/${RESOURCE%%/*} -mindepth 1 -maxdepth 1 | egrep -v "/${RESOURCE%/*/*/*}$" | xargs -i ln -sfn {} $EXECUTE_DIR/${RESOURCE%%/*}
find $SYNC_DIR/${RESOURCE%/*/*/*} -mindepth 1 -maxdepth 1 | egrep -v "/${RESOURCE%/*/*}$" | xargs -i ln -sfn {} $EXECUTE_DIR/${RESOURCE%/*/*/*}
{RESOURCE%%/*}
find $SYNC_DIR/${RESOURCE%/*/*} -mindepth 1 -maxdepth 1 | egrep -v "/${RESOURCE%/*}$" | xargs -i ln -sfn {} $EXECUTE_DIR/${RESOURCE%/*/*}
find $SYNC_DIR/${RESOURCE%/*} -mindepth 1 -maxdepth 1 | egrep -v "/${RESOURCE}$" | xargs -i ln -sfn {} $EXECUTE_DIR/${RESOURCE%/*}

/run-scripts/resourcesSetter.sh

# -Drun.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000"


tail -f /dev/null