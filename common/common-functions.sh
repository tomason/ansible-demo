#!/bin/bash
# common functions for ansible demos

COMMON_DIR=`realpath ../common`

function cleanup_previous_runs() {
  echo "Cleaning up previous run"
  docker ps -q | xargs --no-run-if-empty docker kill > /dev/null
  docker ps -aq | xargs --no-run-if-empty docker rm > /dev/null
}

function deploy_machine() {
  local name=$1
  local options=$2

  # ignore the docker error output (e.g. warning about using loopback device)
  # find IPAddress in docker imspect and parse it (since recently there are 2 same addresses hence the uniq command)
  docker run -d $options $name 2> /dev/null | xargs docker inspect | grep IPAddress | sed -rn 's/.*"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)".*/\1/p' | uniq
}

function deploy_resource_server() {
  # ignore webserver's IP address
  deploy_machine "tschloss/nginx" "--name webserver -v ${COMMON_DIR}/html:/var/www/html" > /dev/null
}

function import_ssh_key() {
  local IP_ADDRESS=$1

  echo "${IP_ADDRESS} `cat ${COMMON_DIR}/container_key.pub`" >> ~/.ssh/known_hosts
}


