# Enabling Pushing Scripts in Meshcentral 

## Install the Script plugin
1. Login to Meshcentral as admin user
2. Click on My Server
3. Click on the plugins tab
4. click on download Plugin, paste in ```https://raw.githubusercontent.com/ryanblenis/MeshCentral-ScriptTask/master/config.json ```, and press ok.
5. click the Action dropdown and click install

## Uploading Scripts
1. Login and click on My Devices
2. click on any device
3. click on the plugins tab if you have more than one plugin installed you will need to click on the script task plugin
4. click on new and name the script and press ok
5. paste in the code from the script and press save then close.
Instead of steps 4 and 5 you can also upload an existing script directly.

## Preping Windows Boxes
1. Make sure you have uploaded the [Windows Setup Script](../scripts/windows/setup.bat) to your server
2. run the setup.bat script from meshcentral. The script will disable execution policy for the administrator user and install chocolately to make managing packages easier.

## Prepping Linux Boxes
Nothing Linux lets you run bash scripts by default