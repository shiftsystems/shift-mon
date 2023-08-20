# Alerting setup
The grafana setup uses the new grafana managed alerting feature instead of panels.
At the time of writing this you cannot provision alerts so they need to be configured manually. 
Please make sure you have enabled SMTP alerts so you can receive emails from grafana

## Configure Contact Points
1. signin to your grafana instance and go the alerting area
2. click the contact point tab and click the pencil icon by the autogen-contact-point-default.
3. type your email and any other contact emails you want to notify by separating them by a ; and click the save button

## Create Alert Rules
1. Login and go t the alerting area
2. Click on the blue New alert rule button
3. Name the rule, select the grafana managed alert, and place it in the shift-mon folder
4. Select shift metrics from the data source
5. Configure your own query or paste the query from the  our example ones below
6. Configure your


## Example Alerts
Feel free to customize any of the numbers or use these as the basis for your own alerts


### Host Down
Query: ```lag(cpu_usage_idle{}[1h])```

B: Reduce
  * Function: Count
  * Input: A
  * Mode: Strict


C: Threshold
  * Input: B
  * Condition: IS Above 
  * Value 300 (the integer is the time seconds the host should be down before the alert fires 300 seconds is 5 minutes)


Summary: `{{ $labels.host }} is down`\
Description: `I say you {{ $labels.host }} dead`\
for: 2m


### High memory usage
Query: ```mem_used_percent{}```

B: Reduce
* Function: Mean
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 90

for: 20m\
Summary: `{{ $labels.host }} is using almost all its RAM`\
Description: `{{ $labels.host }} is at {{ $values.B }}%`\


### High CPU usage
Query: ```100 - cpu_usage_idle{}```\
B: Reduce
* Function: Mean
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 90

for: 1h\
Summary: `{{ $labels.host }} has been using alot of cpu for the past 10 minutes`\
Description: `{{ $labels.host }} is at {{ $values.B }}%`\


### Low Disk Space
Query: ```disk_used_percent{device !="devfs"}```\
B: Reduce
  * Function: Mean
  * Input: A
  * Mode: Strict


C: Threshold
  * Input: B
  * Condition: IS ABOVE
  * Value: 92

for: 1h\
Summary: `{{ $labels.host }} is running out of disk space`\
Description: `{{ $labels.host }} is at {{ $values.B }}% on disk {{ $labels.device }} Disk usage`\


### Automation Failure
Query: ```systemd_units_active_code{name=~`dnf-automatic-install.service|unattended-upgrades.service|certbot.service|apt-daily-upgrade.service|ansible.*`}  == 3```\
B: Reduce
  * Function: Mean
  * Input: A
  * Mode: Strict


C: Threshold
  * Input: B
  * Condition: IS ABOVE
  * Value: 2


for: 1h\
Summary: `{{ $labels.host }} has automatic service that failing`\
Description: `{{ $labels.name }} on {{ $labels.host }} is failing`\


### Unhealthy Smart data
Query:
Operation: Reduce\
Function: Last\
Input: A\
Summary: `{{ $labels.host }} has a not OK SMART status on {{ $labels.device }}`\
Description:


```
{{ $labels.device }} on {{ $labels.host }} is unhealthly
model: {{ $labels.model }}
serial number: {{ $labels.serial_no }}
```
for: 5m

### High CPU IOWait
Query: ```cpu_usage_iowait{}```\
B: Reduce
* Function: Mean
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 6

for: 10m\
Summary: `{{ $labels.host }} has high iowait`\
Description: `{{ $labels.host }} is at {{ $values.B }}% of iowait this could be causing issues with application responsiveness`\

## Related docs
* [Grafana Alerting](https://grafana.com/docs/grafana/latest/alerting/)
* [Promethues missing timeseries]()
* [Prometheus Query functions](https://prometheus.io/docs/prometheus/latest/querying/functions/)