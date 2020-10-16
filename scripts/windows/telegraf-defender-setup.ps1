# download and install telegraf config
$url = "https://gitlab.com/shiftsystems/shift-rmm/-/raw/master/telegraf-configs/windows/defender.conf"
$output = "C:\Program Files\telegraf\telegraf.d\defender.conf"
Invoke-WebRequest -Uri $url -OutFile $output

# Restart Telegraf
net stop telegraf
net start telegraf