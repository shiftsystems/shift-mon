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

## Defining Alerts using Ansible
You can define a set of alerts by adding key named `alert_path` to the Grafana dictionary in the shiftmon inventory.
```yaml
grafana:
  domain: grafana.local.shiftsystems.net
  alert_path: "{{ playbook_dir }}/user-alerts.yml"
```

These alert rules will be evaluated every minute and is not customizable at this time.
An example file can found [user-alerts.yml](../user-alerts.yml)
If you are experiencing alert fatigue you can edit the alerts in the UI and update the user-alerts.yml file or empty the user-alerts.yml file and rerun the shiftmon playbook to update the alerts.

### Updating Provisioned alerts in the UI
Grafana offers a way to edit provisioned alerts in the UI which is more convienent than updating yml file by hand.
1. Login to Grafana and navigate to Alerts & IRM -> Alerting ->Alert rules
2. Expanded the folder with your provisioned alerts
3. Click the More dropdown on the alert you want to edit
4. Click modify export
5. Modify the alert
6. Click Export in the upper right hand side of the screen
7. Copy the file to your user-alerts.yml file
8. Run the shiftmon.yml playbook

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

### HTTPS Failure
Query: ```http_response_result_code{}```\
B: Reduce
* Function: LAST
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 0

for: 5m\
Summary: `{{ $labels.server }} is not healthy`\
Description: `{{ $labels.server }} is not healthy with issue {{ $labels.result }}`\

### DNS Filtering Not working
Query: ```dns_query_result_code{domain="malware.com"}```\
B: Reduce
* Function: LAST
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS Below
* 2

for: 5m\
Summary: `{{ $labels.domain }} is resolvable on {{ $labels.server }}`\
Description: `{{ $labels.domain }} is resolvable on {{ $labels.server }}`\

### DNS Check Failing
Query: ```lag(avg by (server,domain,record_type) (dns_query_query_time_ms{result="success"})[1h])```\
B: Reduce
* Function: LAST
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 500

for: 5m\
Summary: `DNS lookups are not working on {{ $labels.server }}`\
Description: `Users can  not lookup {{ $labels.domain }} on  {{ $labels.server }} with record {{ $labels.record_type }}`\

### SSL cert is about to expire
Query: ```lag(avg by (server,domain,record_type) (dns_query_query_time_ms{result="success"})[1h])```\
B: Reduce
* Function: LAST
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS Below
* 7

for: 5m\
Summary: `{{ $labels.common_name }} will expire soon`\
Description: `{{ $labels.common_name }} will expire soon please renew`\

### Net Response (TCP/UDP) Failure
Query: ```lag(avg by (server) (net_response_response_time{result="success"})[1h])```\
B: Reduce
* Function: LAST
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 0

for: 5m\
Summary: `{{ $labels.server }} is not healthy`\
Description: `{{ $labels.server }} is not healthy`\

### Shiftmon Container Down
Query: ```lag(docker_container_cpu_usage_percent{container_name=~`shift-mon.*-1`}[1h])```\
B: Reduce
* Function: LAST
* Input A
* Mode: Strict

C: Threshold
* Input: B
* Condition: IS ABOVE
* 200

for: 5m\
Summary: `{{ $labels.container_name }} is down`\
Description: `{{ $labels.container_name }} is down on {{ $labels.host }}`\

## Related docs
* [Grafana Alerting](https://grafana.com/docs/grafana/latest/alerting/)
* [Victoriametrics query Function](https://docs.victoriametrics.com/MetricsQL.html)
* [Prometheus Query functions](https://prometheus.io/docs/prometheus/latest/querying/functions/)
