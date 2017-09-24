FROM jenkins/jenkins:alpine

# RUN mkdir -p /var/jenkins_home/secrets
# RUN echo 'admin' > /var/jenkins_home/secrets/initialAdminPassword

USER root

RUN ln -sfn /bin/bash /bin/sh

RUN apk --update add docker shadow py-pip

RUN pip install docker-compose
RUN usermod -a -G docker jenkins
# RUN rc-update add docker boot
# RUN apk --update add git

# RUN sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf
# RUN echo 'rc_provide="loopback net"' >> /etc/rc.conf
# RUN sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf
# RUN sed -i '/tty/d' /etc/inittab
# RUN sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname
# RUN sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh
# RUN sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh
# RUN touch /run/openrc/softlevel
# USER jenkins