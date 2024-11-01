echo    " .--------------------------------------."
echo    "| _       _ _   _                 _    |"
echo    "|(_)_ __ (_) |_| |__   ___   ___ | | __|"
echo    "|| | '_ \| | __| '_ \ / _ \ / _ \| |/ /|"
echo    "|| | | | | | |_| | | | (_) | (_) |   < |"
echo    "||_|_| |_|_|\__|_| |_|\___/ \___/|_|\_\|"
echo    " '--------------------------------------'"

echo
echo INITHOOK INSTALLATION SETUP

git clone https://github.com/akirakani-kei/inithook
cd inithook

mkdir ~/.config/inithook
mv inithookrc ~/.config/inithook/

read -p "Enter Discord Client Token (found at: https://discord.com/developers/applications): " token
read -p "Enter Discord Channel ID (right click on wanted channel, click on Copy Channel ID): " channel_id

sed -i "/^[^#]*token =/s/token =.*/token = $token/" "$HOME/.config/inithook/inithookrc"
sed -i "/^[^#]*channel-id =/s/channel-id =.*/channel-id = $channel_id/" "$HOME/.config/inithook/inithookrc"

echo "Select format:"
echo "1) simple (overall boot time)"
echo "2) complex (times of specific boot stages)"
read -p "(1, 2, s, c): " format_choice

if [[ "$format_choice" == "1" || "$format_choice" == "s" ]]; then
    sed -i "s/^#format = simple/format = simple/" "$HOME/.config/inithook/inithookrc"   
    sed -i "s/^format = complex/#format = complex/" "$HOME/.config/inithook/inithookrc" 
elif [[ "$format_choice" == "2" || "$format_choice" == "c" ]]; then
    sed -i "s/^#format = complex/format = complex/" "$HOME/.config/inithook/inithookrc" 
    sed -i "s/^format = simple/#format = simple/" "$HOME/.config/inithook/inithookrc"   
else
    echo "Invalid input, see ~/.config/inithook/inithookrc"
fi

sudo mv inithook.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/inithook.sh
sudo mv inithook.service /etc/systemd/system/

sudo systemctl enable inithook.service

cd ..

rm -rf inithook
echo "Installation successful."