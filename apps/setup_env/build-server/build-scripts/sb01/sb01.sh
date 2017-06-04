#!/bin/sh

ln -sfn /jdk1.8* /usr/local/java
cd /workspace/SpringBoot02
mvn package -Dmaven.test.skip=true
