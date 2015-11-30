# Demo2
This second demo aims to provide more complex scenario that requires a structured Ansible playbook and numerous options in inventory file.

## Preparing the demo
You need one machine with SSH installed with a user account you can login to via ssh. You should have Python 2.4 or higher installed on the machine. You also need to have an inventory file (in following examples referred to as `hosts`). For this example, it only has to contain a line with your machine's IP address or domain name (if it is resolvable).

If you don't have access to such a machine, you can use provided `start-demo.sh` script that will create a docker container with Fedora 23 for you
that has everything set up and prepared. If you want to use this option, please, follow the [readme in the root of the repository](https://github.com/tomason/ansible-demo/blob/master/README.md) on how to set up
your own environment (build docker images, set up HTTP server etc.). The setup script creates the inventory file named `hosts` for you .

## Ansible playbook
Ansible playbook is a set of files describing desired state of the system after running the ansible command. It should be idempotent - if no changes are required, no changes should be done. For simple playbooks, the tasks can be listed all in one YAML file. However for complex tasks, it is desirable to split this file into more files for better readability and maintanence. The directory structure for playbooks is following:
```
playbook.yaml
roles/
|- role-name/
|  |- tasks/
|  |  \- main.yaml
|  |- files/
|  |- templates/
|  |- handlers/
|  |- vars/
|  |- defaults/
|  \- meta/
\- role2/
   \- tasks/
      \- main.yaml
```

## Demo overview
Ansible playbook in this demo is designed to install a Wildfly 9 server and configure it in the domain mode. For this demo to have any meaning, at least two machines are required - domain controller and domain member that will run the server(s). This playbook is idempotent, so reruning it several times will not have any effect (unless you change the configuration between runs).

### Installing Wildfly
The playbook uses same commands as the one in demo1 to install OpenJDK on the machine and then download and unzip Wildfly. This is done in `install-wildfly` role. Note that the `unarchive` module has `creates` argument defined. This prevents reruning the unzip command every time.

### Setting up the master
The second step in the playbook is configuring the master. First the `host.xml` file is created with role `create-host-xml` and then management users are added for every node in the cluster.

The role for creating the `host.xml` file is parameterized - it expects to receive the name of the template to use. For master, the `host-master-xml.j2` template file is used. However there is no configuration necessary on master (apart from what is already present in the template). The template module is used so the `create-host-xml` role can be reused. After creating the configuration file, the `set_fact` module is used if the template has changed. This way the server picks up the changes that were made.

The other role takes care of creating management users for the nodes authentication. This requires setting `node_username` and `node_password` variables to every machine in nodes group. To avoid recreating users every time, the second task searches the existing users and only missing users are added.

### Setting up the nodes
There is only one role in this step - `create-host-xml` parametrized with `host-node-xml.j2` template file. This is proper template file, it creates host.xml according to settings for the node. It sets the node name, password used for node authentication, master address and number of servers to provide. All these settings are read from inventory file properties: `node_name`, `node_username`, `node_password` and `node_servers`. If any changes are made to the node configuration, the node is mared with `node_restart` property to indicate the node should be restarted to pick the changes from configuration file.

### (Re)Starting Wildfly
Last step in the playbook takes all the nodes that have configuration changed and stops the running server. Then every machine that was marked for restart or doesn't have Wildfly server running starts the new Wildfly server.

### Demo inventory
If you are using the `./start-demo.sh` script, the inventory file is generated for you and looks similar to this:
```
[master]
172.17.0.26  node_username=admin

[nodes]
172.17.0.27  node_servers=1  node_username=node1  node_password=node1password!
172.17.0.28  node_servers=1  node_username=node2  node_password=node2password!
```
The machines are split into two groups - `master` (single machine - domain controller) and `nodes`. These groups represent the roles that the machines will play in the infrastructure. You can also see the settings mentioned before for each machine.

## What to do with the demo
Here are a few examples of what this demo can do with simple modifications.

### Run the playbook
Jus issue the `ansible-playbook -i hosts domain.yml` and watch the progress of the settings. You can visit the `http://<master-address>:9990` to see the management console and see in _Runtime_ tab that the other two machines are connected and running one server each. Use one of the node users to login to the management console.

### Create user for management console
By modifying the inventory file and reruning the playbook, you can get the admin user with access to Management console (no need to use node user any more).
```
[master]
172.17.0.26  node_username=admin  node_password=admin123;
```

### Change the number of servers running on the node
By modifying the inventory file and reruning the playbook, you can have more servers running on one node (mind the limits of the hardware though).
```
[nodes]
172.17.0.27  node_servers=2  node_username=node1  node_password=node1password!
```

### Bring in more machines
Run the `add-machines.sh` script. This will add two more machines into the inventory and after reruning the playbook, you can check the management console for new machines.
```
[nodes]
172.17.0.27  node_servers=1  node_username=node1  node_password=node1password!
172.17.0.28  node_servers=1  node_username=node2  node_password=node2password!
172.17.0.29  node_servers=1  node_username=node3  node_password=password3!
172.17.0.30  node_servers=1  node_username=node4  node_password=node4pwd!
```

### Share configuration between nodes
If you wan to have the same user for all nodes or set number of servers globally, you can use variables in inventory file. Then just rerun the playbook and you get new settings. It is possible to override common settings with settings on every machine. Also remember that every node has to have distinct node name.
```
[nodes]
172.17.0.27  node_name=node1
172.17.0.28  node_name=supernode  node_servers=2

[nodes:vars]
node_servers=1
node_username=node-user
node_password=nodePassw0rd;
```
