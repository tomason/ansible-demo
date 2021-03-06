#!/bin/bash

source ../common/common-functions.sh

cleanup_previous_runs

echo "Setting-up demo for ansible JBUG"
# set-up an nxinx server to serve static content
deploy_resource_server

# set-up one node to practice on
ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh:fedora 2> /dev/null | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p' | uniq )

HOSTS_FILE=hosts
cat > $HOSTS_FILE <<EOF
[nodes]
$ADDRESS
EOF

import_ssh_key $ADDRESS

echo "Node is running on $ADDRESS and host file has been created in $HOSTS_FILE"
