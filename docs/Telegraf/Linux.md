# Linux Install
Currently on Linux We recomend using our Ansible role, but there is also a shell script availble if you are not able to use ansible.
Currently we support Debian 10 or newer, Ubuntu 18.04 and newer, Fedora, and Redhat based distributions.
The ansible role will detect if the following systemd services exist and will deploy telegraf configs for the services listed below.
* mysql
* nginx
* php-fpm
* crowdsec
* meshcentral
* adgaurd home
* docker
* syslog (requires ```syslog: true``` in ansible variables)

There is no support for this in the bash script but we take pull requests.
The configs can be added manually by adding one of the configs in the [telegraf configs folder](../../telegraf-configs/linux) in ```/etc/telegraf/telegraf.d/```

## Ansible
The only thing that is required is that SSH needs to accessible on all endpoints and you have a Linux machine withansible and git installed. 
Ansible can be installed by following [the Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems) and git can be installed from your Linux distribution's repository.

### What does the script/role do? 
* Places connection info for Victoriametrics and Loki in /etc/default/telegraf
* Adds code signing keys and repos from influxdata
* Install the telegraf agent
* Edits config files in /etc/telegraf/
* Can install syslog if ```syslog: true``` is an ansible variable

### setting up your inventory 
You will need the following in your Ansible inventory. The default inventory is in ```/etc/ansible/hosts```. 
We use a YAML inventory so if you are using an ini inventory then you should keep a separate inventory for Shift-RMM. 
you will need the following lines under vars
```
  vars:
    ansible_python_interpreter: /usr/bin/python3
    #metric_batch_size: 1000 # uncomment and increase if telegraf is not sending all data
    #metric_buffer_size: 10000 # uncomment and increase if telegraf is not sending all data
    loki:
      url: 'http://armin.local.mathiasp.me:3100'
      #user: 'test' # optional if you have setup auth for loki
      #password: 'test' # optional if you have setup auth for loki
    victoria:
      url: 'http://armin.local.mathiasp.me:8428'
      #user: 'test' # optional if you have auth setup for victoriametrics
      #password: 'test' # optional if you have auth setup for victoriametrics

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
    #set to true if you want telegraf to forward syslog to loki this will install rsyslog and telegraf will listen on tcp port 6667
    syslog: false 
    loki:
      url: 'http://armin.local.mathiasp.me:3100'
      #user: 'test' # optional if you have setup auth for loki
      #password: 'test' # optional if you have setup auth for loki
    victoria:
      url: 'http://armin.local.mathiasp.me:8428'
      #user: 'test' # optional if you have auth setup for victoriametrics
      #password: 'test' # optional if you have auth setup for victoriametrics

```
### Cloning the repo and running the ansible role
next clone the repo by running the following command ``` git clone https://gitlab.com/shiftsystems/shift-rmm.git ```.
Before deploy the role make sure you are in the shift-rmm repo, and you have run ```git pull`` so you are running the latest version of the role. 
To deploy the role using the default inventory run ```ansible-playbook telegraf.yml --ask-become-pass``` you will prompted for you sudo password for the those machines.
If you are using separate sudo passwords on each machine then you can use the -l <hostname> to run it on a single host. If you are logging on to the server with a different user use the -u <username> flag. Ex ```ansible-playbook -l zoe -u tom telegraf.yml --ask-become-pass```
If you are running into issues with SSH and ansible follow [the Ansible docs](https://docs.ansible.com/ansible/latest/user_guide/connection_details.html)

## Bash Script
The Bash script assumes that wget is installed, curl is installed, you are running it as root or as sudo with root permissions, and you can access gitlab.com. You can upload the script from [here](https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/scripts/linux/telegraf-install.bash) to meshcentral and push it from meshcentral or download the script run ```wget https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/scripts/linux/telegraf-install.bash```. Next you have to edit the following variables in the first few lines of the script to match your settings
```
VICTORIA_URL="https://metrics.example.com"
LOKI_URL="https://logs.example.com"
VICTORIA_USER="test"
VICTOIRA_PASS="test"
LOKI_USER="test"
LOKI_PASS="test"
```
To run the script run ```sudo bash telegraf-install.bash``` or ```bash telegraf-install.bash``` if you are logged in as root.

## Remote Syslog
For devices that generate syslog data but can't have telegraf installed you can configure an instance of telegraf to receive syslog data by setting ```remote_syslog: true``` for one or more hosts in your inventory.
After remote syslog has been setup on one of your installations of telegraf you can forward RFC5424 formatted syslog to the ip or host of the telegraf instance on udp port 6666
Below is the additional configure config file you to place in ```/etc/rsyslog.d/50-telegraf.conf``` to setup syslog forwarding for rsyslog and other syslog daemons and forwarders will be documented as they are tested.
Please replace ```<telegraf_ip_or_host>``` with ip or host of the telegraf instance configured to receive remote syslog
```
$ActionQueueType LinkedList
$ActionQueueFileName srvrfwd
$ActionResumeRetryCount -1
$ActionQueueSaveOnShutdown on

*.* @<telegraf_ip_or_host>:6666;RSYSLOG_SyslogProtocol23Format

```