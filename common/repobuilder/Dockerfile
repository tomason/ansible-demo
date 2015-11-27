FROM fedora:23
MAINTAINER tschloss@redhat.com

# add volume for web content
VOLUME /mnt/fedora

# install everything necessary
RUN dnf install -y 'dnf-command(download)' && dnf install -y createrepo_c

WORKDIR /mnt/fedora
