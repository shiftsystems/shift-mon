## Requirements
* Ubuntu with 22.04 or later.
* A Redhat 8 or 9 based distro (Alma, Rocky)
* The Current version of Fedora
* 4 subdomains to point at the server
* Debian 12 or later

## Installation

### CHECKOUT THE CORRECT BRANCH
make sure you are on the `shiftmon-1` branch

```bash
git checkout shiftmon-1
```

### Setup Ansible on your machine

### Ubuntu
1. ```sudo add-apt-repository ppa:ansible/ansible sudo apt update && sudo apt install ansible git python3-apt software-properties-common```


### RedHat and RedHat Derivatives
1. ```sudo dnf install epel-release```
2. ```sudo dnf install ansible git ansible```

### Fedora
1. ```sudo dnf install ansible```

### Prepping Ubuntu Targets
You will need to run the following commands on a debian machine before running ansible. Since python3, python3-apt, and gpg are not included in some minimal installs
```sudo apt install python3 python3-apt gpg```

### Setup Inventory
1. Make folder in your home directory for shift-mon and the inventory files `mkdir -p ~/shiftmon` or create a `.yml` or `.yaml` file called `shift-inventory.yml` in your existing repository.
2. Add the following to `~/shift-mon/shift-inventory.yml`

```yaml
all:
  hosts:
  children:
    shiftmon_servers:
      hosts:
        server.example.com:
```


3. Create a edit shift-mon.yml with the following Template
If don't have a secretes manager can place the variables in quotes however this is insecure since secrets to various services are in plain text.


#### Configuring Your playbook.yml File

##### Required playbook.yml

Below is an example playbook.yml.

The example playbook.yml below expects many variables to be defined in the environment it runs in. This can be accomplished in many ways, sourcing a `.env` file before running shift-mon or by using CI or other automation tools that handle secrets automatically.

I'll put this here as a reference to anyone who doesn't know how the ansible.builtin.env works.
Below you will see many lines that look like this. There are two main things to look at in these lines. In our example `VMALERT_PASSWORD` is the expected variable name that you need to add to your environment and `default='vmalert'` is the default value if you did not supply one. Note that due to the nature of most of these values they won't have a default and the playbook will not work properly if they are not supplied.
```yml
"{{ lookup('ansible.builtin.env', 'VMALERT_PASSWORD', default='VMALERT') }}"
```

