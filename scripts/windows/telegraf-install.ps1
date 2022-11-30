# Victoria Metrics Settings
$victoria_url = "https://victoriametrics.example.com"
$victoria_user = "telegraf"
$victoria_password = "telegraf"
$victoria_database = "windows"

# Loki Metrics Settings
$loki_url = "https://loki.example.com"
$loki_user = "loki"
$loki_password = "loki"

# env registry key
$telegraf_env =("victoria_url=$victoria_url","victoria_user=$victoria_user","victoria_password=$victoria_password","victoria_database=$victoria_database","loki_url=$loki_url","loki_user=$loki_user","loki_password=$loki_password")

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

# Add Defender config if server 2016 or newer or windows 10
[int]$build = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('CurrentBuild')
if ($build -gt 10000) {
    $url = "https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/defender.conf"
    $output = "C:\Program Files\telegraf\telegraf.d\defender.conf"
    Invoke-WebRequest -Uri $url -OutFile $output
}

# ADD IIS config if IIS is present
$service = get-service w3svc -ErrorAction SilentlyContinue
if($service) {
    $url = "https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/iis.conf"
    $output = "C:\Program Files\telegraf\telegraf.d\iis.conf"
    Invoke-WebRequest -Uri $url -OutFile $output
    $url = "https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/iis-logs.conf"
    $output = "C:\Program Files\telegraf\telegraf.d\iis-logs.conf"
    Invoke-WebRequest -Uri $url -OutFile $output
}
# Create registry entries for telegraf
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\telegraf"-Name "Environment" -PropertyType MultiString -Value $telegraf_env -Force

# Create and start telegraf service
if (!(Get-Service telegraf)) {
    & 'C:\Program Files\telegraf\telegraf.exe' --service install --config-directory 'C:\Program Files\telegraf\conf'
}

Set-Service -Name telegraf -Status Running -StartupType Automatic
