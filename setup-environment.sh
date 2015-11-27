#!/bin/bash

# Script to prepare environment for demo

# copy the public key to authorized_keys for the containers
if [ ! -e common/ssh/files/authorized_keys ]; then
  if [ -e ~/.ssh/id_rsa.pub ]; then
    cp ~/.ssh/id_rsa.pub common/ssh/files/authorized_keys
  else
    echo "Please create file 'common/ssh/files/authorized_keys' with public ssh key that you want to use for connecting to containers."
    exit 1
  fi
fi

# copy authorized_keys to centos image
cp common/ssh/files/authorized_keys common/ssh-centos/files/authorized_keys

# build the docker images for creating ssh containers
docker build -t tschloss/ssh:fedora common/ssh
docker build -t tschloss/ssh:centos common/ssh-centos

# save the ecdsa key of the container to the common scripts
docker run --rm tschloss/ssh:fedora cat /etc/ssh/ssh_host_ecdsa_key.pub > common/container_key.pub


# build the docker image for serving web content
docker build -t tschloss/nginx common/nginx

# build the docker images for downloading rpm packages
docker build -t tschloss/repobuilder:fedora common/repobuilder
docker build -t tschloss/repobuilder:centos common/repobuilder-centos

CONTENT_DIR=`realpath common/html`
mkdir -p "$CONTENT_DIR"
mkdir -p "$CONTENT_DIR/fedora"
mkdir -p "$CONTENT_DIR/centos"

# download WildFly 9 zip to common content
if [ ! -e "${CONTENT_DIR}/wildfly9.zip" ]; then
  echo "Download wildfly zip"
  curl "http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.zip" > $CONTENT_DIR/wildfly9.zip
fi

# download RPMs for installing later
echo "Download OpenJDK package"
docker run --rm -itv $CONTENT_DIR/fedora:/mnt/fedora tschloss/repobuilder:fedora dnf download --resolve java-1.8.0-openjdk-devel

echo "Build repository from downloaded packages"
docker run --rm -itv $CONTENT_DIR/fedora:/mnt/fedora tschloss/repobuilder:fedora createrepo_c /mnt/fedora

# download CentOS RPMs for installing later
echo "Download OpenJDK package (CentOS)"
docker run --rm -itv $CONTENT_DIR/centos:/mnt/centos tschloss/repobuilder:centos yumdownloader -y --resolve --destdir=/mnt/centos java-1.8.0-openjdk-devel

echo "Build repository from downloaded packages"
docker run --rm -itv $CONTENT_DIR/centos:/mnt/centos tschloss/repobuilder:centos createrepo /mnt/centos
