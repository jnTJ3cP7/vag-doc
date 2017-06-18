#!/bin/sh

readonly TOMCAT_DIR='/usr/local/tomcat'
readonly TEST_ECHO='this is テスト !!！！'

# env settings
pro() {
  echo 'pro' > /pro.txt
}
stg() {
  echo 'stg' > /stg.txt
}
default() {
  echo 'default' > /def.txt
  stg
}
env_settings() {
  case "$1" in
    'pro')  pro
            ;;
    'stg')  stg
            ;;
    *)  default
        ;;
  esac
}

if [ -r ./env.txt ]; then
  env_settings `head -1 env.txt`
else
  env_settings default
fi