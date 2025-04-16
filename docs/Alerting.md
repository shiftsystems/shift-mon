# Alerting setup
The preferred method for Alerting in shiftmon is to use vmalert and alertmanager since the rules are simpler and easier to define.
Shiftmon also wires together all the components needed to view alerts and alertmanager configuration in the UI as well as managed silences from Grafana as well as the alertmanager web interface.
If you still want to use Grafana managed rules so rules can be created via a GUI this is supported and Loki is configured for managing alert state to help Grafana managed alerts scale.
Shiftmon also configures Victoriametrics as the remotewrite destination for recording rules

## Enabling Alertmanager to send notifications
Shiftmon includes a template for configuring alertmanager to send notifications via an webhook and/or via email. If both SMTP variables and webhook variables are defined alerts will be routed to both destinations.

### Configuring SMTP
To configure alertmanager to send emails via SMTP the  following will need to be added

- a server and port in the format `<smtp_url:smtp_port>` (smtp_host)
- a from email address where emails will appear to be sent from (smtp_auth_identity)
- a username for authenticating to the SMTP server (smtp_username)
- a password for authenticating to the SMTP server (smtp_password)
- a email address to send the alerts to. (to_email)

The following optional values can also be defined
- disable verifying SSL certificates to the SMTP server (smtp_require_tls)

```yaml
alertmanager:
  smtp_host: "mail.example.com:587"
  smtp_username: "alerts@example.com"
  smtp_password: "super_secure_password"
  smtp_from_email: "alerts@example.com"
  smtp_auth_identity: "alerts@example.com"
  #smtp_require_tls: false
```

### Configure a webhook
To configure alertmanager to send a webhooks you only need to define a name and a URL for the webhook under the alertmanager object

```yaml
alertmanager:
  webhook_name: 'alerty-alertface'
  webhook_url: 'https://alerts.example.com/?api_key=1234567'
```


If you want to configure more complex polices like inhibitions or matchers, then you can override the defaulttemplate by defining `shiftmon_alertmanager_config` to a valid alertmanager configuration. Details about alertmanager configuration can be found in the [Prometheus alertmanager documentation documentation](https://prometheus.io/docs/alerting/latest/configuration/)

### service that support alertmanager webhooks.

Below is a list of services that work with alertmanager via a webhook.
This is list is not complete, but it should be helpful

* [ilert](https://docs.ilert.com/integrations/inbound-integrations/victoria-metrics)
* [pagerduty](https://www.pagerduty.com/docs/guides/prometheus-integration-guide/)
* [ntfy]()
* [keep]()

If you want to configure alertmanager to fit your needs you can follow the [alertmanager configuration docs](https://prometheus.io/docs/alerting/latest/configuration/) and pass a valid alertmanager configuration to the varaiable `shiftmon_alertmanager_config`

## Enabling alerting rules maintained by shiftmon
To avoid alert fatigue, Shiftmon does not have any alerting or recording rules enabled by default.
Each of the variables below will enable a group of alerts related to a certain service if you wish to turn them off simply delete the key or set it to `false` and rerun the shiftmon.yml playbook

```yaml
# Deadman alerts for things like hosts not sending metrics, UPS units not sending metrics, missing metrics from vmanomaly
shiftmon_alerts_deadman_enabled: true

# Host metrics alerts like high resource utilization or low disk space
shiftmon_alerts_infra_enabled: true

# enables alerts for things like backbox health checks failing
shiftmon_alerts_blackbox_enabled: true

# Enables alerts for ProxmoxVE and Proxmox backup server
shiftmon_alerts_proxmox_enabled: true

# Enables alerts for FreeIPA
shiftmon_alerts_freeipa_enabled: true

# Enables alerts for victorialogs
shiftmon_alerts_victorialogs_enabled: true

# Enables alerts for vmauth
shiftmon_alerts_vmauth_enabled: true

# Enables alerts for alertmanager
shiftmon_alerts_alertmanager_enabled: true

# Enables alerts for Victoriametrics
shiftmon_alerts_victoriametrics_enabled: true

# Enables alerting and recording rules for Adguard home
shiftmon_alerts_adguardhome_enabled: true

# Enables recording rules for various logging services
shiftmon_recording_logs: true
```

## Adding your alerting and recording rules to vmalert

It is best practice to keep these rule files in git along with the rest of any other Infrastructure as code you maintain so any errors can be quickly reverted.


1. create 1 or more files that contain a valid vmalert rule config.
2. rules_files: subkey under the victoria key
3. Add a subkey under the `rule_file` key that will be the name of the file on the shiftmon server and the value of that subkey should be the path to the file.

Below is a snippet from a shiftmon inventory as an example
```yaml
  vars:
    victoria:
      rule_files:
        pango: "{{ playbook_dir}}/rule-files/pango.yaml"
        darules: "{{ playbook_dir}}/rule-files/darules.yaml"

```


## Configuring Alertmanager

TODO

## Configure Contact Points in Grafana managed Alerts
1. Login to your grafana instance and go the alerting area
2. click the contact point tab and click the pencil icon by the autogen-contact-point-default.
3. type your email and any other contact emails you want to notify by separating them by a ; and click the save button

## Create Alert Rules
1. Login and go the alerting area
2. Click on the blue New alert rule button
3. Name the rule, select the Grafana managed alert, and place it in the shift-mon folder
4. Select the correct data source
5. Configure your own query or paste the query from the  our example ones below
6. Configure your

## Define Grafana Managed rules via using Ansible
You can define a set of alerts by adding key named `alert_path` to the Grafana dictionary in the shiftmon inventory.
```yaml
grafana:
  domain: grafana.example.com
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


## Related docs
* [Grafana Alerting](https://grafana.com/docs/grafana/latest/alerting/)
* [Victoriametrics query Function](https://docs.victoriametrics.com/MetricsQL.html)
* [Why loki is used for alert state](https://grafana.com/blog/2023/07/10/how-we-improved-grafanas-alert-state-history-to-provide-better-insights-into-your-alerting-data/)
* [vmalert docs](https://docs.victoriametrics.com/vmalert)
* [alertmanager docs](https://prometheus.io/docs/alerting/latest/configuration/)

