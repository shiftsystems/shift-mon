# Windows Install
We recomend using [chocolately](https://chocolatey.org) for deploying telegraf.
If you push out telegraf via meshcentral it will use choclately.
The powershell script does the following. 
1. Installs Telegraf via chocolately
2. downloads the the telegraf config and places it in c:\program files\telegraf
3. Creates registry key with telegraf server and creds in HKLM:\SYSTEM\CurrentControlSet\Services\telegraf
4. configures telegraf to start on boot 

## Using Meshcentral
1. make sure you have uploaded the setup.bat and the telegraf-install.ps1 scripts into meshcentral instructions can be found [here](../Meshcentral/enable-scripts.md)
2. edit the telegraf-install script in meshcentral by clicking on the script and clicking edit.
3. change the following lines to match your influxdb server info. If you need help getting a token follow the [Influxdb documentation](https://docs.influxdata.com/influxdb/cloud/security/tokens/create-token/)
  * telegraf_url = your influxdb servers url
  * telegraf_token = the token you obtained in step3 in quotes
4. save the script, click on it again and run it. You can use the advanced run feature to push it to multiple nodes at the same time. 
 
## Using Powershell and Chocolately 
This assumes you have configured execution policy to allow mutli line scripts to execute and you must have local administrator priviledges. This can be pushed via the setup script via meshcentral or by running ```Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser``` in an admin powershell session.
Next run ```Invoke-WebRequest https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/scripts/windows/telegraf-install.ps1```
Execute the script you just download by running ```.\telegraf-install.ps1```

## Manual Install
1. Download the latest version of telegraf from [here]()
2. extract the zip archive into c:\program files\
3. Download the config file from [here](https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/telegraf.conf) and place it in ```c:\Program Files\telegraf\conf
4. create a multistring registry value in ```HKLM:\SYSTEM\CurrentControlSet\Services\telegraf"-Name "Environment``` with the following values with your influxdb server url and a token with write permissions your windows bucket. ```"server=https://influxdb.example.com","organization=shiftsystems","token=GET_YOUR_OWN_TOKEN","bucket=windows"```
5. run ```c:\Program Files\Telegraf\telegraf.exe --service install --config "C:\Program Files\Telegraf\telegraf.conf"``` from an administrator powershell session
6. run ```Set-Service -Name telegraf -Status Running -SartupType Automatic``` after the service has been created.
