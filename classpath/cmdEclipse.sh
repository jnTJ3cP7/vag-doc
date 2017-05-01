#!/bin/sh

cd `dirname $0`

# Absolute path
ECLIPSE_APP_PATH='/Applications/Eclipse_4.6.3.app/Contents/MacOS/eclipse'
WORKSPACE_PATH='/Users/XXXXXXXXXXXXX/Documents/workspace'
PROJECT_NAME='ExperimentAltt'
ECLIPSE_BUILD_ANT_FILE_PATH="${WORKSPACE_PATH}/refresh.xml"

# classpath edit
sed -i -e "s/path=\"classesf\"/path=\"classes\"/" ../hoge/ExperimentAltt/.classpath
sed -i -e "s/1\.8/1\.7/g" ../hoge/ExperimentAltt/.classpath ../hoge/ExperimentAltt/.settings/org.eclipse.jdt.core.prefs

# execute build
${ECLIPSE_APP_PATH} -nosplash \
-data ${WORKSPACE_PATH} \
-application org.eclipse.ant.core.antRunner \
-buildfile ${ECLIPSE_BUILD_ANT_FILE_PATH} \
-DtargetProject=${PROJECT_NAME}
