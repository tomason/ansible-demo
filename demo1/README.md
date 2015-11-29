# Demo1
This first demo is intended to introduce you to the ansible ad-hoc commands and show the basics of the Ansible playbooks.
For these purposes, you have a single machine that has ssh installed and set up.
You should use root user to connect to the server and can try some of the following commands.

## Preparing the demo
You need one machine with SSH installed with a user account you can login to via ssh. You should have Python 2.4 or higher installed on the machine. You also need to have an inventory file (in following examples referred to as `hosts`). For this example, it only has to contain a line with your machine's IP address or domain name (if it is resolvable).

If you don't have access to such a machine, you can use provided `start-demo.sh` script that will create a docker container with Fedora 23 for you
that has everything set up and prepared. If you want to use this option, please, follow the [readme in the root of the repository](https://github.com/tomason/ansible-demo/blob/master/README.md) on how to set up
your own environment (build docker images, set up HTTP server etc.). The setup script creates the inventory file named `hosts` for you .

## Ansible ad-hoc commands
### Ansible command structure
All commands in this document follow the same structure:

`ansible <host-pattern> [options] -m <module> [-a <arguments>]`

You can find a list of modules (for `-m` parameter) together with their required arguments
(for `-a` parameter) in [Ansible documentation](http://docs.ansible.com/ansible/modules_by_category.html).

Most notable options are
```
-i <filename>    Path to inventory (otherwise default is used - /etc/ansible/hosts)
-u <username>    Username to use for ssh connection
```

### Example commands
Print the facts about all the machines in the inventory:

`ansible all -i hosts -u root -m setup`

Ping every machine in the inventory:

`ansible all -i hosts -u root -m ping`

Install java on all machines in inventory:

`ansible all -i hosts -u root -m dnf -a 'name=java-1.8.0-openjdk-devel state=present'`

Download zip file from the internet to every machine in inventory:

`ansible all -i hosts -u root -m get_url -a 'url=http://webserver/wildfly9.zip dest=/tmp/wildfly9.zip'`

Unzip the file on all machines:

`ansible all -i hosts -u root -m unarchive -a 'src=/tmp/wildfly9.zip dest=/opt copy=no'`

Execute shell command on all machines in inventory (shell module is the default):

`ansible all -i hosts -u root -a 'nohup /opt/wildfly-9.0.2.Final/bin/standalone.sh -b 0.0.0.0 &'`


## Basic playbooks
Though the ad-hoc commands can do a lot, sometimes there are more complex tasks that require multiple commands to be
issued in correct order. For these use-cases, you can use simple playbooks - a YAML file that contains all the information
that you would pass through the commad line:

### Basic playbook format
```YAML
---
- hosts: <host-pattern>
  remote_user: <Username to use for ssh connection>
  tasks:
    - name: Install java through dnf
      dnf: name=java-1.8.0-openjdk-devel state=present
```

There is a sample playbook already present in the reposiory: `standalone.yaml`.
This playbook will install OpenJDK on the machine, download, unzip and start Wildfly in standalone mode.
> Warning: This playbook is not idempotent, rereuning it will try to start new Wildfly server.
