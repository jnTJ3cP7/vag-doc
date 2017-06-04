#!/bin/sh

clean () {
  if [ $1 = Tomcat6Java6 ]; then
    rm -rf /workspace/$1/src/main/webapp/WEB-INF/classes/
    mkdir -p /workspace/$1/src/main/webapp/WEB-INF/classes/
  else
    rm -rf /workspace/$1/target/classes/
    mkdir -p /workspace/$1/target/classes/
  fi
}

cd `dirname $0`
ln -sfn /jdk1.6* /usr/local/java;

awk -F= '$1=="dep.lis" {print $NF}' build.properties | \
  awk -F, '{for(i=1;i<=NF;i++){print $i}}' | while read -r line; do clean $line; done

ant;
