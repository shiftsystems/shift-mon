# Linux Install
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
The only thing that is required is that SSH needs to accessible on all endpoints and you have a Linux machine with ansible and git installed. 
Ansible can be installed by following [the Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems) and git can be installed from your Linux distribution's repository.

### What does the role do? 
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

### Adding Your Own Telegraf Configs
Shiftmon supports user provided Telegraf configs by defining them in their ansible inventory and copying them to `/etc/telegraf/telegraf.d/`.
The filename and local location for the config file are defined in a dictionary named `telegraf_config_paths`.
The key of the dictionary is the filenmae and value of the dictionary is where the configuration is stored on the ansible controller.
The inventory
```yaml
all:
  hosts:
    localhost:
  vars:
   telegraf_config_paths:
     gitea: "{{playbook_dir}}/telegraf-configs/gitea.conf"
```
Will copy the contents of the gitea.conf in the telegraf-configs on the Ansible Controller to `/etc/telegraf/telegraf.d/gitea.conf` and trigger telegraf to restart if that file is updated.
To apply this config only a single host you would use an inventory where `telegraf_config_paths` is defined under the host

```yaml
all:
  hosts:
    localhost:
      telegraf_config_pathas:
        gitea: "{{playbook_dir}}/telegraf-configs/gitea.conf"
```

### Per Process Configuration
Shiftmon allows users to collect metrics from specified processes from based on the user, systemd units, or a pattern via the [procstat Telegraf plugin](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/procstat).
By default no per process metrics are collected.
To add per process metrics define the processes variable with 1 or more of the following variables containing a list.
* systemd_units
* users
* patterns

Below are some are a couple of examples for defining processes for a single host or across your whole fleet.

#### Collecting Metrics for all hosts
```yaml
all:
  hosts:
    host1:
    host2:
  vars:
    processes:
      systemd_units:
        - "telegraf.service"
        - "mongod.service"
      patterns:
        - ".*omada*"
        - ".*tplink.*"
      users:
        - "telegraf"
```
#### Collecting process metrics for a single host
```yaml
all:
  hosts:
    no-proc.example.com:
    process.example.com:
      processes:
        systemd_units:
          - "telegraf.service"
          - "mongod.service"
        patterns:
          - ".*omada*"
          - ".*tplink.*"
        users:
          - "telegraf"
```