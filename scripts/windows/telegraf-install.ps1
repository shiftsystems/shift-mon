$telegraf_url="https://telegraf.exmpale.com"
$telegraf_org="shiftsystems"
$telegraf_bucket="windows"
$telegraf_token="GET_YOUR_TOKEN"
$telegraf_env =("server=$telegraf_url","organization=$telegraf_org","token=$telegraf_token","bucket=$telegraf_bucket")


C:\ProgramData\chocolatey\choco.exe install telegraf -y
C:\ProgramData\chocolatey\choco.exe upgrade telegraf -y
$path = "C:\Program Files\telegraf\conf\"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

# download and install telegraf config
$url = "https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/telegraf.conf"
$output = "C:\Program Files\telegraf\telegraf.conf"
Invoke-WebRequest -Uri $url -OutFile $output

# Create registry entries for telegraf
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\telegraf"-Name "Environment" -PropertyType MultiString -Value $telegraf_env -Force

# Create and start telegraf service
if (!(Get-Service telegraf)) {
    & 'C:\Program Files\telegraf\telegraf.exe' --service install --config-directory 'C:\Program Files\telegraf\conf'
}

Set-Service -Name telegraf -Status Running -StartupType Automatic
