# Migrating from legacy setup to Containers
At this time we don't support migrating in place and you will need to setup a new server.
Migrating Victoriametrics data can be done at any time using vmctl, but loki and grafana will require that they are stopped to copy data.

## Victoriametrics
This needs run after the new server is deployed

1. login to your old server and ```cd /opt/victoriametrics```
2. run the following command with your particulars filled out 
```
./vmctl-prod vm-native --vm-native-src-addr=http://localhost:8428 --vm-native-dst-addr=https://<telegraf_user>:<telegraf_password>@<metrics_url> --vm-native-filter-match='{db="linux"}' --vm-native-filter-time-start='2020-01-01T20:07:00Z'
```

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
3. Copy all of the /var/lib/grafana folder from the old server to /opt/shift-mon/grafana
all your grafana info has been copied over and you can run the through shift-mon install as normal.