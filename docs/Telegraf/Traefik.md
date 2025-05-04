## Traefik
This is not via automation since traefik can be configured in a variety of ways.
The examples I am using are using the a yaml config file.
For other methods for collecting metrics read the [Traefik docs](https://doc.traefik.io/traefik/observability/metrics/influxdb/_)


### Prometheus
Add the following to your traefik config 
```
# expose the metrics endpoint
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
# Format the access logs as JSON this will provide more context about each request and make logs easier to parse by default traefik logs in Common Log Format like Apache or Nginx.
accessLog:
  format: json
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
