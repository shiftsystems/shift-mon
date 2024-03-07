## Traefik
This is not via automation since traefik can be configured in a variety of ways.
The examples I am using are using the a yaml config file.
For other methods for collecting metrics read the [Traefik docs](https://doc.traefik.io/traefik/observability/metrics/influxdb/_)


### Prometheus
Add the following to your traefik config 
```
metrics:
  prometheus:
    entrypoint: metrics
    buckets:
      - 0.1
      - 0.3
      - 1.2
      - 5.0
    addRoutersLabels: true
    addServicesLabels: true
```
You will also need to create a separate metrics entrypoint
```
entryPoints:
  metrics:
    address: ":8082"
```
You will also need to map port 8082 to localhost on your container in docker/podman if you are using compose your ports section will look like this
```
ports:
  - "80:80"
  - 443:443"
  - "127.0.0.1:8082:8082"

```
finally define `telegraf_traefik_metric_url: 'http://127.0.0.1:8082'` in the inventory for the host you want to collect traefik metrics from

### Via Influx DB (only works with Traefik v2 using this config will prevent traefik from starting)
Add the following to your traefik config to collect metrics changing to the host and address to lines to match your metrics server and docker hostname.
set the protocol to `http` and add `:8428` to your address if you need to ship metrics over plain text http without auth.
```
metrics:
  influxDB:
    address: metrics.local.example.com
    protocol: https
    database: linux
    addRoutersLabels: true
    addServicesLabels: true
```

Setup the Access log For Traefik if you want to collect access logs.
Change the filePath to a directory mapped to a volume to telegraf can see it.
Setup log rotate on this file to avoid filling your hard drive
```
accessLog:
  filePath: '/etc/traefik/access.json'
  format: json
```

Add the following to /etc/telegraf/telegraf.d/traefik.conf to read the logs and change the files to to point to the volume were your access log is stored.
If you are having permissions issues reading the file you can set `telegraf_root: true` for that host in your inventory and redeploy Telegraf.
Note doing this is running will set telegraf to run as root on your system which lets it see everything and do everything which is a security risk.
You can also set permissions for your container which is more secure but more time consuming.

```toml
[[inputs.tail]]
  name_suffix = "_traefik"
  files = ['''/var/log/traefik/access.*''']
  data_format = "json"
  json_string_fields = ["*"]
# optional adds reverse DNS lookup for ip addresses
[[processors.reverse_dns]]
  namepass = ["tail_traefik"]
  [[processors.reverse_dns.lookup]]
    field = "ClientHost"
    dest = "ReverseLookup"
```