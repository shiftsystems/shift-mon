# Set Loki as the default Logging Backend
param($LoggingBackend='Loki')

# Victoria Metrics Settings
$victoria_url = "https://victoriametrics.example.com"
$victoria_user = "telegraf"
$victoria_password = "telegraf"
$victoria_database = "windows"

# Loki Metrics Settings
$loki_url = "https://loki.example.com"
$loki_user = "loki"
$loki_password = "loki"

Write-Host "Creating Telegraf config folder"
$path = "C:\Program Files\telegraf\telegraf.d\"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
Write-Host "Created Telegraf config folder"


# Install Chocolately
$path = "C:\ProgramData\chocolatey\bin\choco.exe"
If(test-path $path) {
    Write-Host "Installing and Updating Telegraf"
    C:\ProgramData\chocolatey\choco.exe install telegraf -y
    C:\ProgramData\chocolatey\choco.exe upgrade telegraf -y
    Write-Host "Telegraf is Up to Date"
} 
Else {
    Write-Host "Install Telegraf the old fashioned way"
    Write-Host "Getting Latest Release of Telegraf from github"
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/influxdata/telegraf/releases/latest"
    Write-Host "$release.tag_name"
    $release = $release.tag_name
    $release = $release.TrimStart("v")
    Write-Host "Now Downloading Telegraf $release"
    $download_url = "https://dl.influxdata.com/telegraf/releases/telegraf-$($release)_windows_amd64.zip"
    wget  "$download_url" -UseBasicParsing -OutFile c:\windows\temp\telegraf.zip
    Expand-Archive c:\windows\temp\telegraf.zip -DestinationPath 'C:\windows\temp\'
    $path = "C:\Program Files\telegraf\telegraf.exe"
    if (test-path $path) {
      Stop-Service Telegraf
    }
    Copy-Item -Force "C:\windows\temp\telegraf-$($release)\telegraf.exe" "C:\Program Files\telegraf\telegraf.exe"
    Write-Host "Telegraf Successfully installed"
    Write-Host "Remove zip file"
    Remove-Item "C:\windows\temp\telegraf.zip"
    Remove-Item -Recurse "C:\Windows\temp\telegraf-$($release)"

}


# download and install telegraf config
If ($LoggingBackend -eq "Loki") {
$url = "https://gitlab.com/shiftsystems/shiftmon/-/raw/main/telegraf-configs/windows/telegraf.conf"
}
Else {
$url = "https://gitlab.com/shiftsystems/shiftmon/-/raw/main/telegraf-configs/windows/telegraf-vl.conf"
}

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

# Create and start telegraf service
if (!(Get-Service telegraf)) {
    Write-Host "Creating Telegraf service"
    & 'C:\Program Files\telegraf\telegraf.exe' --service install --config-directory 'C:\Program Files\telegraf\conf'
    Write-Host "Created Telegraf Service"
}

# Create registry entries for telegraf
Write-Host "Creating Registry Entry For Telegraf"
$telegraf_env =("victoria_url=$victoria_url","victoria_user=$victoria_user","victoria_password=$victoria_password","victoria_database=$victoria_database","loki_url=$loki_url","loki_user=$loki_user","loki_password=$loki_password")
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\telegraf"-Name "Environment" -PropertyType MultiString -Value $telegraf_env -Force
Write-Host "Created Registry Entry"

Set-Service -Name telegraf -Status Running -StartupType Automatic
Write-Host "Restarting Telegraf"
Restart-Service telegraf
Write-Host "Restarted Telegraf"rite-Host "Restarted Telegraf"
