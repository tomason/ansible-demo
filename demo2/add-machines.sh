#!/bin/bash

source ../common/common-functions.sh

# set-up two more nodes
NODE1_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh:fedora /usr/sbin/sshd -D | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')
NODE2_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh:fedora /usr/sbin/sshd -D | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

HOSTS_FILE=hosts
echo "$NODE1_ADDRESS  node_servers=1  node_username=node3  node_password=password3!" >> $HOSTS_FILE
echo "$NODE2_ADDRESS  node_servers=1  node_username=node4  node_password=node4pwd!" >> $HOSTS_FILE

import_ssh_key $NODE1_ADDRESS
import_ssh_key $NODE2_ADDRESS

echo "Two additional nodes on $NODE1_ADDRESS and $NODE2_ADDRESS and were added to the host file $HOSTS_FILE"
