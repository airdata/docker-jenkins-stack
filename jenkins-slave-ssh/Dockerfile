FROM airdata/jenkins-slave:latest
USER root
ADD ./setup/sshd_config /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && echo root:password123 | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
