FROM localhost:5000/tomcat6:latest

ADD jdk-8* /
RUN ln -sfn /jdk1.8* /usr/local/java

ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin:$M2
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar


RUN sed -i -e "s/^securerandom.source=.*$/securerandom\.source=file:\/dev\/urandom/" $JAVA_HOME/jre/lib/security/java.security
