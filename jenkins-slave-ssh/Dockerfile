FROM alpine as slave_content
WORKDIR /tmp
RUN apk add --update tar curl tar unzip wget
RUN curl -LJO https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u232b09.tar.gz \
  && curl -LJO http://apache.cbox.biz//ant/binaries/apache-ant-1.10.8-bin.tar.gz  \
  && curl -LJO http://apache.cbox.biz/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz \
  && curl -LJO https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-x64.tar.xz \
  && wget --no-check-certificate https://sourceforge.net/projects/ant-contrib/files/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.tar.gz \
  && wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
  && wget http://cdn.sencha.com/cmd/4.0.1.45/SenchaCmd-4.0.1.45-linux-x64.run.zip -O /tmp/senchacmd.zip \
  && find . -iname "*.tar.*" -exec tar -xf {} \; \
  && mv apache-ant-1.10.6 /opt/ant \
  && mv jdk8u232-b09 /opt/jdk1.8.0_201 \
  && mv apache-maven-3.5.4 /opt/maven \
  && mv node-v8.11.3-linux-x64 /opt/ \
  && mv /tmp/ant-contrib/ant-contrib-1.0b3.jar /opt/ant/lib/ \
  && unzip /tmp/senchacmd.zip -d /opt \
  && unzip /tmp/terraform_0.11.13_linux_amd64.zip -d /opt

FROM centos:7 as base_install
USER root
ENV JAVA_HOME=/opt/jdk1.8.0_201
ENV M2_HOME=/opt/maven
ENV NODE_HOME=/usr/local/node-v8.11.3-linux-x64
ENV HOME=/var/jenkins/worker
ENV NPM_CONFIG_PREFIX=/var/jenkins/worker/.npm-global
ENV PATH=$NODE_HOME/bin:$ANT_HOME/bin:$M2_HOME/bin:$NPM_CONFIG_PREFIX/bin:$PATH
ADD ./setup/sshd_config /etc/ssh/sshd_config
COPY --from=slave_content /opt/ /opt/
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
    python-pip \
  && yum clean all
RUN mkdir -p /var/jenkins/worker \
  && git-lfs install \
  && chown 1000:1000 /var/jenkins/worker \
  && groupadd -g 1000 jenkins \
  && useradd -d "/var/jenkins/worker" -u 1000 -g 1000 -m -s /bin/bash jenkins \
  && echo "jenkins    ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers \
  && chown -R jenkins:jenkins /var/jenkins/worker \
  && ssh-keygen -A \
  && echo root:password123 | chpasswd
RUN sudo pip install ansible-cmdb \
  && sudo update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_201/bin/java 100 \
  && sudo update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_201/bin/javac 100 \
  && sudo mv /opt/node-v8.11.3-linux-x64 /usr/local \
  && sudo mv /opt/terraform /bin \
  && sudo chmod a+x /opt/SenchaCmd-4.0.1.45-linux-x64.run \
  && sudo /opt/SenchaCmd-4.0.1.45-linux-x64.run --mode unattended --prefix /opt \
  && sudo chmod a+x /opt/Sencha/Cmd/4.0.1.45/sencha \
  && sudo chown -R jenkins /usr/local/node-v8.11.3-linux-x64 \
  && sudo chown -R jenkins:jenkins /var/jenkins/worker \
  && sudo rm -rf /tmp/* \
  && npm install -g sonarqube-scanner

CMD ["/usr/sbin/sshd", "-D"]
