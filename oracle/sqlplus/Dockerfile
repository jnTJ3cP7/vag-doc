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


RUN wget --no-check-certificate https://github.com/hanslub42/rlwrap/archive/master.zip
RUN unzip /master.zip -d /
WORKDIR /rlwrap-master
RUN apk --update add make gcc g++ autoconf automake libtool readline-dev 	ncurses-dev
RUN autoreconf --install
RUN automake  --add-missing
RUN ./configure
RUN make
RUN make install

RUN mkdir /rlwrap-extensions
WORKDIR /rlwrap-extensions
RUN wget --no-check-certificate  http://www.linuxification.at/download/rlwrap-extensions-V12-0.05.tar.gz
RUN tar xvfz rlwrap-extensions-V*.tar.gz

RUN mkdir /alias
RUN echo -e "#!/bin/sh\nrlwrap -pRed -if /rlwrap-extensions/sqlplus /sqlplus/sqlplus \"\$@\"" > /alias/sqlplus
RUN chmod +x /alias/sqlplus
ENV PATH=/alias:$PATH

WORKDIR /scripts
