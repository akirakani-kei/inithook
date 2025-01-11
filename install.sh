#!/bin/sh

# this script's a mess due to the project having underwent numerous (moronic) changes throughout its development that previously required elevated privileges for a few more aspects than it does now.
# i have no real incetive to fix/update an install script to be more efficient (and all it does is move some files)
# do bear in mind that this was my first ever scripting project, i'm aware it's hot garbage
# it did serve as my stepping stone into the world of shell scripting, which i am grateful for
# coming back to this however was the most painful experience of fixing my own code i've ever been subjected to

#i thoroughly apologise

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
        rm -rf ~/.config/inithook
        mkdir -p ~/.config/inithook
        mv inithook.sh ~/.config/inithook/
        chmod +x ~/.config/inithook/inithook.sh
        mv inithook.service ~/.config/systemd/user/
        systemctl --user enable inithook.service
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
    rm -rf ~/.config/inithook
    mkdir -p ~/.config/inithook
    mv inithook.sh ~/.config/inithook/
    sudo chmod +x ~/.config/inithook/inithook.sh
    mv inithook.service ~/.config/systemd/user/
    systemctl --user enable inithook.service
    mv inithookrc ~/.config/inithook/
    cd ..
    sudo rm -rf inithook
elif command -v doas >/dev/null 2>&1; then
    echo "Running with doas"
    rm -rf ~/.config/inithook
    mkdir -p ~/.config/inithook
    mv inithook.sh ~/.config/inithook/
    doas chmod +x ~/.config/inithook/inithook.sh
    mv inithook.service ~/.config/systemd/user/
    systemctl --user enable inithook.service
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
