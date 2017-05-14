FROM base-alpine:latest

RUN wget --no-check-certificate https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.45/bin/apache-tomcat-6.0.45.tar.gz

RUN tar zxvf apache-tomcat-6.0.45.tar.gz; rm -f apache-tomcat-6.0.45.tar.gz
RUN mv apache-tomcat-6.0.45 /usr/local/tomcat
RUN sed -i -e 's/exec "\$PRGDIR"\/"\$EXECUTABLE" start "\$@"/exec "\$PRGDIR"\/"\$EXECUTABLE" jpda start "\$@"/g' /usr/local/tomcat/bin/startup.sh
RUN sed -i -e '/^<\/tomcat-users>$/ i \  <role rolename="manager-gui"\/>' /usr/local/tomcat/conf/tomcat-users.xml
RUN sed -i -e '/^<\/tomcat-users>$/ i \  <user username="tomcat" password="tomcat" roles="manager-gui"\/>' /usr/local/tomcat/conf/tomcat-users.xml

RUN sed -i -e "/<\/Server>$/ i \  <Listener className=\"org\.apache\.catalina\.mbeans\.JmxRemoteLifecycleListener\" rmiRegistryPortPlatform=\"9090\" rmiServerPortPlatform=\"9091\"\/>" /usr/local/tomcat/conf/server.xml

RUN wget --no-check-certificate https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.45/bin/extras/catalina-jmx-remote.jar

RUN mv -f catalina-jmx-remote.jar /usr/local/tomcat/lib/

COPY setenv.sh /usr/local/tomcat/bin
RUN chmod +x /usr/local/tomcat/bin/setenv.sh