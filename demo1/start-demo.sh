#!/bin/bash

echo "Cleaning up previous run"
docker ps -q | xargs --no-run-if-empty docker kill > /dev/null
docker ps -aq | xargs --no-run-if-empty docker rm > /dev/null

echo "Setting-up demo for ansible JBUG"
# set-up an nxinx server to serve static content
docker run -d --name webserver -v /home/share/ansible-demo/html:/var/www/html tschloss/nginx nginx > /dev/null

# set-up one node to practice on
ADDRESS=$(docker run -d --link webserver:webserver tschloss/ssh /usr/sbin/sshd -D | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p')

HOSTS_FILE=hosts
cat > $HOSTS_FILE <<EOF
[nodes]
$ADDRESS
EOF

echo "$ADDRESS ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJqsrYP53KFxoLgHr1Ai+anVrcr3ggwJ7GKuXpcLY/i6QKmyM4gbWKAzngCS4PajvZVaBv3TWPBCXjb48GhjHQ8=" >> ~/.ssh/known_hosts

echo "Node is running on $ADDRESS and host file has been created in $HOSTS_FILE"
