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
The only thing that is required is that SSH needs to accessible on all endpoints and you have a Linux machine with ansible and git installed. 
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
