FROM alpine as base_content
WORKDIR /tmp
ADD http://apache.cbox.biz//ant/binaries/apache-ant-1.10.6-bin.tar.gz apache-ant.tar.gz
ADD http://apache.cbox.biz/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz maven.tar.gz
ADD https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-x64.tar.xz nodejs.tar.xz
RUN apk add --update tar curl tar unzip wget

RUN curl -LJO  https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u232b09.tar.gz \
  && find . -iname "*.tar.*" -exec tar -xf {} \; \
  && ls -la \
  && mv apache-ant-1.10.6 /opt/ant \
  && mv jdk8u232-b09 /opt/jdk1.8.0_201 \
  && mv apache-maven-3.5.4 /opt/maven \
  && mv node-v8.11.3-linux-x64 /opt/ \
  && rm -rf /tmp/*

FROM base_content as slave_content
ADD https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip /tmp/terraform_0.11.13_linux_amd64.zip
ADD http://cdn.sencha.com/cmd/4.0.1.45/SenchaCmd-4.0.1.45-linux-x64.run.zip /tmp/senchacmd.zip
ADD https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/19.11.6.0/vosp-api-wrappers-java-19.11.6.0.jar /opt/VeracodeJavaAPI.jar
RUN wget --no-check-certificate https://sourceforge.net/projects/ant-contrib/files/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.tar.gz -O /tmp/ant-contrib.tar.gz \
  && tar -xf /tmp/ant-contrib.tar.gz -C /tmp \
  && mv /tmp/ant-contrib/ant-contrib-1.0b3.jar /opt/ant/lib/ \
  && unzip /tmp/senchacmd.zip -d /opt \
  && unzip /tmp/terraform_0.11.13_linux_amd64.zip -d /opt \
  && rm -rf /tmp/*

FROM centos:7 as base_install
USER root
ENV JAVA_HOME=/opt/jdk1.8.0_201
ENV M2_HOME=/opt/maven
ENV NODE_HOME=/usr/local/node-v8.11.3-linux-x64
ENV HOME=/var/jenkins/worker
ENV NPM_CONFIG_PREFIX=/var/jenkins/worker/.npm-global
ENV PATH=$NODE_HOME/bin:$ANT_HOME/bin:$M2_HOME/bin:$NPM_CONFIG_PREFIX/bin:$PATH
COPY ./setup/entrypoint.sh /usr/local/bin/
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash \
  && yum -y update && yum -y install epel-release \
  && yum -y install git-lfs \
    bzip2 \
    git \
    openssh \
    openssh-clients \
    openssh-server \
    rsync \
    sshpass \
    sudo \
    unzip \
    wget \
    zip \
    strace pango libXcomposite libXcursor libXdamage libXext libXi \
    libXtst cups-libs libXScrnSaver libXrandr GConf2 alsa-lib atk gtk3 cairo jq \
    ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc \
  && yum clean all
RUN mkdir -p /var/jenkins/worker \
  && git-lfs install \
  && chown 1000:1000 /var/jenkins/worker \
  && groupadd -g 1000 jenkins \
  && useradd -d "/var/jenkins/worker" -u 1000 -g 1000 -m -s /bin/bash jenkins \
  && echo "jenkins    ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers \
  && chown -R jenkins:jenkins /var/jenkins/worker \
  && chmod a+x /usr/local/bin/entrypoint.sh \
  && sed -i 's/\r//' /usr/local/bin/entrypoint.sh


FROM base_install as slave
COPY --from=slave_content /opt /opt
USER jenkins
RUN sudo yum update -y && sudo yum -y install python-pip \
  && sudo pip install ansible-cmdb \
  && sudo update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_201/bin/java 100 \
  && sudo update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_201/bin/javac 100 \
  && sudo mv /opt/node-v8.11.3-linux-x64 /usr/local \
  && sudo mv /opt/terraform /bin \
  && sudo mv /opt/VeracodeJavaAPI.jar /usr/local/VeracodeJavaAPI.jar \
  && sudo chmod a+x /opt/SenchaCmd-4.0.1.45-linux-x64.run \
  && sudo /opt/SenchaCmd-4.0.1.45-linux-x64.run --mode unattended --prefix /opt \
  && sudo chmod a+x /opt/Sencha/Cmd/4.0.1.45/sencha \
  && sudo chown -R jenkins /usr/local/node-v8.11.3-linux-x64 \
  && sudo chmod 0775 /usr/local/VeracodeJavaAPI.jar \
  && sudo chown -R jenkins:jenkins /var/jenkins/worker \
  && npm install -g sonarqube-scanner
VOLUME /var/jenkins/worker
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 22 4444 5555
