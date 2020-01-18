#!/bin/bash

mkdir -p ~/.m2

[ $(node -p "try{require('html-inline/package.json').version}catch(e){}") != "1.2.0" ] && npm install -g html-inline@1.2.0
[ $(node -p "try{require('puppeteer-webshot-cli/package.json').version}catch(e){}") != "1.0.2" ] && npm install -g puppeteer-webshot-cli@1.0.2

KEYGEN=/usr/bin/ssh-keygen
KEYFILE=~/.ssh/id_rsa

if [ ! -f $KEYFILE ]; then
  $KEYGEN -q -t rsa -N "" -f $KEYFILE
  cat $KEYFILE.pub >> ~/.ssh/authorized_keys
fi
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 http://jenkins-master:8080/jnlpJars/agent.jar -O /tmp/agent.jar
sudo chmod 666 /tmp/agent.jar
java -jar /tmp/agent.jar -jnlpUrl  http://jenkins-master:8080/computer/slave/slave-agent.jnlp -workDir "/var/jenkins/worker"
exec "$@"
