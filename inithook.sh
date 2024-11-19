#!/bin/bash

attempt=1

start_time=$(date +%s.%N)

while [ $attempt -le 20 ]; do


    if ping -c 1 8.8.8.8 &> /dev/null; then

    connection_time=$(date +%s.%N)
    delta=$(echo "$connection_time - $start_time" | bc)

    touch /var/log/inithooktemp.log


    format=$(grep -oP '^(?!#).*format = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)

    ### FUNCTIONS

bootinfo() {
    local prefix="$1"
    local boot_time
    boot_time=$(systemd-analyze | grep -oP '(?<=\= ).*')

    if [ "$format" = "simple" ]; then
        echo "${prefix}${prefix}${prefix}$HOSTNAME${prefix}${prefix} booted in: ${prefix}${prefix}${boot_time}${prefix}${prefix}${prefix}" > /var/log/inithooktemp.log
    
    elif [ "$format" = "complex" ]; then

        local firmware loader kernel userspace
        firmware=$(systemd-analyze | sed -n 's/.*Startup finished in \([^ ]*\).*/\1/p')
        loader=$(systemd-analyze | sed -n 's/.*(firmware) + \([^ ]*\).*/\1/p')
        kernel=$(systemd-analyze | sed -n 's/.*(loader) + \([^ ]*\).*/\1/p')
        userspace=$(systemd-analyze | sed -n 's/.*(kernel) + \([^ ]*\).*/\1/p')

        {
            echo "${prefix}${prefix}${prefix}$HOSTNAME${prefix}${prefix} booted in: ${prefix}${prefix}${boot_time}${prefix}${prefix}${prefix}"
            echo
            echo "${prefix}firmware: ${firmware}${prefix}"
            echo "${prefix}loader: ${loader}${prefix}"
            echo "${prefix}kernel: ${kernel}${prefix}"
            echo "${prefix}userspace: ${userspace}${prefix}"
            echo
            printf "${prefix}Connection established after: %.3f seconds. (post boot)${prefix}" "$delta"
        } > /var/log/inithooktemp.log
    fi
}


    discordfunc() {

        local distroif=$(grep -oP '^(?!#).*distro-image = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)

        if [ "$distroif" = "true" ]; then

        local distro=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | sed -E 's/^Linux //I' | awk '{print tolower($1)}')

        fi

        local TOKEN=$(grep -oP '^(?!#).*token = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
        local CHANNEL_IDS=$(grep -oP '^(?!#).*channel-id = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
        local COLOR=$(grep -oP '^(?!#).*embed-color = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)

            if [ "$COLOR" == "random" ]; then
                COLOR=$((((RANDOM << 15) | RANDOM)%16777216))

            elif [ "$COLOR" == "distro" ]; then
            COLOR=$(curl -s https://raw.githubusercontent.com/akirakani-kei/distro-icons/refs/heads/main/colors | grep -oP "^(?!#).*\b$distro\b = \K.*")
            fi


        bootinfo "*"
        local MESSAGE_CONTENT=$(sed ':a;N;$!ba;s/\n/\\n/g' /var/log/inithooktemp.log | sed 's/"/\\"/g')

        local JSON_THING=$(cat << EOF
        {
            "embeds": [
                {
                    "description": "$MESSAGE_CONTENT",
                    "footer": {
                    "text": "github.com/akirakani-kei",
                    "icon_url": "https://avatars.githubusercontent.com/u/52973114"
                    },
                    "thumbnail": {
                    "url": "https://raw.githubusercontent.com/akirakani-kei/distro-icons/refs/heads/main/icons/$distro.png"
                    },                    
                    "color": $COLOR
                }
            ]
        }
EOF
)

        for CHANNEL_ID in $CHANNEL_IDS; do

        curl --request POST -H "Content-Type: application/json" -H "Authorization: Bot $TOKEN" \
        -d "$JSON_THING" \
        https://discord.com/api/v10/channels/$CHANNEL_ID/messages

        done
    }



        ### DISCORD

        if grep -Eq "^[[:space:]]*discord[[:space:]]*$" "/home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc"; then

        discordfunc

        fi

        ### !!!
        bootinfo
        ### !!!
        


        ### CUSTOM

        if grep -Eq "^[[:space:]]*custom[[:space:]]*$" "/home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc"; then

        BLOCK=$(awk '/^\[Custom\]/ {flag=1; next} flag' "/home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc")
        USER_SHELL=$(getent passwd "$(who | awk 'NR==1{print $1}')" | cut -d: -f7)
        
        if [[ -n "$BLOCK" ]]; then
            echo "$BLOCK" | "$USER_SHELL" 
        fi

        fi



        #!!!
        exit 0
        #!!!



    else
        echo "No internet connection found after $attempt attempts."
        echo "No internet connection found after $attempt attempts." > /var/log/inithooktemp.log
    fi
    
    attempt=$((attempt + 1))

    sleep 5


done


if [ $attempt -gt 20 ]; then
    exit 1
fi
