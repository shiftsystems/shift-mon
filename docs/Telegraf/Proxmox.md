# Adding a Metric Server in Proxmox

## Using Ansible
This is assuming you have ssh access as root with an SSH key to the PVE and PBS servers in the inventory.

## WARNING FOR PROXMOX BACKUP SERVER (PBS) THIS WILL OVERRIDE EXISTING METRIC SERVER SETTINGS
As far as I can tell PBS's metric server config doesn't support comments so we the ansible role will override the file instead of using blockinfile which perserves the config

### Inventory
Create an inventory named `pve-inventory.yml` with the following content with the hosts and variables adjusted to suit your environment
```yaml
all:
  hosts:
    10.0.0.2:
    10.0.0.3:
    10.0.0.4:
  vars:
    syslog_host: "logs.example.com"
    metrics_host: "metrics.example.com"
    metrics_token: "muh-token"
    ansible_user: "root"
```

### Playbook
Create a playbook named `instrument-pve.yml` with following content
```yaml
- hosts: all
  tasks:
    - ansible.builtin.include_role:
        name: pve_instrumentation
```

### Running the play
run the following command. note you might need to adjust the path if you used a different name or folder than what was listed above

```bash
ansible-playbook -i ../pve-inventory.yml instrument-pve.yml
```

## Add Metrics Manually in Proxmox Virtual Environment (PVE)
Due to how Proxmox sends metrics, and how shiftmon handles authentication currently we do not support pushing metrics to shiftmon from proxmox over TLS at this time
1. login to Proxmox with an account administrative privileges 
2. click on Datacenter
3. click on the Metric Server submenu
4. Click add -> influxdb and fill out the settings below
  * Name: shiftmon
  * Server: the fqdn of the Victoriametrics server
  * Protocol: HTTPS
  * Port: 443
  * Organization: set it to `proxmox`, but this field is not used since we are using the InfluxDBv1 endpoint in Victoriametrics which ignores the organization field
  * bucket: set it to `proxmox`, but this field is not used since we are using the InfluxDBv1 endpoint in Victoriametrics which ignores the bucket field
  * token: set to a valid token for your Victoriametrics instance.
5. hit create or ok.

## Add Metrics Manually in Proxmox Backup Server (PBS)
1. login to Proxmox Backup Server with an account with administrative privileges
2. click on Configuration in left side of the scree
3. click on the Metric Server submenu
4. Click add -> InfluxDB (HTTP) and fill out the settings below
  * Name: shiftmon
  * URL: `https://<your_victoriametrics_url>`
  * Organization: set it to `proxmox`, but this field is not used since we are using the InfluxDBv1 endpoint in Victoriametrics which ignores the organization field
  * bucket: set it to `proxmox`, but this field is not used since we are using the InfluxDBv1 endpoint in Victoriametrics which ignores the bucket field
  * token: Set to a valid token for your Victoriametrics instance.
5. hit create or ok.

## Adding Syslog to Proxmox Manually
Proxmox VE does not have syslog forwarding built in by default.
Luckily Proxmox is built on Debian so we can install rsyslog from the debian repo and configure it to forward logs to shiftmon.
This assumes telegraf has been configured with shiftmon ansible role with `remote_syslog: true` on a box that the proxmox host(s) can access on udp port 6666.
If there is a firewall on the on the syslog server please make sure that port 6666 is open.

### Configuring Proxmox 
Note these steps will need to be performed on each proxmox host, and we do not have a method for forwarding syslog over TLS at this time.
1. SSH into the proxmox node. By default you can ssh in as root to a proxmox node using the root password you use to sign into the web interface
1. Install Rsyslog `apt -y install rsyslog`
2. Add the following contents to `/etc/rsyslog.d/50-shiftmon.conf` with the ip address swapped out for the telegraf instance with `remote_syslog: true`

For Proxmox Virtual Environment PVE
```
# Enable imfile module
module(load="imfile")

# Forward syslog to Telegraf
*.* action(type="omfwd" Target="10.0.0.8" Port="6666" Protocol="udp" Template="RSYSLOG_SyslogProtocol23Format")

# Scrape Proxmox Access Log
input(type="imfile" File="/var/log/pveproxy/access.log" Tag="pve-access" Severity="info" Facility="local7")
input(type="imfile" File="/var/log/pveam.log" Tag="pveam" Severity="info" Facility="local7")
input(type="imfile" File="/var/log/pve-firewall.log" Tag="pve-firewall" Severity="info" Facility="local7")

```
For Proxmox Backup Server (PBS)
```
# Enable imfile module
module(load="imfile")

# Forward syslog to Telegraf
*.* action(type="omfwd" Target="logs.local.shiftsystems.net" Port="6666" Protocol="udp" Template="RSYSLOG_SyslogProtocol23Format")

#scrape Proxmox Logs
input(type="imfile" File="/var/log/proxmox-backup/tasks/archive" Tag="pbs-archive" Severity="info" Facility="local7")
input(type="imfile" File="/var/log/proxmox-backup/tasks/active" Tag="pbs-active" Severity="info" Facility="local7")

```

3. Restart rsyslog `systemctl restart rsyslog`
4. Confirm that logs are flowing by checking out the Proxmox Dashboard in your shiftmon instance.

