#!/bin/bash

source ../common/common-functions.sh

cleanup_previous_runs

echo "Setting-up demo2 for ansible JBUG"
# set-up an nxinx server to serve static content
deploy_resource_server

# set-up master
MASTER_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

# set-up two nodes
NODE1_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')
NODE2_ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

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
