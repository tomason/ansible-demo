#!/bin/bash
# common functions for ansible demos

COMMON_DIR=`realpath ../common`

function cleanup_previous_runs() {
  echo "Cleaning up previous run"
  docker ps -q | xargs --no-run-if-empty docker kill > /dev/null
  docker ps -aq | xargs --no-run-if-empty docker rm > /dev/null
}

function deploy_resource_server() {
  docker run -d --name webserver -v "${COMMON_DIR}/html:/var/www/html" tschloss/nginx > /dev/null
}

function import_ssh_key() {
  local IP_ADDRESS=$1

  echo "${IP_ADDRESS} `cat ${COMMON_DIR}/container_key.pub`" >> ~/.ssh/known_hosts
}