```yaml
- hosts: shiftmon_servers
  name: Deploy Shift mon
  tasks:
    - name: Create shiftmon group
      ansible.builtin.group:
        name: shiftmon
        state: present
      become: true
    - name: Create shiftmon user
      ansible.builtin.user:
        name: shiftmon
        state: present
        groups: shiftmon
        append: true
      become: true
    - name: Set Telegraf Secrets
      run_once: true
      ansible.builtin.set_fact:
        #telegraf_root: true #uncomment if telegraf needs to run as root
        env_telegraf_tags: []
        extra_vars_tag: []
        vmalert_token: vmalert
        alertmanager:
          domain: am.local.shiftsystems.net
          webhook_url: 'https://example.com/webhook-endpoint'
          webhook_name: 'hooky-mchookface'
          smtp_host: 'mail.example.com:587'
          smtp_username: "{{ alertmanager_smtp_username }}"
          smtp_password: "{{ alertmanager_smtp_password }}"
          smtp_from_email: "{{ alertmanager_smtp_username }}"
          smtp_auth_identity: "{{ alertmanager_smtp_username }}"
          #to_email: "hooky@examples.com"
          users:
            - user: alertmanager
              password: alertmanager
        loki:
          retention_period: 30d
          tsdb_date: "2023-04-30"
          tsdb_13_date: "2024-04-10"
        victoria:
          url: 'https://metrics.example.com'
          retention_period: 90d
          domain: metrics.example.com
          insecure: false
          #downsampling_period: '1d:1m,7d:5m' # only available if you have an license of Victoriametrics
          #retention_filter: '{db=~`opnsense|windows`}:30d' # only available if you have an license of Victoriametrics
          #license: "GET_YOUR_OWN" # only available if you have an license of Victoriametrics
          tokens:
            - '{{ secret_token }}'
            - '{{ other_secret_token }}'
          users:
            - user: victoriametrics
              password: victoriametrics
           # uncomment these lines if you want to add your own rules to vmalert
           #rule_files:
           #pango: "{{ playbook_dir}}/rule-files/pango.yaml"
        victorialogs:
          domain: logs.example.com
          tokens:
            - 'its-log-its-log'
            - 'its-big-its-heavy-its-wood'
          users:
            - user: victorialogs
              password: "victorialogs"
          retention_period: '30d'
          #syslog_port: '514' # uncomment if you want to use Victorialogs as a syslog server Please use Telegraf as syslog if possible
        vmanomaly_enabled: true
        email:
          enabled: true
          host: 'mail.example.com'
          alert_from_address: 'alerts@shiftsystems.net'
          user: 'alerts@example.com'
          password: '{{ shiftmon_smtp_password }}'
          alert_from_name: 'Shiftmon Alerts'
          port: '587'
        oauth:
          enabled: true
          name: "muh-sso-provider"
          client_id: "{{ oauth_client_id }}"
          client_secret: "{{ oauth_client_secret }}"
          auth_url: '{{ oauth_auth_url }}'
          token_url: '{{ oauth_token_url }}'
          api_url: '{{ oauth_api_url }}'
          allowed_domains: 'example.com shiftsystems.net'
          scope: 'openid email profile'
        # Uncomment to enable LDAP login for Grafana
        #ldap_host: 'ldap.example.com'
        #ldap_port: '389' # use 636 for SSL use 389 for STARTTLS and please don't use plain text
        #bind_dn: 'uid=grafana_bind,cn=users,cn=accounts,dc=local,dc=example,dc=com'
        #base_dn: 'dc=local,dc=shiftsystems,dc=net'
        #user_search: '(\u0026(uid=%s)(memberOf=cn=ipausers,cn=groups,cn=accounts,dc=local,dc=example,dc=com))'
        #ldap_first_name: 'givenName'
        #member_of: 'memberOf'
        #ldap_last_name: 'sn'
        #ldap_user: 'uid'
        #ldap_email: 'mail'
        #admin_group: 'cn=admins,cn=groups,cn=accounts,dc=local,dc=example,dc=com'
        # bind_password: "{{ lookup('env', 'BIND_PASSWORD') }}" # optional LDAP Bind Password
        syslog: rsyslog
        reverse_lookup_remote_syslog: false
        reverse_lookup_syslog: false
        remote_syslog: true
        # uncomment to use DNS verification with Traefik
        #dns:
        #provider: cloudflare
        #auth_values:
        #CF_DNS_API_TOKEN: "GET_YOUR_OWN"
        grafana:
          domain: grafana.example.com
          #alert_path: "{{ playbook_dir }}/user-alerts.yml" # uncomment to add Grafana managed alerting rules
          basic_auth_user: "{{ grafana_basic_auth_user }}"
          basic_auth_password: "{{ grafana_basic_auth_password }}"
# uncomment to add your own dashboards to Grafana each key should have a value that points to a folder
          #dashboard_paths:
          #  stonks: "{{ playbook_dir }}/stonks"
          #  business: "{{ playbook_dir }}/business"
          #  matrix: "{{ playbook_dir }}/matrix"
        tls:
          email: 'test@example.com'
    - name: Deploy Telegraf
      ansible.builtin.include_role:
        name: telegraf
        public: true
    - name: Deploy victoriametrics
      ansible.builtin.include_role:
        name: victoriametrics
        public: true
    - name: Deploy loki
      ansible.builtin.include_role:
        name: loki
        public: true
    - name: Deploy grafana
      ansible.builtin.include_role:
        name: grafana
        public: true
    - name: Deploy traefik
      ansible.builtin.include_role:
        name: traefik
        public: true
# Uncomment to deploy vmanomaly this requires a Victoriametrics Enterprise license
#    - name: Deploy vmanomaly
#      ansible.builtin.include_role:
#        name: vmanomaly
    - name: Deploy Docker
      ansible.builtin.include_role:
        name: docker
        public: true
```

##### Additional Optional Features

You can copy and paste these groups of variables to enable additional features of shift-mon.

###### Email
```yaml
        # SMTP information to allow Grafana to send emails
        email:
          #enabled: true # Set this to true to enable email 
          host: 'mail.example.com'
          alert_from_address: 'alerts@example.com'
          user: 'alerts@example.com'
          password: "{{ lookup('env', 'TELEGRAF_PASSWORD') }}"
          alert_from_name: 'Shiftmon Alerts'
          port: '587'
```
###### TSDB Date

If you are just installing Shiftmon please set `tsdb_13_date` the date you are deploying Shiftmon formatted `yyyy-mm-dd` This will be the default in the future.

```yaml
tsdb_13_date: 2024-04-10
```

Loki is moving to using the TSDB index and depcrecating the default boltdb index since the TSDB index is performant and they were struggling to maintain all the older indices. To take advantage of these features set `tsdb_13_date` to a date in future formatted `YYYY-MM-DD` this can be used with the existing `tsdb_date` and is a legacy variable which is uses an older schema with the TSDB index.

```yaml
          tsdb_date: "2023-04-30"
          tsdb_13_date: "2024-04-01"
```

###### LDAP Authentication
```yaml
```

