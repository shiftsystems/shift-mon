# Nut
ShiftMon's Telegraf role will not setup NUT for you.
I loosely followed the instructions from [Techno Tim](https://technotim.live/posts/NUT-server-guide/) to install Nut server.
If you haven't already brought a UPS make sure it is [compatible with NUT](https://networkupstools.org/stable-hcl.html)

## Shiftmon Setup
Since NUT uses a password for authentication Shiftmon will deploy the Telegraf config for NUT when the following variables for a host are configured.
Please remember to replace 
```
nut.example.com:
  nut_enabled: true
  nut:
    server: "127.0.0.1"
    port: 3493
    username: YOUR_USER
    password: YOUR_PASSWORD
```


