#!/bin/sh

echo    ".----------------------------------------."
echo    "|  _       _ _   _                 _     |"
echo    "| (_)_ __ (_) |_| |__   ___   ___ | | __ |"
echo    "| | | '_ \| | __| '_ \ / _ \ / _ \| |/ / |"
echo    "| | | | | | | |_| | | | (_) | (_) |   <  |"
echo    "| |_|_| |_|_|\__|_| |_|\___/ \___/|_|\_\ |"
echo    "'----------------------------------------'"

echo
echo INITHOOK INSTALLATION SETUP
echo


git clone https://github.com/akirakani-kei/inithook
cd inithook

if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root (configuration file will be stored in /root/.config/inithook)"
    echo
    echo "WARNING: When installing as root, the script will ONLY function properly when root is the only logged in/configured user on the system; otherwise, it will try to fetch its non-existent configuration file from the non-root user."
    echo "If you have a non-root user configured, switch into it and run the script again."
    echo

    echo "Continue as root? [Y/n]: "
    read prompt
    prompt="${prompt:-Y}"
    prompt=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

    if [ "$prompt" = "y" ]; then
        echo "Continuing as root..."
        mv inithook.sh /usr/local/bin/
        chmod +x /usr/local/bin/inithook.sh
        mv inithook.service /etc/systemd/system/
        systemctl enable inithook.service
        mkdir -p ~/.config/inithook
        mv inithookrc ~/.config/inithook/
        cd ..
        rm -rf inithook
    else
        echo "Halted."
        cd ..
        rm -rf inithook
        exit 1
    fi
elif command -v sudo >/dev/null 2>&1; then
    echo "Running with sudo"
    sudo mv inithook.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/inithook.sh
    sudo mv inithook.service /etc/systemd/system/
    sudo systemctl enable inithook.service
    mkdir -p ~/.config/inithook
    mv inithookrc ~/.config/inithook/
    cd ..
    sudo rm -rf inithook
elif command -v doas >/dev/null 2>&1; then
    echo "Running with doas"
    doas mv inithook.sh /usr/local/bin/
    doas chmod +x /usr/local/bin/inithook.sh
    doas mv inithook.service /etc/systemd/system/
    doas systemctl enable inithook.service
    mkdir -p ~/.config/inithook
    mv inithookrc ~/.config/inithook/
    cd ..
    doas rm -rf inithook
else
    echo "Neither sudo nor doas were found. Please install either of them to proceed."
    echo "Installation failed."
    exit 1
fi

echo "Activate Discord functionality (go through Discord setup)? [Y/n]: "
read prompt
prompt="${prompt:-Y}"
prompt=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

if [ "$prompt" = "y" ]; then
    echo "Enter Discord Client Token (found at: https://discord.com/developers/applications): "
    read token
    echo "Enter Discord Channel ID (right click on wanted channel, click on Copy Channel ID): "
    read channel_id

    sed "/^[^#]*token =/s/token =.*/token = $token/" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
    sed "/^[^#]*channel-id =/s/channel-id =.*/channel-id = $channel_id/" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
    sed "/^#discord/s/^#//" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
fi

echo "Select format:"
echo "1) simple (overall boot time)"
echo "2) complex (times specific boot stages)"
echo "(1, 2, s, c): "
read format_choice

if [ "$format_choice" = "1" ] || [ "$format_choice" = "s" ]; then
    sed "s/^#format = simple/format = simple/" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
    sed "s/^format = complex/#format = complex/" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
elif [ "$format_choice" = "2" ] || [ "$format_choice" = "c" ]; then
    sed "s/^#format = complex/format = complex/" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
    sed "s/^format = simple/#format = simple/" "$HOME/.config/inithook/inithookrc" > tmpfile && mv tmpfile "$HOME/.config/inithook/inithookrc"
else
    echo "Invalid input, see ~/.config/inithook/inithookrc"
fi

echo "Installation successful. Modify ~/.config/inithook/inithookrc for further configuration."
