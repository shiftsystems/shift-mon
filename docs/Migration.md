# Migrating from legacy setup to Containers
At this time we don't support migrating in place and you will need to setup a new server.
Migrating Victoriametrics data can be done at any time using vmctl, but loki and grafana will require that they are stopped to copy data.

## Victoriametrics
This needs run after the new server is deployed

1. Download the latest version of vmutils from [their github](https://github.com/VictoriaMetrics/VictoriaMetrics/releases) and extract the archive
2. cd into the folder created by extracting the archive
3. run the following command with your particulars filled out
```
./vmctl-prod vm-native --vm-native-src-user <old_user> --vm-native-src-password <old_password> --vm-native-src-addr=https://<old_metrics_url> --vm-native-src-user <new_user> --vm-native-src-password <new_password> --vm-native-dst-addr=https://<metrics_url> --vm-native-filter-match='{db="linux"}' --vm-native-filter-time-start='2020-01-01T20:07:00Z'
```
4. replace linux in the above command with each database or replace it a valid promql label filter.

## Loki
This needs done before Deploying the new instance of Shift-mon. This will overwrite or courrupt loki if you already have it configured
1. Stop loki on the old server by running ```sudo systemctl stop loki```
1. configure you ansible inventory for the new server
2. run the loki role on the new server to create the directories by running ```ansible-playbook -i your_inventory loki.yml --ask-become-pass```
3. copy all of /opt/loki from the old server to /opt/shift-mon/loki on the new server using sftp or scp
all your logs have been copied and should appear when you run shift mon role on your server

## Grafana
This needs done before Deploying the new instance of Shift-mon. This will overwrite or courrupt grafana if you already have it configured
1. Stop Grafana on the old server ```sudo systemctl stop grafana-server```
2. run the grafana role on the new server to create the directories by running ```ansible-playbook -i your_inventory grafana.yml --ask-become-pass```
3. Copy the grafana sqlite database in ```/var/lib/grafana/grafana.db``` folder from the old server to your home folder and make yourself the owner```sudo cp /var/lib/grafan
4. copy it over to ```/opt/shift-mon/grafana/grafana.db``` on the new server
5. set the permissions on the grafana database by running ```sudo chown 472:root /opt/shift-mon/grafana/grafana.db && sudo chmod 640 /opt/shift-mon/grafana/grafana.db```
6. install shift-mon as normal and any custom data you added to grafana should be there.

all your grafana info has been copied over and you can run the through shift-mon install as normal.
