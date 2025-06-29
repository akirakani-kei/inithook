# inithook
Tracker Service for Startup Activity via HTTP Requests

![image](https://github.com/user-attachments/assets/515e4821-57c9-42dd-bd55-d04ed77c5570)



> [!IMPORTANT]
> *inithook **relies** on systemd for fetching its information and running at startup.* <br>
> *It will **only** run on distributions which use **systemd** as their init system.* <br>
> *The script runs as a systemd **user** process and should be interacted with via the `--user` tag:* <br>
`systemctl --user enable/start/stop/status inithook`

## Installation

### Install dependencies


Debian (Ubuntu, Mint, etc.)
```shell
sudo apt install maim curl
```

Arch
```shell
sudo pacman -S maim curl
```
##

### Create a Discord Application

Go to *[Discord's Developer Portal](https://discord.com/developers/applications)* and **[create a new application](https://discordjs.guide/preparations/setting-up-a-bot-application.html#creating-your-bot)** (or use an already existing one) which will serve as a mean of connection to Discord.
<br> <br>
***Copy the token and save it for later.***

*[Add your bot to the server](https://discordjs.guide/preparations/adding-your-bot-to-servers.html#bot-invite-links)* you want the alerts to go through. ([create a server](https://support.discord.com/hc/en-us/articles/204849977-How-do-I-create-a-server) if you haven't already).
<br> <br>
***Also copy the Channel ID(s) you want the updates to be sent to.*** <br>
<sub> Make sure your bot has the necessary permissions to access/send messages to those channels! <br>

##

### Run the installation script

```shell
sh -c "$(curl -sS https://raw.githubusercontent.com/akirakani-kei/inithook/refs/heads/main/install.sh)"
```
_Paste the previously **[saved information](#create-a-discord-application)** accordingly; configure based on your own preferences._ <br>
After installation, reboot or run `systemctl --user start inithook`. <br> <br>
*See `~/.config/inithook/inithookrc` for further configuration.*
<br> <br> <br>




## Paths

file                    |  path
------------------------|----------------------
inithook.sh             | ~/.config/inithook/
inithook.service        | ~/.config/systemd/user/
inithookrc              | ~/.config/inithook/
inithooktemp.log        | ~/.config/inithook/

