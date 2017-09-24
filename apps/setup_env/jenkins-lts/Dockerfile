FROM jenkins/jenkins:lts

# RUN mkdir -p /var/jenkins_home/secrets
# RUN echo 'admin' > /var/jenkins_home/secrets/initialAdminPassword

USER root

RUN ln -sfn /bin/bash /bin/sh

# RUN apt-get update
# RUN apt-get -y install \
#         apt-transport-https \
#         ca-certificates \
#         curl \
#         software-properties-common
# RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
# RUN add-apt-repository \
#         "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
#         $(lsb_release -cs) \
#         stable"
# RUN apt-get update
# RUN apt-get -y install docker-ce

USER jenkins