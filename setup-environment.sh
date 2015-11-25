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

# build the docker image for creating ssh containers
docker build -t tschloss/ssh common/ssh

# save the ecdsa key of the container to the common scripts
docker run --rm tschloss/ssh cat /etc/ssh/ssh_host_ecdsa_key.pub > common/container_key.pub


# build the docker image for serving web content
docker build -t tschloss/nginx common/nginx

# build the docker image for downloading rpm packages
docker build -t tschloss/repobuilder common/repobuilder

CONTENT_DIR=`realpath common/html`
mkdir -p "$CONTENT_DIR"
mkdir -p "$CONTENT_DIR/fedora"

# download WildFly 9 zip to common content
if [ ! -e "${CONTENT_DIR}/wildfly9.zip" ]; then
  echo "Download wildfly zip"
  curl "http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.zip" > $CONTENT_DIR/wildfly9.zip
fi

# download RPMs for installing later
echo "Download OpenJDK package"
docker run --rm -itv $CONTENT_DIR/fedora:/mnt/fedora tschloss/repobuilder dnf download --resolve java-1.8.0-openjdk-devel

echo "Build repository from downloaded packages"
docker run --rm -itv $CONTENT_DIR/fedora:/mnt/fedora tschloss/repobuilder createrepo_c /mnt/fedora

