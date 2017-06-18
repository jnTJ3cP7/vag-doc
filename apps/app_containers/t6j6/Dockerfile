FROM tomcat6-java6:latest

ARG CONTEXT_PATH

RUN sed -i -e "/<\/Host>$/ i \        <Context path=\"\/$CONTEXT_PATH\" docBase=\"$CONTEXT_PATH\" reloadable=\"true\" allowLinking=\"true\"\/>" /usr/local/tomcat/conf/server.xml


RUN sed -i "`expr \$(fgrep -n '<Connector port=\"8443\"' \/usr\/local\/tomcat\/conf\/server\.xml | awk -F: '{print \$1}') - 1`d" /usr/local/tomcat/conf/server.xml
RUN sed -i "`grep -n -- '-->' \/usr\/local\/tomcat\/conf\/server\.xml | \
  awk -v base=\$(fgrep -n '<Connector port=\"8443\"' \/usr\/local\/tomcat\/conf\/server\.xml | awk -F: '{print \$1}') -F: '\$1 > base {print \$1}' | head -1`d" \
  /usr/local/tomcat/conf/server.xml
RUN sed -i "s/^\(.*<Connector port=\"8443\".*\)SSLEnabled=\"true\"\(.*\)$/\1\2/g" /usr/local/tomcat/conf/server.xml