#!/bin/bash

source ../common/common-functions.sh

cleanup_previous_runs

echo "Setting-up demo for ansible JBUG"
# set-up an nxinx server to serve static content
docker run -d --name webserver -v /home/share/ansible-demo/html:/var/www/html tschloss/nginx nginx > /dev/null

# set-up one node to practice on
ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh2 /usr/sbin/sshd -D | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

HOSTS_FILE=hosts
cat > $HOSTS_FILE <<EOF
[nodes]
$ADDRESS
EOF

import_ssh_key $ADDRESS

echo "Node is running on $ADDRESS and host file has been created in $HOSTS_FILE"
