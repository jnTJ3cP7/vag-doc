#!/bin/sh

ln -sfn /jdk1.8* /usr/local/java;
cd /workspace/Tomcat6Java8Maven01;
mvn clean compile dependency:copy-dependencies -DincludeScope=runtime;
