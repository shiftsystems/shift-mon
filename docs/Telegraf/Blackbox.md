# Blackbox Monitoring
The Telegraf role supports configuring HTTP, DNS, TCP, and ping checks by configuring Ansible Variables.
The same check can be setup to run from multiple locations in order to track metrics across locations and for tracking metrics if a location is down.

## HTTPS
This plugin will track if a domain is accessible, what response code it returns, and fail a check if the incorrect string is retruned
This also will gather full chain cert information including OSCP, who issued the cert, and the expiration date

### Options
* url (required): the url to check
* check_name (optional): label to be added to give a human readable name for a check
* interval (optional): how often the check should occur defaults to 1m (one minute)
* timeout (optional): how long to wait before failing the check due to taking to long defaults to 30s (30 seconds)
* expected_status_code (optional int): HTTP status code request should return defaults to 200
* method (optional): which HTTP verb to use defaults to get
* basic_user (optional): HTTP basic username
* basic_password (optional): HTTP basic password
* response_string(optional): string that the http request should return
* insecure_skip_verify(optional): check if the SSL cert is valid defaults to `'false'` set to `'true'` if you want to ignore cert validity. The way toml in telegraf configs expects a lower case true and ansible booleans start with a capitial letter.
### Example Inventory
```yaml
all:
  hosts:
    erwin:
  vars:
    blackbox_https_urls:
      - url: 'https://loki.example.com/ready'
        check_name: 'Loki'
        basic_user: '$victoria_user'
        basic_password: '$victoria_password'
        response_string: 'ready'
        interval: '5m'
```

## DNS
Gather info if a record can or cannot be resolved.
This can be also be used to see if DNS filtering is working.

### Options
* server (required): the dns server to use
* domain (required): the domain to query
* check_name (optional): label to be added to give a human readable name for a check
* interval (optional): how often the check should occur defaults to 1m (one minute)
* timeout (optional): how long to wait before failing the check due to taking to long defaults to 5s (5 seconds)
* record_type (optional): DNS record type to use defaults to A

### Example
```yaml
all:
  hosts:
    erwin:
  vars:
    blackbox_dns_queries:
      - server: 10.0.0.254
        check_name: 'local DNS'
        domain: 'example.local.com'
```

## Net Response (TCP or UDP)
checks to see if a port responds. Currently doesn't support UDP since UDP requires a response string but this will be added in a future release

### Options
* host (required): ip or hostname used in the check
* port (required): port to check
* protocol (optional): either tcp or udp defaults to tcp
* read_timeout (optional): how long to wait while reading before timing out and failing the check
* send_string (optional): host to send to the TCP port
* expected_string(required for udp): string that request should return
* check_name (optional): label to be added to give a human readable name for a check
* interval (optional): how often the check should occur defaults to 1m (one minute)
* timeout (optional): how long to wait before failing the check due to taking to long to respond defaults to 5s (5 seconds)

### Example
```yaml
all:
  hosts:
    erwin:
  vars:
    blackbox_net_hosts:
      - host: dc1.local.example.com
        port: 389
      - host: dc2.local.example.com
        port: 389
        interval: '5m'

```

## Ping
Send an ICMP ping request to a host. I would reccomend that use something closer mimics if a service is unavailable but sometimes ping is the best or only option

### Options
* host (required): ip or hostname to ping
* count (optional int): number of ping requests to send defaults to 1
* deadline (optional int): behaves like -w option in ping command defaults to 1
* check_name (optional): label to be added to give a human readable name for a check
* interval (optional): how often the check should occur defaults to 1m (one minute)
* timeout (optional): how long to wait before failing the check due to taking to long to respond defaults to 5s (5 seconds)
### Example
```yaml
all:
  hosts:
    erwin:
  vars:
    blackbox_ping_hosts:
      - host: host1.local.example
        timeout: '10s'
```

## All together

```yaml
all:
  hosts:
    erwin:
  vars:
    loki:
      user: telegraf
      password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
      url: "{{ lookup('env', 'LOKI_URL') }}"
    victoria:
      user: telegraf
      password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
      url: "{{ lookup('env', 'VICTORIA_URL') }}"
    blackbox_https_urls:
      - url: 'https://grafana.local.example.com/login'
        check_name: 'Grafana'
# 3XX redirect
      - url: 'https://vpn.example.com/admin'
        check_name: 'HeadScale UI'
        expected_status_code: 308
      - url: 'https://matrix.org/_matrix/federation/v1/version'
        check_name: 'Matrix'
# Use basic auth with telegraf secrets
      - url: 'https://metrics.local.example'
        check_name: 'Victoriametrics'
        basic_user: '$victoria_user'
        basic_password: '$victoria_password'
    blackbox_dns_queries:
      - server: 10.0.0.254
        check_name: 'local DNS'
        domain: 'example.local.com'
      - server: 10.99.0.2
        domain: 'malware.com'
        check_name: 'Unsafe Domain'
        domain: 'www.example.com'
        record_type: 'CNAME'
        timeout: '10s'
    blackbox_ping_hosts:
      - host: 1.1.1.1
        check_name: 'Cloudflare'
    blackbox_net_hosts:
      - host: dc1.local.example.com
        port: 389
      - host: dc2.local.example.com
        port: 389
```
