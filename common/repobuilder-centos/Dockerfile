FROM centos:7
MAINTAINER tschloss@redhat.com

# add volume for web content
VOLUME /mnt/centos

# install everything necessary
RUN yum install -y yum-utils createrepo

WORKDIR /mnt/centos
