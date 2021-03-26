# Adding telegraf to proxmox
This document requires you have a token with write permission to the proxmox bucket. 
If you need help getting a token follow the [Influxdb Documentation](https://docs.influxdata.com/influxdb/cloud/security/tokens/create-token/)

## Adding a metric server in proxmox
1. login to proxmox with the root account
2. click on Datacenter
3. click on the Metric Server submenu
4. Click add -> influxdb and fill out the settings below
* name:
* server: thee hostname of your influxdb server
* port: 443
* orginaztion: shiftsystems
* bucket: proxmox
* token: the token with write permission to the proxmox bucket. 