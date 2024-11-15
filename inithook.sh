#!/bin/bash

attempt=1

start_time=$(date +%s.%N)

while [ $attempt -le 20 ]; do


    if ping -c 1 8.8.8.8 &> /dev/null; then

    connection_time=$(date +%s.%N)
    delta=$(echo "$connection_time - $start_time" | bc)

    touch /var/log/inithooktemp.log


    format=$(grep -oP '^(?!#).*format = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)

    if [ "$format" = "simple" ]; then


    OUTPUT="***$HOSTNAME** booted in: **$(systemd-analyze | grep -oP '(?<=\= ).*')***"
    echo "${OUTPUT}" > /var/log/inithooktemp.log

    elif [ "$format" = "complex" ]; then

        OUTPUT1="***$HOSTNAME** booted in: **$(systemd-analyze | grep -oP '(?<=\= ).*')***"
        OUTPUT2="*firmware: $(systemd-analyze | sed -n 's/.*Startup finished in \([^ ]*\).*/\1/p')*"
        OUTPUT3="*loader: $(systemd-analyze | sed -n 's/.*(firmware) + \([^ ]*\).*/\1/p')*"
        OUTPUT4="*kernel: $(systemd-analyze | sed -n 's/.*(loader) + \([^ ]*\).*/\1/p')*"
        OUTPUT5="*userspace: $(systemd-analyze | sed -n 's/.*(kernel) + \([^ ]*\).*/\1/p')*"
        echo "${OUTPUT1}" > /var/log/inithooktemp.log
        echo >> /var/log/inithooktemp.log
        echo "${OUTPUT2}" >> /var/log/inithooktemp.log
        echo "${OUTPUT3}" >> /var/log/inithooktemp.log
        echo "${OUTPUT4}" >> /var/log/inithooktemp.log
        echo "${OUTPUT5}" >> /var/log/inithooktemp.log
        echo >> /var/log/inithooktemp.log
        printf "*Connection established after: %.3f seconds. (post boot)*" "$delta" >> /var/log/inithooktemp.log
    fi


        distroif=$(grep -oP '^(?!#).*distro-image = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)

        if [ "$distroif" = "true" ]; then

        distro=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | sed -E 's/^Linux //I' | awk '{print tolower($1)}')
        fi
        

        TOKEN=$(grep -oP '^(?!#).*token = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
        CHANNEL_IDS=$(grep -oP '^(?!#).*channel-id = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
        COLOR=$(grep -oP '^(?!#).*embed-color = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
            if [ "$COLOR" == "random" ]; then
                COLOR=$((((RANDOM << 15) | RANDOM)%16777216))

            elif [ "$COLOR" == "distro" ]; then
            COLOR=$(curl -s https://raw.githubusercontent.com/akirakani-kei/distro-icons/refs/heads/main/colors | grep -oP "^(?!#).*\b$distro\b = \K.*")
            fi

        MESSAGE_CONTENT=$(sed ':a;N;$!ba;s/\n/\\n/g' /var/log/inithooktemp.log | sed 's/"/\\"/g')



        JSON_THING=$(cat << EOF
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

        if grep -Eq "^[[:space:]]*discord[[:space:]]*$" "/home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc"; then

        for CHANNEL_ID in $CHANNEL_IDS; do

        curl --request POST -H "Content-Type: application/json" -H "Authorization: Bot $TOKEN" \
        -d "$JSON_THING" \
        https://discord.com/api/v10/channels/$CHANNEL_ID/messages

        done

        fi

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
