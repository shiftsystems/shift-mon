# Install Telegraf on OPNSense
1. Login to your firewall and from the lefthand side go to System > Firmware > Plugins
2. click the + button by os-telegraf
3. go to Servies > Telegraf > Input from the menu on the left side
4. enable the following plugins and hit Save
  * CPU
  * Total CPU
  * Disk
  * type /dev and press enter into Disk Ignore FS
  * DiskIO
  * Memory
  * System
  * Network
  * Intrusion Detection Alerts
5. Make sure all outputs are disabled. They will be added in manually in the next step. The telegraf plugin doesn't support routing metrics and logs to different datasources in the out so the outputs will be placed in a separate config file.
7. To restart Telegraf go to Lobby Dashboard in the man menu and click the refresh icon in the services panel. If you have removed this panel go to System > Diagnostics > Services and click the refresh button
8. Go to Grafana and confirm that your firewall is sending metrics

## But what about logs

1. SSH into your opnsense box and enter a shell (option 8 from the menu)
2. open a new file in the telegraf extra configs folder by running ```vi /usr/local/etc/telegraf.d/shiftmon.conf```
3. add the following content to the file 
```
[[outputs.http]]
  url = "https://logs.example.com/insert/jsonline?_msg_field=fields.message&_time_field=timestamp&_stream_fields=tags.appname,tags.host,tags.hostname,tags.event_type,tags.path,tags.resp_code,tags.severity,tags.Cached,tags.Upstream,tags.dest_port,tags.dest_ip,tags.src_ip,tags.src_port"
  data_format = "json"
  insecure_skip_verify = true
  use_batch_format = false
  namepass = ["suricata","syslog","tail*","exec*","resolver*","netflow*"]
  content_encoding = "gzip"
  [outputs.http.headers]
    Authorization = "Bearer loggy-mclog-face"
[[outputs.influxdb]]
  urls = ["https://metrics.local.shiftsystems.net"]
  database = "opnsense"
  retention_policy = ""
  write_consistency = "any"
  timeout = "10s"
  http_headers = {"Authorization" = "Bearer icky-vicky"}
  namedrop = ["suricata","syslog","tail*","exec*","resolver*"]
  insecure_skip_verify = true
[[inputs.syslog]]
  server = "udp://:6667"
  syslog_standard = "RFC5424"
[[inputs.exec]]
  commands = ["opnsense-version"]
  data_format = "grok"
  grok_patterns = ['''%{DATA:os} %{GREEDYDATA:version}''']
  name_suffix = "_opnsense_version"
  interval = "1m"
[[inputs.netflow]]
  service_address = "udp://127.0.0.1:2099"
  protocol = "netflow v9"
[[inputs.tail]]
  files = ["/var/log/crowdsec/*.log"]
  data_format = "logfmt"
  name_suffix = "_crowdsec"
[[inputs.tail]]
  files = ['''/var/log/caddy/*.log''']
  data_format = "json"
  json_string_fields = ["*"]
  json_strict = false
  name_suffix = "_caddy"
[[inputs.smart]]
  attributes = true
  enable_extensions = ["auto-on"]
[[processors.rename]]
  [[processors.rename.replace]]
    field = "msg"
    dest = "message"
    namepass = ["suricata","syslog","tail*","exec*","resolver*","netflow*"]
[[processors.defaults]]
  [processors.defaults.fields]
    message = "default message"
    namepass = ["suricata","syslog","tail*","exec*","resolver*","netflow*"]
# Uncomment if you are using tailscale
#[[inputs.prometheus]]
#  urls = ["http://100.100.100.100/metrics"]
#  metric_version = 2
# unccoment if you are using Caddy Reverse Proxy
#[[inputs.prometheus]]
#  urls = ["http://127.0.0.1:6060/metrics"]
#  metric_version = 2
```
4. Go to System > Settings > Logging / targets
5. add a target and set the following options
  * tick the enabled box
  * set transport to UDP(4)
  * select the levels you want to log
  * select the apps you want to log
  * select the Facilities you want to log
  * set the hostname to 127.0.0.1
  * set the port to 6667
6. click save then click apply. 
7. go to the OPNSense dashboard in Grafana and make sure the firewall and metric sure all panels contain data
