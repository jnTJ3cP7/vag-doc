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


#glassfis3
ENV MD5=ae8e17e9dcc80117cb4b39284302763f

RUN wget --no-check-certificate http://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip

RUN echo "$MD5  glassfish-3.1.2.2.zip" | md5sum -c -
RUN unzip ./glassfish-3.1.2.2.zip 
RUN mv -f glassfish3 glassfish
RUN rm -rf ./glassfish-3.1.2.2.zip

WORKDIR /glassfish/bin

RUN echo "AS_ADMIN_PASSWORD=" > /tmp/glassfishpwd
RUN echo "AS_ADMIN_NEWPASSWORD=adminadmin" >> /tmp/glassfishpwd
RUN ./asadmin --user=admin --passwordfile=/tmp/glassfishpwd change-admin-password --domain_name domain1
RUN echo -n "adminadmin" | base64 | xargs -i echo "asadmin://admin@172.27.0.1:4848 {}" > /root/.asadminpass
RUN chmod 600 /root/.asadminpass
RUN echo "AS_ADMIN_PASSWORD=adminadmin" > /tmp/glassfishpwd
