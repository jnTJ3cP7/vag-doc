FROM base-alpine:latest

#java6
ADD jdk-6*.bin /
RUN chmod u+x /jdk-6*.bin
RUN ./jdk-6*.bin
RUN rm -f jdk-6*.bin
RUN ln -sfn /jdk1.6* /usr/local/java

ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar


#glassfis2
RUN wget --no-check-certificate http://download.java.net/javaee5/v2ur2/promoted/Linux/glassfish-installer-v2ur2-b04-linux-ml.jar

RUN sh -c '/bin/echo -e "a" | java -Xmx256m -jar glassfish-installer-*'

RUN rm -rf glassfish-installer*
WORKDIR /glassfish
RUN chmod -R u+x lib/ant/bin
RUN lib/ant/bin/ant -f setup.xml
# RUN bin/asadmin start-domain domain1
# 8080 8181 4848
