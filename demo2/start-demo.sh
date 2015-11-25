#!/bin/bash

function import_ssh_key() {
  local IP_ADDRESS=$1

  echo "${IP_ADDRESS} ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJqsrYP53KFxoLgHr1Ai+anVrcr3ggwJ7GKuXpcLY/i6QKmyM4gbWKAzngCS4PajvZVaBv3TWPBCXjb48GhjHQ8=" >> ~/.ssh/known_hosts
}

echo "Cleaning up previous run"
docker ps -q | xargs --no-run-if-empty docker kill > /dev/null
docker ps -aq | xargs --no-run-if-empty docker rm > /dev/null

echo "Setting-up demo2 for ansible JBUG"
# set-up an nxinx server to serve static content
docker run -d --name webserver -v /home/share/ansible-demo/html:/var/www/html tschloss/nginx nginx > /dev/null

# set-up master
MASTER_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh2 | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

# set-up two nodes
NODE1_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh /usr/sbin/sshd -D | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')
NODE2_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh /usr/sbin/sshd -D | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

HOSTS_FILE=hosts
cat > $HOSTS_FILE <<EOF
[master]
$MASTER_ADDRESS  node_username=admin

[nodes]
$NODE1_ADDRESS  node_servers=1  node_username=node1  node_password=node1password!
$NODE2_ADDRESS  node_servers=1  node_username=node2  node_password=node2password!
EOF

import_ssh_key $MASTER_ADDRESS
import_ssh_key $NODE1_ADDRESS
import_ssh_key $NODE2_ADDRESS

echo "Master is running on $MASTER_ADDRESS, nodes on $NODE1_ADDRESS and $NODE2_ADDRESS and host file has been created in $HOSTS_FILE"
