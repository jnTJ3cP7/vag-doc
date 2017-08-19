#!/bin/sh


./asadmin start-domain 
./asadmin --user=admin --passwordfile=/tmp/glassfishpwd enable-secure-admin
./asadmin stop-domain 
rm -f /tmp/glassfishpwd
sed -i "s/<protocol.*name=\"http-listener-2\">/<protocol security-enabled=\"true\" name=\"http-listener-2\">/g" ../glassfish/domains/domain1/config/domain.xml
./asadmin start-domain 


tail -f /dev/null