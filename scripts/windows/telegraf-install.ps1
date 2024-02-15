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
Write-Host "Installing and Updating Telegraf"
C:\ProgramData\chocolatey\choco.exe install telegraf -y
C:\ProgramData\chocolatey\choco.exe upgrade telegraf -y
Write-Host "Telegraf is Up to Date"
Write-Host "Creating Telegraf config folder"
$path = "C:\Program Files\telegraf\telegraf.d\"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
Write-Host "Created Telegraf config folder"
# download and install telegraf config
$url = "https://gitlab.com/shiftsystems/shiftmon/-/raw/main/telegraf-configs/windows/telegraf.conf"
$output = "C:\Program Files\telegraf\telegraf.conf"
Invoke-WebRequest -Uri $url -OutFile $output
Write-Host "Added Base Telegraf Config"

# Add Defender config if server 2016 or newer or windows 10
[int]$build = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('CurrentBuild')
if ($build -gt 10000) {
    $url = "https://gitlab.com/shiftsystems/shiftmon/-/raw/main/telegraf-configs/windows/defender.conf"
    $output = "C:\Program Files\telegraf\telegraf.d\defender.conf"
    Invoke-WebRequest -Uri $url -OutFile $output
	Write-Host "Added Defender config"
}

# ADD IIS config if IIS is present
$service = Get-Service w3svc -ErrorAction SilentlyContinue
if($service) {
    $url = "https://gitlab.com/shiftsystems/shiftmon/-/raw/main/telegraf-configs/windows/iis.conf"
    $output = "C:\Program Files\telegraf\telegraf.d\iis.conf"
    Invoke-WebRequest -Uri $url -OutFile $output
	Write-Host "Added IIS Config"
}

# ADD Sysmon config if Sysmon is present
$service =  @(Get-Service Sysmon*).Count -gt 0
if($service) {
    $url = "https://gitlab.com/shiftsystems/shiftmon/-/raw/main/telegraf-configs/windows/sysmon.conf"
    $output = "C:\Program Files\telegraf\telegraf.d\sysmon.conf"
    Invoke-WebRequest -Uri $url -OutFile $output
	Write-Host "Added Sysmon Config"
}

# Create registry entries for telegraf
Write-Host "Creating Registry Entry For Telegraf"
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\telegraf"-Name "Environment" -PropertyType MultiString -Value $telegraf_env -Force
Write-Host "Created Registry Entry"
# Create and start telegraf service
if (!(Get-Service telegraf)) {
    Write-Host "Creating Telegraf service"
    & 'C:\Program Files\telegraf\telegraf.exe' --service install --config-directory 'C:\Program Files\telegraf\conf'
    Write-Host "Created Telegraf Service"
}

Set-Service -Name telegraf -Status Running -StartupType Automatic
Write-Host "Restarting Telegraf"
Restart-Service telegraf
Write-Host "Restarted Telegraf"
