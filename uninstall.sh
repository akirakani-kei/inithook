rm -rf .config ~/.config/inithook
sudo rm /etc/systemd/system/inithook.service
sudo rm /usr/local/bin/inithook.sh
sudo rm /var/log/inithooktemp.log
sudo systemctl disable inithook.service