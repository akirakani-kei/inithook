rm -rf ~/.config/inithook
rm ~/.config/systemd/user/inithook.service
systemctl --user disable inithook.service
