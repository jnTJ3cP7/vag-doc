FROM base-alpine:latest

ARG MAVEN_VERSION

# antはjava6が動く中では最新
RUN wget --no-check-certificate http://www.apache.org/dist/ant/binaries/apache-ant-1.9.9-bin.tar.gz \
https://jaist.dl.sourceforge.net/project/ant-contrib/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.tar.gz \
http://ftp.kddilabs.jp/infosystems/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

RUN find . -maxdepth 1 -type f -name "*.tar.gz" -print0 | xargs -0 -n 1 tar zxvf
RUN find . -maxdepth 1 -type f -name "*.tar.gz" -print0 | xargs -0 -n 1 rm -f

RUN mv -f apache-ant-* apache-ant; chmod u+x apache-ant/bin/ant
RUN cp -rf ant-contrib/ant-contrib-1.0b3.jar apache-ant/lib/; rm -rf ant-contrib
RUN mv -f apache-maven-* apache-maven; chmod u+x apache-maven/bin/mvn

ADD jdk-* /
RUN chmod u+x /jdk-6*.bin
RUN ./jdk-6*.bin
RUN rm -f jdk-6*.bin

ENV ANT_HOME=/apache-ant

ENV M2_HOME=/apache-maven
ENV M2=$M2_HOME/bin

ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin:$M2:$ANT_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar


COPY build-app.sh /
RUN chmod -R u+x /build-app.sh
ENTRYPOINT ["/build-app.sh"]
