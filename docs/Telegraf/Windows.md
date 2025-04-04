# Windows Install
The powershell script does the following. 
1. Installs Telegraf via chocolately if present otherwise it will download the latest version from Influxdata
2. Downloads the the telegraf config and places it in c:\program files\telegraf
3. Creates registry key with Victoriametrics and Victorialogs connection info in HKLM:\SYSTEM\CurrentControlSet\Services\telegraf
4. Configures Telegraf to start on boot

## Using Meshcentral
1. Make sure you have uploaded the setup.bat and the telegraf-install.ps1 scripts into meshcentral instructions can be found [here](../Meshcentral/enable-scripts.md)
2. Edit the telegraf-install script in meshcentral by clicking on the script and clicking edit.
3. Change the following lines to match your influxdb server info. If you need help getting a token follow the [Influxdb documentation](https://docs.influxdata.com/influxdb/cloud/security/tokens/create-token/)
  * victoriametrics_url = your Victoriametrics URL
  * victoriametrics_token = token with access to Victoriametrics
  * victorialogs_url = your Victorialogs URL
  * victorialogs_token = your Victorialogs token
4. save the script, click on it again and run it. You can use the advanced run feature to push it to multiple nodes at the same time.
 
## Using Powershell and Chocolately 
This assumes you have configured execution policy to allow mutli line scripts to execute and you must have local administrator priviledges. This can be pushed via the setup script via meshcentral or by running ```Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser``` in an admin powershell session.

1. Download the script ```Invoke-WebRequest https://gitlab.com/shiftsystems/shiftmon/-/raw/main/scripts/windows/telegraf-install.ps1```
2. Modify the values below so Telegraf can connect to your shiftmon server
  * victoriametrics_url = your Victoriametrics URL
  * victoriametrics_token = token with access to Victoriametrics
  * victorialogs_url = your Victorialogs URL
  * victorialogs_token = your Victorialogs token
3. Execute the script you just download by running ```.\telegraf-install.ps1```

