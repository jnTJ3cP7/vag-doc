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

WORKDIR /scripts