###### Bring Your Own Dashboards
You can define a dictionary in the shiftmon.yml file that will deploy dashboards you have exported from Grafana
The dictionary name is `dashboard_paths` under `grafana`
The key is the folder name it will appear under in Grafana
The value is the path to the folder on the Ansible Controller
```yaml
grafana:
  domain: "grafana.example.com"
  dashboard_paths:
    business: "{{ playbook_dir }}/business"
```
You can export Grafana dashoards by following the [Grafana docs](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#dashboard-json-model).
4. Deploy or update Shift-mon by running `ansible-galaxy collection install --force shiftsystems.shift_mon  && ansible-playbook -i shift-inventory.yml shift-mon.yml --ask-become-pass` from `~/shift-mon`


5. Setup the Admin User for Grafana
First, navigate to the URL you defined for Grafana and click get started.
Then fill out your username and password. You should do this even if you have ldap enabled to avoid someone creating the admin account on your behalf.


### Deploying Telegraf. 
For Linux Devices Please use the ansible roles. There is a shell script but it does not do nearly as much as the Ansible Role. For other Operating systems, you will find various scripts in the Scripts folder that you can upload to your RMM and push out telegraf on an ad hoc or scheduled basis.

By default the username and password for loki and Victoriametrics are stored in `/etc/default/telegraf` if you want to use linux kernel secrets you can set `use_telegraf_secrets: true` but you will need to apply secrets after every reboot since Linux kernel secrets do not persist across reboots.

By default the Telegraf Ansible role will try to instrument the Services listed in the [README](README.md) automatically if found on a system.


Services are discovered by looking at the list of systemd services present on a system, looking for a binary in a certain path, or based off of variables that define an endpoint and credentails for connecting to that endpoint.
If you add one of the supported services to your system just rerun the Telegraf role and the appropriate Telegraf config will be added.
To prevent automatic instrumentation for a service from occurring add a variable called `do_not_instrument: []` to your inventory with the services you do not want shift-mon to instrument from the list above in the form of a list ex `do_not_instrument: ["mysql","docker"]` will not instrument mysql and docker but instrument everything else.
`do_not_instrument: ["docker"]` will not instrument docker automatically, and even though it is 1 item it still needs to be a list.
This variable can be defined as a host variable, group variable or globally.
Defining this variable WILL NOT cause a previously deployed configurations to be removed and the user will have to remove the configuration file from `/etc/telegraf/telegraf.d` and restart telegraf to stop further collection of data from the now ignored service.

By default Telegraf runs as an unprivileged user if you are running into issues with telegraf not having the right permissions to collect certain data please change group membership, permissions on a resource, or add the required capabilities to the telegraf user.
Telegraf can be run as root on your system by setting `telegraf_root: true` in your inventory for that host or group if needed, but this is a security risk since telegraf can run arbitrary scripts using the exec and execd plugins


### [Pushing Telegraf to Windows via MeshCentral](docs/Telegraf/Windows.md)
This should a be a similar workflow to most RMMs. upload the scripts, change your particulars, and yeet it on to your endpoints


### Syslog
Shift-mon can configure syslog forwarding to loki, and configure telegraf act a syslog server by following the instructions below

* If `syslog` is defined at all for a host, group, or telegraf will listen for syslog messages on udp port 6667 on localhost.
* Define `syslog: rsyslog` to have the telegraf role install and configure rsyslog and setup log forwarding to udp 6667 on localhost.
* Define `remote_syslog: true` to have telegraf listen for syslog on all interfaces on udp port 6666 not this will only work for syslog formatted in RFC3164.

To ship syslog messages formatted using RFC3164 please configure rsyslog or syslog-ng to forward the logs to telegraf on localhost.
ESXI hosts prior to 8.0 use this format as well as PFSense by default, but PFSense can be configured to use RFC5424 formatting for syslog messages.



### Vsphere
Telegraf can be configured to gather metrics from VCenter by scraping the metrics API to enable this feature add the following variables to a host in your inventory.
```yaml
vsphere_enabled: true
vsphere_urls = ["https://muh-vcenter.local.example.com"]
vsphere_user = "test@example.local.com"
vsphere_password = "SECRET"
```
The vsphere connection information above is saved in /etc/default/telegraf to avoid it being world readable.
The configuration deployed by shift-mon or this WILL NOT collect metrics about each VM in VCenter to avoid running into limitations with the VCenter API.
If you need to increase the amount results the VSphere API will return review [this document](https://kb.vmware.com/s/article/2107096)


## Installing Telegraf on Other Devices

### [Proxmox](Telegraf/Proxmox.md)
Documentation for insturmenting Proxmox Virtual Environment can be found [here](Telegraf/Proxmox.md)

### [Pfsense](docs/Telegraf/PFSense.md)
First, login to your Pfsense firewall as an administrative user.
Next, click on system > package manager then click on available packages.
Type Telegraf in the search box, then click on the install button next to were it says Telegraf.
Click on the confirm and wait for the package to install.
After Telegraf is installed, click on services > Telegraf
Tick the box were it says enable Telegraf and paste in the contents of telegraf_ips.conf. If you are using Snort and have blocking turned use the telegraf_ips.conf. If you are using it for just intrusion detection or not using Snort at all, use telegraf_ids.conf.
Change influxdb.example.com to your InfluxDB domain, replace GET_A_TOKEN_FROM_YOUR_INFLUXDB_INSTANCE with write access to the Pfsense bucket, and click save.
If you are not sure how to get a token, please refer to the Generate Additional Tokens for Each Bucket section of this document


### [OPNSense](docs/Telegraf/OPNSense.md)
