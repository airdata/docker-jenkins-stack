FROM airdata/jenkins-master-docker:latest

ADD ./setup /usr/share/jenkins/ref/

USER root

RUN apt-get update -y \
  && apt-get install -y jq sudo \
  && apt-get autoremove -y 

USER jenkins
ENV JAVA_OPTS="-Xmx2048m"
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt; exit 0
VOLUME [ "/var/jenkins/cache", "/var/jenkins_home", "/var/log/jenkins" ]
EXPOSE 4444
