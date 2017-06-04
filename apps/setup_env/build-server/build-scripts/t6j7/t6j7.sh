#!/bin/sh

ln -sfn /jdk1.7* /usr/local/java;
cd /workspace/Tomcat6Java7Maven01;
mvn compile dependency:copy-dependencies -DincludeScope=runtime;
