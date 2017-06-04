#!/bin/sh

cd /build-scripts

if [ "$1"  = "/bin/sh" ]; then
  echo "please input app name which you want to build."
  exit 1;
else
  for arg in "$@"
  do
    if [ -d "$arg" ]; then
      echo "build start : $arg";
      /bin/sh $arg/$arg.sh
      [ "$?" -ne 0 ] && echo "build failed : $arg" && exit 1;
    else
      echo "unexpected arguments : $arg";
      exit 1;
    fi
  done
fi
echo "build all success";
