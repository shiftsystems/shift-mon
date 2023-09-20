# NTOPNG
NtopNG is a tool for analzying netowrk traffic that is usually installed on a router.
If you need help installing NtopNG please review the relavant docs for your router

* [OPNSense](https://docs.opnsense.org/manual/how-tos/ntopng.html)
* [PFSense](https://www.ntop.org/guides/ntopng/third_party_integrations/pfsense.html#pfsenseintegration)
* [Linux](https://www.ntop.org/guides/ntopng/what_is_ntopng.html#installing-on-linux)

## Pointing NtopNG at Victoriametrics
1. login to NtopNG
2. go to Settings > Preferences > timeseries
3. set the timeseries driver to InfluxDB 1.x
4. Set the InfluxDB URL to your victoriametrics url 
    * if you wish to avoid SSL issues and send metrics over plain text and have set `insecure: true` on your shift-mon server set the url to `http://yourmetricsurl.example.com:8428`
5. Set the InfluxDB Database value to a unique value like `ntopng_site_name1` using a duplicate name will cause different instances of ntopng to overlap in Grafana and probably cause bugs
6. Enable authentication if you are using the main metrics url
7. Input the username or password if you enabled auth
8. Set all toggles besides internals to on
9. Set Host Timeseries to Full
10. Set Local Hosts Timeseries > Layer-7 Applications to Both
11. Set Device Timeseries -> Layer-7 Applications to Per Category
12. Hit Save


## Self Signed Certs
If you are using a self signed cert and receiving errors from NtopNG you might need add your CA and/or certificate to your system. Use the guides below 


## Installing NtopNG

### OPNSense
1. login
2. Go to System > Trust > Authorities if you are importing a CA or System > Trust Certificates if you are importing a single cert
3. paste the CA cert or cert in the certificate data section and click import an existing cert if you are using a single cert
4. hit save

### PFsense
Follow [Netgate's Docs](https://docs.netgate.com/pfsense/en/latest/certificates/ca.html#create-a-new-certificate-authority-entry)


### Debian Based Linux
Follow the [Debian docs](https://manpages.debian.org/buster/ca-certificates/update-ca-certificates.8.en.html)

### Redhat/EL based Linux
Follow the [Redhat docs](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-shared-system-certificates)