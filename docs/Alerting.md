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
Query: ```count(cpu_usage_idle{} offset 5m) by (host) unless count(cpu_usage_idle{} ) by (host)```\
Operation: Reduce\
Function: Mean\
Input: A\
Summary: {{ $labels.host }} is down\
Description: I say you {{ $labels.host }} dead\
Conditions: Evaluate every 1m for 5m\


### High memory usage
Query: ```avg_over_time(mem_used_percent[10m]) > 92```\
Operation: Reduce\
Function: Mean input A\
Input: A\
Summary: {{ $labels.host }} is using almost all its RAM\
Description: {{ $labels.host }} is at {{ $value }}%\
Conditions: Evaluate every 1m for 5m\


### High CPU usage
Query: ```100 - avg_over_time(cpu_usage_idle{}[10m]) > 95```\
Operation: Classic \
Function: Mean input A\
Input: A\
Summary: {{ $labels.host }} has been using alot of cpu for the past 10 minutes\
Description: {{ $labels.host }} is at {{ $value }}%\
Conditions: Evaluate every 2m for 10m\


### Low Disk Space
Query: ```disk_used_percent{device !="devfs"} > 92```\
Operation: Reduce\
Function: Mean\
Input: A \
Summary: {{ $labels.host }} is running out of disk space\
Description: {{ $labels.host }} is at {{ $value }}% on disk {{ $labels.device }} Disk usage\
Conditions: Evaluate every 2m for 10m\

### Automation Failure
Query: ```{name=~`dnf-automatic-install.service|unattended-upgrades.service|certbot.service|apt-daily-upgrade.service`} == 3```\
Operation: Reduce\
Function: Mean\
Input: A\
Summary: {{ $labels.host }} automatic services are not working correctly\
Description: {{ $labels.host }} is having an issue with automation\
Conditions: Evaluate every 10m for 30m\

## Related docs
* [Grafana Alerting](https://grafana.com/docs/grafana/latest/alerting/)
* [Promethues missing timeseries]()
* [Prometheus Query functions](https://prometheus.io/docs/prometheus/latest/querying/functions/)