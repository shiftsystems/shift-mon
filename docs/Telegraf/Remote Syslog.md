# Remote Syslog
For devices that generate syslog data but can't have telegraf installed you can configure an instance of telegraf to receive syslog data by setting ```remote_syslog: true``` for one or more hosts in your inventory.
After remote syslog has been setup on one of your installations of telegraf you can forward RFC5424 formatted syslog to the ip or host of the telegraf instance on udp port 6666
Below is the additional configure config file you to place in ```/etc/rsyslog.d/50-telegraf.conf``` to setup syslog forwarding for rsyslog and other syslog daemons and forwarders will be documented as they are tested.
Please replace ```<telegraf_ip_or_host>``` with ip or host of the telegraf instance configured to receive remote syslog
```
$ActionQueueType LinkedList
$ActionQueueFileName srvrfwd
$ActionResumeRetryCount -1
$ActionQueueSaveOnShutdown on

*.* @<telegraf_ip_or_host>:6666;RSYSLOG_SyslogProtocol23Format

```