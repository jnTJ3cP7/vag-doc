#!/bin/sh

trap finally EXIT

finally() {
  mv -f "$ORACLE_DB_VERSION/$DOCKERFILE_BACKUP" "$ORACLE_DB_VERSION/$DOCKERFILE"
  mv -f "$ORACLE_DB_VERSION/dbca.rsp.tmpl.bak" "$ORACLE_DB_VERSION/dbca.rsp.tmpl"
  mv -f "$ORACLE_DB_VERSION/createDB.sh.bak" "$ORACLE_DB_VERSION/createDB.sh"
}

runOracleDB() {
  docker-compose up oracle > ~/dockerRun.log 2>&1 &
  exec 2> /dev/null
  sh -c 'tail -n +0 -f ~/dockerRun.log | { while read -r line; do echo $line; \
    echo $line | grep -q "DATABASE IS READY TO USE" && break; done && kill $$; }' || :
  rm -f dockerRun.log
}

if [ $# -eq 1 ] && [ -d "$1" ]; then
  cd $1
else
  cd `dirname $0`
fi

docker images | grep -q 'oracle/database'
if [ $? -eq 0 ]; then
  runOracleDB
else
  cp -f OracleDatabase/dockerfiles/12.2.0.1/dbca.rsp.tmpl OracleDatabase/dockerfiles/12.2.0.1/dbca.rsp.tmpl.bak
  cp -f OracleDatabase/dockerfiles/12.2.0.1/createDB.sh OracleDatabase/dockerfiles/12.2.0.1/createDB.sh.bak
  if [ -e db_env.properties ]; then
    DB_MEMORY=`awk -F = '$1 == "MEMORY" { print $2 }' db_env.properties`
    DB_PASSWORD=`awk -F = '$1 == "PASSWORD" { print $2 }' db_env.properties`
    sed -i -e "s/^totalMemory=2048$/totalMemory=${DB_MEMORY}/g" OracleDatabase/dockerfiles/12.2.0.1/dbca.rsp.tmpl
    sed -i -e "s/^ORACLE_PWD=\"test\"$/ORACLE_PWD=\"${DB_PASSWORD}\"/g" OracleDatabase/dockerfiles/12.2.0.1/createDB.sh
  fi
  cd OracleDatabase/dockerfiles
  ORACLE_DB_VERSION='12.2.0.1'
  DOCKERFILE='Dockerfile.ee'
  DOCKERFILE_BACKUP='Dockerfile.ee.bak'
  cp -f "$ORACLE_DB_VERSION/$DOCKERFILE" "$ORACLE_DB_VERSION/$DOCKERFILE_BACKUP"
  sed -i -e "/^USER root$/a RUN ln -sfn /usr/share/zoneinfo/Asia/Tokyo /etc/localtime" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^USER root$/a RUN yum -y install rlwrap" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^USER root$/a RUN rpm -ivh epel-release-latest-7\.noarch\.rpm" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^USER root$/a RUN wget https:\/\/dl\.fedoraproject\.org\/pub\/epel\/epel-release-latest-7\.noarch\.rpm" "$ORACLE_DB_VERSION/$DOCKERFILE"

  sed -i -e "/^WORKDIR \/home\/oracle$/i RUN mkdir \/home\/oracle\/rlwrap-extensions \/home\/oracle\/alias" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i WORKDIR \/home\/oracle\/rlwrap-extensions" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i RUN wget --no-check-certificate http:\/\/www\.linuxification\.at\/download\/rlwrap-extensions-V12-0\.05\.tar\.gz" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i RUN tar xvfz rlwrap-extensions-V\*\.tar\.gz" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i RUN echo -e \"#!\/bin\/sh\\\nrlwrap -pRed -if \/home\/oracle\/rlwrap-extensions\/sqlplus \$ORACLE_HOME\/bin\/sqlplus \\\\\"\\\\\$@\\\\\"\" > \/home\/oracle\/alias\/sqlplus" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i RUN chmod \+x \/home\/oracle\/alias\/sqlplus" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i ENV PATH=\/home\/oracle\/alias:\$PATH" "$ORACLE_DB_VERSION/$DOCKERFILE"

  sed -i -e "/^WORKDIR \/home\/oracle$/i ENV NLS_LANG=Japanese_Japan\.AL32UTF8" "$ORACLE_DB_VERSION/$DOCKERFILE"
  sed -i -e "/^WORKDIR \/home\/oracle$/i ENV ORA_SDTZ=Japan" "$ORACLE_DB_VERSION/$DOCKERFILE"


  sed -i -e '$ a WORKDIR \/home\/oracle\/sqlplus' "$ORACLE_DB_VERSION/$DOCKERFILE"


  ./buildDockerImage.sh -v "${ORACLE_DB_VERSION}" -e -i
  finally
  cd ../..
  runOracleDB
fi
