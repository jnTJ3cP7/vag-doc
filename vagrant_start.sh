#!/bin/sh

vagrantReload() {
  if [ $# -gt 0 ]; then
    for PROVISION in "$@"
      do
        PROVISIONS=${PROVISIONS}${PROVISION},
      done
      vagrant reload --provision-with `echo $PROVISIONS | sed -e "s/,$//"`
  else
    vagrant reload
  fi
}

vagrantUp() {
  if [ $# -gt 0 ]; then
    for PROVISION in "$@"
      do
        PROVISIONS=${PROVISIONS}${PROVISION},
      done
      vagrant up --provision-with `echo $PROVISIONS | sed -e "s/,$//"`
  else
    vagrant up
  fi
}

VAGRANT_VERSION=`vagrant --version | sed -n -e 's/^Vagrant \(.*\)$/\1/p'`
if [ `echo $VAGRANT_VERSION | wc -c | awk '{print $NF}'` -lt 2 ]; then
  echo 'please install Vagrant'
  exit 1
fi
echo "Vagrant version is $VAGRANT_VERSION"

# vagrant status で１回目かどうか判断する
vagrant status | grep -q 'not created (virtualbox)'
if [ $? -eq 0  ]; then
#vbguest等のプラグインを確認する
  if [ `vagrant plugin list | grep 'vagrant-vbguest' | wc -l | awk '{print $1}'` -lt 1 ]; then
    vagrant plugin install vagrant-vbguest
  fi
  SETTINGS_FILE='settings.yml'
  VBGUEST_LINE=`egrep -vn '^ +' $SETTINGS_FILE | awk -F : '$2 == "vbguest" { print $1 }'`
  NEXT_LINE=`egrep -vn '^ +' $SETTINGS_FILE | awk -v base=$VBGUEST_LINE -F : '$1 > base { print $1 }' | head -1`
  if [NEXT_LINE]
  VBGUEST_LINE=`expr $VBGUEST_LINE + 1`
  NEXT_LINE=`expr $NEXT_LINE - 1`
  if [ $? -gt 1 ]; then
    NEXT_LINE=`grep '' $SETTINGS_FILE | wc -l`
  fi
  sed -i -e "$VBGUEST_LINE,$NEXT_LINE s/^\(.*auto_update:\).*$/\1 true/" $SETTINGS_FILE
  sed -i -e "$VBGUEST_LINE,$NEXT_LINE s/^\(.*no_remote:\).*$/\1 false/" $SETTINGS_FILE
  vagrant up --provision-with firstRunning
  vagrantReload ${@+"$@"}
  sed -i -e "$VBGUEST_LINE,$NEXT_LINE s/^\(.*auto_update:\).*$/\1 false/" $SETTINGS_FILE
  sed -i -e "$VBGUEST_LINE,$NEXT_LINE s/^\(.*no_remote:\).*$/\1 true/" $SETTINGS_FILE
else
  # ２回目以降はすでに起動しているかどうかを確認する
  vagrant status | grep -q 'running (virtualbox)'
  if [ $? -eq 0 ]; then
    vagrantReload ${@+"$@"}
  else
    vagrantUp ${@+"$@"}
  fi
fi
