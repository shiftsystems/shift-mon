# Linux Install
Currently on Linux We recommend using our Ansible role, but there is also a shell script available if you are not able to use ansible.
Currently we support Debian 10 or newer, Ubuntu 18.04 and newer, Fedora, and Redhat based distributions.
The Ansible role will detect if the following systemd services exist and will deploy telegraf configs for the services listed below.
* MySQL
* Nginx
* PHP-FPM
* Crowdsec
* Meshcentral
* Adgaurdhome
* Docker
* Podman
* Syslog (requires ```syslog: true``` in ansible variables)
* Caddy
* Libvirt

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

### Setup 

Edit `~/shift-mon/telegraf.yml` to look like this or make a `telegraf.yml` in your existing automation repo.
Similar to the shift-mon role you can edit the lookups to be plain text values or can be populated from your secrets manager, but this is insecure since secrets are being stored in plain text.

```
- hosts: all
  tasks:
    - name: Set Telegraf Secrets
      ansible.builtin.set_fact:
        loki:
          user: telegraf
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          url: 'https://logs.local.shiftsystems.net'
        victoria:
          user: telegraf
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          url: 'https://metrics.local.shiftsystems.net'

    - name: Deploy Telegraf
      ansible.builtin.include_role:
        name: shiftsystems.shift_mon.telegraf
        public: true
```

Add Additional hosts to one line at a time ending with a colon in `~/shift-mon/inventory.yml` or existing inventory as seen the example below. Make Sure they are not under the shiftmon_servers block other wise the entire monitoring system will deployed to that endpoint.

```yaml
all:
  hosts:
    erwin:
    eren:
      metric_buffer_size: 10000
      metric_buffer_limit: 100000
    10.0.0.2:
      remote_syslog: true
    shiftmon_servers:
      server.local.example.com:

```

Once your Inventory is setup deploy Telegraf by running `ansible-galaxy collection install --force shiftsystems.shift_mon && ansible-playbook -i inventory.yml telegraf.yml --ask-become-pass` from `~/shift-mon`.
This Command will be different if you are adding this to an existing automation repo.

If you are using your own automation repo you will need to modify the `ansible-playbook` command.

## Bash Script please don't use unless you have to.
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