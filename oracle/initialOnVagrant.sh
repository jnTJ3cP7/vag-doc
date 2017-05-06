#!/bin/sh

runOracleDB() {
  docker-compose up oracle > ~/dockerRun.log 2>&1 &
  exec 2> /dev/null
  sh -c 'tail -n +0 -f ~/dockerRun.log | { while read -r line; do echo $line; \
    echo $line | grep -q "DATABASE IS READY TO USE" && break; done && kill $$; }' || :
}

cd /vagrant/oracle

docker images | grep -q 'oracle/database'
if [ $? -eq 0 ]; then
  runOracleDB
else
  cd OracleDatabase/dockerfiles
  ORACLE_DB_VERSION='12.2.0.1'
  DOCKERFILE='Dockerfile.ee'
  DOCKERFILE_BACKUP='Dockerfile.ee.bak'
  cp -f "$ORACLE_DB_VERSION/$DOCKERFILE" "$ORACLE_DB_VERSION/$DOCKERFILE_BACKUP"
  sed -i -e "/^USER root$/a RUN ln -sfn /usr/share/zoneinfo/Asia/Tokyo /etc/localtime" "$ORACLE_DB_VERSION/$DOCKERFILE"
  # memory等を聞く
  ./buildDockerImage.sh -v "${ORACLE_DB_VERSION}" -e -i
  mv -f "$ORACLE_DB_VERSION/$DOCKERFILE_BACKUP" "$ORACLE_DB_VERSION/$DOCKERFILE" 
  cd ../..
  runOracleDB
fi

