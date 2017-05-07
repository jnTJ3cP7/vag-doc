#!/bin/sh


echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
service network restart

timedatectl set-timezone Asia/Tokyo
localectl set-locale LANG=ja_JP.UTF-8

echo 'cd /vagrant' >> /home/vagrant/.bash_profile

# check latest verison in https://github.com/docker/compose/blob/master/CHANGELOG.md
sh -c "curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
chmod +x /usr/local/bin/docker-compose
# yum install -y epel-release
# yum -y update
curl -sSL https://get.docker.com/ | sh
systemctl start docker.service
systemctl enable docker.service
usermod -a -G docker vagrant
systemctl stop docker.service
rm -rf /var/lib/docker
exit