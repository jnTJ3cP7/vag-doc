FROM base-alpine:latest

# RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
      # http://download.oracle.com/otn/java/jdk/8u131-b11/d54c1d‌​3a095b4ff2b6607d096f‌​a80163/jre-8u131-lin‌​ux-x64.tar.gz

RUN wget --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn/java/jdk/8u131-b11/d54c1d‌​3a095b4ff2b6607d096f‌​a80163/jre-8u131-lin‌​ux-x64.tar.gz"

RUN tar zxvf jdk-8*; rm -f jdk-8*
RUN ln -sfn /jdk1.8* /usr/local/java

ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
