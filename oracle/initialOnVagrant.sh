#!/bin/sh

runOracleDB() {
  docker-compose up oracle | while read line
    do
      echo "$line" | grep 'DATABASE IS READY TO USE!' && break
      echo "$line"
    done
}

cd oracle

docker images | grep -q 'oracle/database'
if [ $? -eq 0 ]; then
  runOracleDB
else
  cd OracleDatabase/dockerfiles
  ORACLE_DB_VERSION='12.2.0.1'
  # memory等を聞く
  ./buildDockerImage.sh -v "${ORACLE_DB_VERSION}" -e -i
  cd ../..
  runOracleDB
fi

