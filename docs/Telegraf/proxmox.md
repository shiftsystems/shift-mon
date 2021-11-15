# Adding a metric server in proxmox
1. login to proxmox with the root account
2. click on Datacenter
3. click on the Metric Server submenu
4. Click add -> influxdb and fill out the settings below
* name:
* server: thee hostname of your influxdb server
* port: 443 for nginx or 8428 without
* protocol: HTTPS for nginx HTTP if it is enabled
* orginaztion: Doesn't matter for influxdbv1
* bucket: proxmox
* token: username:password if authenication is enabled
5. hit create or ok.