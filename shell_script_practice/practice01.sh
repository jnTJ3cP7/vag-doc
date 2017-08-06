#!/bin/sh

echo "${BASH_SOURCE:-$0}"
cd $(dirname ${BASH_SOURCE:-$0})
echo "${BASH_SOURCE:-$0}"

ls -l
BEFORE_PATH=`env | grep -i path`
echo "before:${BEFORE_PATH}"

DATE=`date "+%Y%m%d%H%M%S"`
rm -f "./classpath_${DATE}"
find . -maxdepth 1 -name '*test*' >> "./classpath_${DATE}"
while read -r line
do
  PATH="${PATH}:${line}"
done < "./classpath_${DATE}"
cat "./classpath_${DATE}"
rm -f "./classpath_${DATE}"
echo $PATH

PATH="hogefugahoge:${PATH}"
echo $PATH