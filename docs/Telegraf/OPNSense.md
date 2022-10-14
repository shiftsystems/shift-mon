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
  * Intrusion Dection Alerts
5. go to Services > Telegraf > Output
6. Set the following settings and click save
  * Check the Enable Influx Output (Victoriametrics accepts metrics on the InfluxDBv1 api among others)
  * add your victoriametrics url to the Influx URL field
  * type opnsens in the database field
  * add a username and password if you have set one up
  * If you are using a self signed cert Click Dsiable SSL verification
7. To restart Telegraf go to Lobby Dashboard in the man menu and click the refresh icon in the services panel. If you have removed this panel go to System > Diagnostics > Services and click the refresh button
8. Go to grafana and confirm that your firewall is sending metrics

## But what about logs
at the time of writing there is no loki out put configuration for logs so you will have add the config to telegraf manually which requires SSH and shell access to the server. 
1. SSH into your opnsense box and enter a shell (option 8 from the menu), and can exit vi on freebsd
2. open a new file in the telegraf extra configs folder by running ```vi /usr/local/etc/telegraf.d/loki.conf```
3. add the following content to the file 
```
[[outputs.loki]]
  domain = "https://loki.example.com:3100"
  namepass = ["suricata","syslog","tail*","exec*","resolver*"]
[[inputs.syslog]]
  server = "udp://:6667"
  syslog_standard = "RFC5424"
[[inputs.exec]]
  commands = ["opnsense-version"]
  data_format = "grok"
  grok_patterns = ['''%{DATA:os} %{DATA:version} \(%{DATA:arch}\/%{DATA:ssl_type}\)''']
  name_suffix = "_opnsense_version"
  #interval = "1m"
# UnComment this section if you want to scrape the unbound log this requires telegraf be run as root
#[[inputs.tail]]
#  name_override = "resolver"
#  data_format = "grok"
#  grok_patterns = ['''%{SYSLOGTIMESTAMP:timestamp} %{GREEDYDATA:hostname} unbound\[%{INT}\]: \[%{INT:pid}:%{INT:thread}\] %{DATA:level}: %{DATA:resolver_ip} %{DATA:domain} %{DATA:record_type} %{GREEDYDATA}''']
#  files = ["/var/log/resolver/resolver_*"]

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
7. go to the explore tab and loki and make sure the firewall is shipping logs