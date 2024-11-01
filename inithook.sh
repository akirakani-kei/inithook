#!/bin/bash

attempt=1

while [ $attempt -le 20 ]; do


    if ping -c 1 8.8.8.8 &> /dev/null; then

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

    fi

        

        TOKEN=$(grep -oP '^(?!#).*token = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
        CHANNEL_ID=$(grep -oP '^(?!#).*channel-id = \K.*' /home/$(who | awk 'NR==1{print $1}')/.config/inithook/inithookrc)
        MESSAGE_CONTENT=$(sed ':a;N;$!ba;s/\n/\\n/g' /var/log/inithooktemp.log | sed 's/"/\\"/g')

        JSON_THING=$(cat << EOF
        {
            "embeds": [
                {
                    "description": "$MESSAGE_CONTENT",
                    "footer": {
                    "text": "github.com/akirakani-kei"
                    },                    
                    "color": 3880010
                }
            ]
        }
EOF
)

        curl --request POST -H "Content-Type: application/json" -H "Authorization: Bot $TOKEN" \
        -d "$JSON_THING" \
        https://discord.com/api/v10/channels/$CHANNEL_ID/messages




        #!!!
        break  
        #!!!



    else
        echo "No internet connection found after $attempt attempts." > /var/log/inithooktemp.log
    fi
    
    attempt=$((attempt + 1))

    sleep 10
done


if [ $attempt -gt 20 ]; then
    exit 1
fi
