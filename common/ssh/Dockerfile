FROM fedora:23
MAINTAINER tschloss@redhat.com

# install everything necessary
RUN dnf install -y openssh-server procps-ng vim bind-utils unzip && \
    dnf clean all && \
    rm /etc/yum.repos.d/*

# required files
ADD files /root/files

# configure the container
RUN cp /root/files/my.repo /etc/yum.repos.d/my.repo && \
    sshd-keygen && \
    mkdir /root/.ssh && \
    cp /root/files/authorized_keys /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# default command is starting ssh server
CMD [ "/usr/sbin/sshd", "-D" ]

