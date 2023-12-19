# Shiftwatch, monitoring for your monitoring
The biggest issue with self hosting monitoring is that if your monitoring goes down it cannot send a notification that it failed.
The solution to this is to setup a second monitoring system that is as separate from primary monitoring as possible.
A solution to this is setting up a second shiftmon server in a different provider and have a different alerting endpoints.
If you do not want to setup a second monitoring server you can purchase Shiftwatch from Shiftsystems by emailing sales@shiftsystems.net
To enable Shiftwatch 
1. define the following host variables on your Shiftmon server and set the values to match the metric and log urls of the other Shiftmon server
```
shiftwatch_enabled: true
user_secrets:
  shiftwatch_metrics_url: "https://metrics.example.com"
  shiftwatch_logs_url: "https://logs.example.com"
  grafana_url: "https://dashboard.example.com"
  shiftwatch_user: telegraf
  shiftwatch_password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
  customer_id: "shiftwatch"
```
2. Run the [Telegraf role](Telegraf/Linux.md)
3. Configure the following Alerts in the [Alerting docs](Alerting.md)
  * Shiftmon Container down
  * HTTPS failure
  * SSL cert is about to expire
  * Host Down
4. Test your alerting by stopping telegraf on the shiftmon server temporarily and see if the missing host metrics alert fires