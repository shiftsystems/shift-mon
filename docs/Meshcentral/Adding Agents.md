# Installing agents

## Downloading the agent
1. Login to Meshcentral and click on My Devices
2. Click on Add Agent from the Device Group you wish to add a device. 
3. Select the OS and install type. 
  * Background installs allow for presistant access Once the agent is installed
  * Interactive Only means that the endpoint will only be available while the program is running.
4. Download the File

## Using the Invite Link
1. Login to Meshcentral and click on My Devices
2. Click on Invite from the Device Group you wish to add a device.
3. set the expiration time and install type, and contact type using an email invite requires that you setup an stmp account during install, or edited the meshcentral config.
  * Background installs allow for presistant access Once the agent is installed
  * Interactive Only means that the endpoint will only be available while the program is running.
4. deliver the link to your client

## Pushing meshcentral Via Group Policy.
1. Download a Windows Background and interactive agent using the Downloading the agent
2. Place this executable on a server accesible by all the target enpoints in the domain.
3. Create a batch script with the content below and place it on the same server created to bad_fake_name on the meshcentral subreddit](https://www.reddit.com/r/MeshCentral/comments/g5fa6m/how_to_automate_installation_of_meshagents_with/)
```
IF NOT EXIST "%ProgramFiles%\Mesh Agent\MeshAgent.exe" (
"\\server\deploy\MeshCentral\meshagent.exe" -fullinstall
)
```
4. Create a group policy that executes this as a logon script for the desired enpoints. 

## Adding a Permenant link to your website
1. Follow the Using an Invite link instructions above just make sure you set the expiration time to Unlimited.
2. copy the invite link
3. embed the link in your website.
