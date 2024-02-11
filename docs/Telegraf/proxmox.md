# Adding a Metric Server in Proxmox
Due to how Proxmox sends metrics, and how shiftmon handles authentication currently we do not support pushing metrics to shiftmon from proxmox over TLS at this time
1. login to Proxmox with an account administrative privileges 
2. click on Datacenter
3. click on the Metric Server submenu
4. Click add -> influxdb and fill out the settings below
  * Name: shiftmon
  * Server: the hostname of your influxdb server
  * Protocol: HTTP
  * Port: 8428
  * Organization: set it to `proxmox`, but this field is not used since we are using the InfluxDBv1 endpoint in Victoriametrics which ignores the organization field
  * bucket: set it to `proxmox`, but this field is not used since we are using the InfluxDBv1 endpoint in Victoriametrics which ignores the bucket field
  * token: Leave blank for Unauthenticated metrics. For Authenticated metrics set the Token field to `username:password` where the username and password are any of the users you listed in your shift-mon inventory. 
5. hit create or ok.

## Adding Syslog to Proxmox
Proxmox VE does not have syslog forwarding built in by default.
Luckily Proxmox is built on Debian so we can install rsyslog from the debian repo and configure it to forward logs to shiftmon.
This assumes telegraf has been configured with shiftmon ansible role with `remote_syslog: true` on a box that the proxmox host(s) can access on udp port 6666.
If there is a firewall on the on the syslog server please make sure that port 6666 is open.

### Configuring Proxmox 
Note these steps will need to be performed on each proxmox host, and we do not have a method for forwarding syslog over TLS at this time.
1. SSH into the proxmox node. By default you can ssh in as root to a proxmox node using the root password you use to sign into the web interface
1. Install Rsyslog `apt -y install rsyslog`
2. Add the following contents to `/etc/rsyslog/50-shiftmon.conf` with the ip address swapped out for the telegraf instance with `remote_syslog: true`
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
3. Restart rsyslog `systemctl restart rsyslog`
4. Confirm that logs are flowing by checking out the Proxmox Dashboard in your shiftmon instance.