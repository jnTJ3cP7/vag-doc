#!/bin/sh

DATE=`date +%Y%m%d%H%M%S`
NOW_DIR=`dirname .`
TARGET_DIR="/temp_${DATE}"
OUTPUT_DIR="/output"
PASS_PHRASE='docker'
COUNTRY='JP'

if [ -z "$1" ]; then
  echo '####### please input domain #########'
  read -p 'DOMAIN : ' DOMAIN
else
  DOMAIN="$1"
fi

rm -rf "${TARGET_DIR}"
mkdir "${TARGET_DIR}"
cd "${TARGET_DIR}"


expect <<EOF
spawn openssl genrsa -des3 -out server.orig.key 2048
expect {
  "key:" { send "${PASS_PHRASE}\n"; exp_continue }
  eof
}
EOF


expect <<EOF
spawn openssl rsa -in server.orig.key -out server.key
expect {
  "key:" { send "${PASS_PHRASE}\n"; exp_continue }
  eof
}
EOF


expect <<EOF
spawn openssl req -new -key server.key -out server.csr
expect {
  "Country Name *:" { send "${COUNTRY}\n"; exp_continue }
  "State or Province Name *:" { send "${PASS_PHRASE}\n"; exp_continue }
  "Locality Name *:" { send "${PASS_PHRASE}\n"; exp_continue }
  "Organization Name *:" { send "${PASS_PHRASE}\n"; exp_continue }
  "Organizational Unit Name *:" { send "${PASS_PHRASE}\n"; exp_continue }
  "Common Name *:" { send "${DOMAIN}\n"; exp_continue }
  "Email Address *:" { send "${PASS_PHRASE}\n"; exp_continue }
  "A challenge password *:" { send "${PASS_PHRASE}\n"; exp_continue }
  "An optional company name *:" { send "${PASS_PHRASE}\n"; exp_continue }
  eof
}
EOF


openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt


mv server.key "${DOMAIN}.key"
mv server.crt "${DOMAIN}.crt"

mv "${DOMAIN}.key" "${DOMAIN}.crt" "${OUTPUT_DIR}"


cd "${NOW_DIR}"