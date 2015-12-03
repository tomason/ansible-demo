#!/bin/bash

source ../common/common-functions.sh

cleanup_previous_runs

echo "Setting-up demo2 for ansible JBUG"
# set-up an nxinx server to serve static content
deploy_resource_server

# set-up master
MASTER_ADDRESS=$(deploy_machine "tschloss/ssh:fedora" "--link webserver:webserver")

# set-up two nodes
NODE1_ADDRESS=$(deploy_machine "tschloss/ssh:fedora" "--link webserver:webserver")
NODE2_ADDRESS=$(deploy_machine "tschloss/ssh:centos" "--link webserver:webserver")

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
#import_ssh_key $NODE2_ADDRESS

echo "Master is running on $MASTER_ADDRESS, nodes on $NODE1_ADDRESS and $NODE2_ADDRESS and host file has been created in $HOSTS_FILE"
