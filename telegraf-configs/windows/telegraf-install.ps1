param($telegraf_url,
    $telegraf_config_url,
    $telegraf_version,
    $telegraf_org,
    $telegraf_token,
    $telegraf_bucket,
    $mesh_url)

$telegraf_env =("server=$telegraf_url","organization=$telegraf_org","token=$telegraf_token","bucket=$telegraf_bucket")
if ((Test-Path 'C:\Program Files\telegraf') -and (&'C:\Program Files\telegraf\telegraf.exe' --version | Select-String "$telegraf_version" )) {
    Write-Host "telegraf $telegraf_version is already installed now exiting"
    exit
}
# download and zip telegraf
$url = "https://dl.influxdata.com/telegraf/releases/telegraf-"+$telegraf_version+"_windows_amd64.zip"
$output = "c:\windows\Temp\telegraf.zip"
Invoke-WebRequest -Uri $url -OutFile $output

# expand telegraf archive and create directories
Expand-Archive 'C:\windows\Temp\telegraf.zip' 'C:\windows\Temp\' -Force
Stop-Service telegraf
Remove-Item 'C:\Program Files\telegraf' -Recurse -Force
Move-Item -Path "C:\windows\Temp\telegraf-$telegraf_version" -Destination "C:\Program Files\telegraf" -Force

$path = "C:\Program Files\telegraf\conf\"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

# download and install telegraf config
$url = "https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/telegraf.conf"
$output = "C:\Program Files\telegraf\conf\telegraf.conf"
Invoke-WebRequest -Uri $url -OutFile $output


# Create and start telegraf service
if (!(Get-Service telegraf)) {
    & 'C:\Program Files\telegraf\telegraf.exe' --service install --config-directory 'C:\Program Files\telegraf\conf'
}

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\telegraf"-Name "Environment" -PropertyType MultiString -Value $telegraf_env -Force

Set-Service -Name telegraf -Status Running -StartupType Automatic
