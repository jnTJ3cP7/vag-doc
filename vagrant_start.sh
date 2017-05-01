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
  sed -i -e "s/vbguest\.auto_update.*$/vbguest\.auto_update = true/g" ./Vagrantfile
  sed -i -e "s/vbguest\.no_remote.*$/vbguest\.no_remote = false/g" ./Vagrantfile
  vagrant up --provision-with firstRunning
  vagrantReload ${@+"$@"}
  sed -i -e "s/vbguest\.auto_update.*$/vbguest\.auto_update = false/g" ./Vagrantfile
  sed -i -e "s/vbguest\.no_remote.*$/vbguest\.no_remote = true/g" ./Vagrantfile
  rm -f ./Vagrantfile-e
else
  # ２回目以降はすでに起動しているかどうかを確認する
  vagrant status | grep -q 'running (virtualbox)'
  if [ $? -eq 0 ]; then
    vagrantReload ${@+"$@"}
  else
    vagrantUp ${@+"$@"}
  fi
fi
