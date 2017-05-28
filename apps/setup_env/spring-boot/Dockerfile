FROM base-alpine:latest

ARG MAVEN_VERSION

RUN wget --no-check-certificate http://ftp.kddilabs.jp/infosystems/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

RUN tar zxvf apache-maven-*; rm -f apache-maven-*.tar.gz
RUN mv -f apache-maven-* apache-maven; chmod u+x apache-maven/bin/mvn

ENV M2_HOME=/apache-maven
ENV M2=$M2_HOME/bin


ADD jdk-8* /
RUN ln -sfn /jdk1.8* /usr/local/java


ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin:$M2
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar


ENV MAVEN_OPTS="-Dmaven.test.skip=true"

RUN sed -i -e "s/^securerandom.source=.*$/securerandom\.source=file:\/dev\/urandom/" $JAVA_HOME/jre/lib/security/java.security
