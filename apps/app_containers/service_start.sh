#!/bin/sh

cd `dirname $0`

FORCE_RECREATE=false
while getopts f OPT
do
  case $OPT in
    f)  FORCE_RECREATE=true
        ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
  echo 'please input service'
  exit 1
else
  if [ ! -d "$1" ]; then
    echo 'please input valid service'
    exit 1
  else
    SERVICE="$1"
  fi
fi
if [ -n "$2" ]; then
  echo "$2" > "$1/env.txt"
fi

trap finally EXIT
finally() {
  rm -f "$SERVICE/env.txt"
}


if $FORCE_RECREATE; then
  docker-compose up -d --force-recreate "$1"
else
  docker ps -a | awk '{print $NF}' | egrep -q "^$1$"
  if [ $? -eq 0 ]; then
    docker restart "$1"
  else
    docker-compose up -d "$1"
  fi
fi