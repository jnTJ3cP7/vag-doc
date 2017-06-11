FROM base-alpine:latest

RUN mkdir /zips
ADD instantclient* /zips/
RUN unzip /zips/instantclient-basic* -d /
RUN mv -f /instantclient* /sqlplus
RUN unzip /zips/instantclient-sqlplus* -d /
RUN cp -fr /instantclient*/* /sqlplus/
RUN rm -rf /instantclient*
RUN unzip /zips/instantclient-tools* -d /
RUN cp -fr /instantclient*/* /sqlplus/
RUN rm -rf /instantclient*

RUN ln -s /sqlplus/libclntsh.so.12.1 /sqlplus/libclntsh.so
RUN ln -s /sqlplus/libocci.so.12.1 /sqlplus/libocci.so
RUN apk --update add libaio

ENV LD_LIBRARY_PATH=/sqlplus
ENV PATH=/sqlplus:$PATH
ENV NLS_LANG=Japanese_Japan.AL32UTF8
ENV ORA_SDTZ=Japan

RUN rm -rf /zips


ADD jdk-8* /
RUN ln -sfn /jdk1.8* /usr/local/java

ENV JAVA_HOME=/usr/local/java
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar


COPY sqlcl-* /
RUN unzip sqlcl-* && \
  rm -f sqlcl-*.zip && \
  chmod +x sqlcl/bin/sql

RUN mkdir /alias
RUN echo -e "#!/bin/sh\n/sqlcl/bin/sql \"\$@\"" > /alias/sqlplus
RUN chmod +x /alias/sqlplus
ENV PATH=/alias:$PATH


RUN sed -i -e "s/^securerandom.source=.*$/securerandom\.source=file:\/dev\/urandom/" $JAVA_HOME/jre/lib/security/java.security

WORKDIR /scripts
