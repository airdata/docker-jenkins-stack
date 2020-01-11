FROM jenkins/jenkins:2.198 as master

ADD ./setup /usr/share/jenkins/ref/

USER root

RUN apt-get update \
  && apt-get install -y jq mariadb-client \
  && apt-get autoremove -y \
  && wget https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jdk_x64_linux_8u232b09.tar.gz \
  && tar -xf OpenJDK8U-jdk_x64_linux_8u232b09.tar.gz \
  && rm -rf OpenJDK8U-jdk_x64_linux_8u232b09.tar.gz \
  && mv openjdk-8u232-b09 /opt/jdk1.8.0_201 \
  && ls -la /opt/**/* \
  && mkdir -p \
      /var/jenkins/cache \
      /var/jenkins_home \
      /var/log/jenkins \
  && chown -R jenkins:jenkins \
      /var/jenkins/cache \
      /var/jenkins_home \
      /var/log/jenkins \
      /usr/share/jenkins/ref \
  && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_201/bin/java 100 \
  && update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_201/bin/javac 100

USER jenkins
ENV JAVA_OPTS="-Xmx2048m"
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt; exit 0
VOLUME [ "/var/jenkins/cache", "/var/jenkins_home", "/var/log/jenkins" ]
EXPOSE 4444
