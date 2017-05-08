FROM tomcat6-java6:latest

ARG CONTEXT_PATH

RUN sed -i -e "/<\/Host>$/ i \        <Context path=\"\/$CONTEXT_PATH\" docBase=\"$CONTEXT_PATH\" reloadable=\"true\" allowLinking=\"true\"\/>" /usr/local/tomcat/conf/server.xml

COPY executeContainer.sh /
RUN chmod u+x executeContainer.sh
