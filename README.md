# Ansible demo
Demo for presentation on JBUGcz. The purpose of the demo is to show basics of Ansible usage and to demonstrate the installation and setup of Wildfly 9 in domain mode. Demo1 is for the introduction of basic ad-hoc Ansible commands and Demo2 contains a more complex scenario with Ansible playbooks.

## Requirements
To run these demos, you need multiple machines with ssh access and internet access for downloading files and installing packages. If you don't have access to any machines, you can use script `setup-environment.sh` for Docker based setup.

## Offline demo
If you need to run the demo in offline environment, run `setup-environment.sh` script. It will setup local Docker based setup and download any files and packages that are necessary for other demos.

## Setup Script
For the script to run successfully, you will need:
* This git repository
* Docker daemon started
* curl installed
* `common/ssh/files/authorized_keys` file

You can supply your own `authorized_keys` file, or the script will copy the contents of `~/.ssh/id_rsa.pub` and put it to the `authorized_keys` file as the only key.

## List of docker images
* `tschloss/nginx:latest`
 * Fedora 23 based docker image with installed nginx server set to share anything in `/var/www/html` directory.
 * Run docker with volume containing downloaded content.
 * Run docker with named container (makes it easier to link other containers to it.
 * `docker run -d --name webserver -v "/tmp/html:/var/www/html" tschloss/nginx`
* `tschloss/ssh:fedora`
 * Fedora 23 based docker image with Python2 and OpenSSH server installed. Authorized keys file is set for root user and dnf is configured to download data from linked webserver container.
 * Run docker with link to webserver container.
 * `docker run -d --link webserver:webserver tschloss/ssh:fedora`
* `tschloss/ssh:centos`
 * CentOS 7 based docker image with OpenSSH server installed. Authorized keys file is set for root user and yum is configured to download data from linked webserver container.
 * Run docker with link to webserver container.
 * `docker run -d --link webserver:webserver tschloss/ssh:centos`
* tschloss/repobuilder:fedora
 * Fedora 23 based docker image with tools installed for creating offline Fedora repo.
 * Run docker with volume where the offline content will be stored
 * `docker run --rm -itv /tmp/html/fedora:/mnt/fedora tschloss/repobuilder:fedora dnf download --resolve <package_name>`
 * `docker run --rm -itv /tmp/html/fedora:/mnt/fedora tschloss/repobuilder:fedora createrepo_c /mnt/fedora`
* tschloss/repobuilder:centos
 * CentOS 7 based docker image with tools installed for creating offline CentOS repo.
 * Run docker with volume where the offline content will be stored
 * `docker run --rm -itv /tmp/html/centos:/mnt/centos tschloss/repobuilder:centos yumdownloader -y --resolve --destdir=/mnt/centos <package_name>`
 * `docker run --rm -itv /tmp/html/centos:/mnt/centos tschloss/repobuilder:centos createrepo /mnt/centos`
