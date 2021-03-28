# Linux Install
Currently on Linux We recomend using our Ansible role, but there is also a shell script availble if you are not able to use ansible.
Currently we support Debian 10, Ubuntu 18.04 and newer, Fedora, and Redhat based distributions.
You will also need a token with write permissons to the linux bucket.
Follow the [Influxdb Docs](https://docs.influxdata.com/influxdb/cloud/security/tokens/create-token/) for getting a token if you need help

## Ansible
The only thing that is required is that SSH needs to accessible on all endpoints and you have a Linux machine withansible and git installed. 
Ansible can be installed by following [the Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems) and git can be installed from your Linux distribution's repository.

### What does the script/role do? 
* Places connection info your influxdb in /etc/default/telegraf
* Adds code signing keys and repos from influxdata
* Install the telegraf agent
* Edits config files in /etc/telegraf/

### setting up your inventory 
You will need the following in your Ansible inventory. The default inventory is in ```/etc/ansible/hosts```. 
We use a YAML inventory so if you are using an ini inventory then you should keep a separate inventory for Shift-RMM. 
you will need the following lines under vars
```
  vars:
    ansible_python_interpreter: /usr/bin/python3
    influxdb2:
      bucket: linux
      org: shiftsystems
      token: GET_YOUR_OWN_TOKEN_FROM_YOUR_INFLUXDB_DATABASE
      url: http://example.com

```

You will also want to keep hosts or IP addressesone per line with a colon at the end. As shown in the example belwo

```
hosts:
  zoe:
  eren:
  erwin:
  10.0.0.2:
```
an example inventory will look like this 

```
all:
  hosts:
    zoe:
    eren:
    erwin:
  vars:
    ansible_python_interpreter: /usr/bin/python3
    influxdb2:
      bucket: linux
      org: shiftsystems
      token: GET_YOUR_OWN_TOKEN_FROM_YOUR_INFLUXDB_DATABASE
      url: https://influx.example.com

```
### Cloning the repo and running the ansible role
next clone the repo by running the following command ``` git clonehttps://gitlab.com/shiftsystems/shift-rmm.git ```.
Before deploy the role make sure you are in the shift-rmm repo, and you have run ```git pull`` so you are running the latest version of the role. 
To deploy the role using the default inventory run ```ansible-playbook telegraf.yml --ask-become-pass``` you will prompted for you sudo password for the those machines.
If you are using separate sudo passwords on each machine then you can use the -l <hostname> to run it on a single host. If you are logging on to the server with a different user use the -u <username> flag. Ex ```ansible-playbook -l zoe -u tom telegraf.yml --ask-become-pass```
If you are running into issues with SSH and ansible follow [the Ansible docs](https://docs.ansible.com/ansible/latest/user_guide/connection_details.html)

## Bash Script
The Bash script assumes that wget is installed, curl is installed, you are running it as root or as sudo with root permissions, and you can access gitlab.com. You can upload the script from [here](https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/scripts/linux/telegraf-install.bash) to meshcentral and push it from meshcentral or download the script run ```wget https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/scripts/linux/telegraf-install.bash```. Next you have to edit the following variables in the first few lines of the script to match your settings
```
INFLUXDB_URL="https://test.example.com"
TELEGRAF_TOKEN="GET_YOUR_OWN_TOKEN"
```
To run the script run ```sudo bash telegraf-install.bash``` or ```bash telegraf-install.bash``` if you are logged in as root.
