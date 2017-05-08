FROM tomcat6:latest

RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
      http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin

RUN chmod u+x /jdk-6u45-linux-x64.bin
RUN ./jdk-6u45-linux-x64.bin
RUN rm -f jdk-6u45-linux-x64.bin
RUN ln -sfn /jdk1.6* /usr/local/java

ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
