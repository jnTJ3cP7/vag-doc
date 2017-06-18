#!/bin/sh

cd `dirname $0`
source ./config.sh

echo "${TOMCAT_DIR}"
echo "${TEST_ECHO}"


"${TOMCAT_DIR}/bin/startup.sh"

echo "$1" > /first.txt
echo "$2" > /first2.txt

tail -f /dev/null