#!/bin/bash

# Unifi Video Vars
UNIFI_MOTION_LOG=/srv/unifi-protect/logs/events.cameras.log

# MQTT Vars
MQTT_SERVER="192.168.1.10"
MQTT_PORT="1883"
MQTT_TOPIC_BASE="unifi/camera/motion"

MQTT_ON_PAYLOAD="ON"
MQTT_OFF_PAYLOAD="OFF"

# MQTT User/Pass Vars, only use if needed
MQTT_USER=""
MQTT_PASS=""
#MQTT_ID="yourid"  ## To make it work with hassio

PREVIOUS_MESSAGE=""

# --------------------------------------------------------------------------------
# Script starts here

# Check if a username/password is defined and if so create the vars to pass to the cli
if [[ -n "$MQTT_USER" && -n "$MQTT_PASS" ]]; then
  MQTT_USER_PASS="-u $MQTT_USER -P $MQTT_PASS"
else
  MQTT_USER_PASS=""
fi

# Check if a MQTT_ID has been defined, needed for newer versions of Home Assistant
if [[ -n "$MQTT_ID" ]]; then
  MQTT_ID_OPT="-I $MQTT_ID"
else
  MQTT_ID_OPT=""
fi

while inotifywait -e modify $UNIFI_MOTION_LOG; do
    LAST_MESSAGE=`grep "verbose: motion." $UNIFI_MOTION_LOG | tail -n1 `

    if [[ "$PREVIOUS_MESSAGE" == "$LAST_MESSAGE" ]]; then
        echo " same skipping: $PREVIOUS_MESSAGE"
    else
        echo "PREVIOUS_MESSAGE: $PREVIOUS_MESSAGE"
        echo "LAST_MESSAGE: $LAST_MESSAGE"

        PREVIOUS_MESSAGE="$LAST_MESSAGE"

        LAST_CAM=`echo $LAST_MESSAGE | awk -F 'verbose: motion.' '{print $2}' | awk -F '[' '{print $1}' | cut -d ' ' -f2- | xargs | sed s/" "/_/g |  tr '[:upper:]' '[:lower:]' | sed -r 's/[^a-zA-Z0-9\-]+/_/g'`
        LAST_EVENT=`echo $LAST_MESSAGE | awk -F 'verbose: motion.' '{print $2}' | awk -F ' ' '{print $1}'`
        LAST_CAM_ID=`echo $LAST_MESSAGE | grep -o '\[.*\]' | awk '{print $1}' | cut -b 2-`
        LAST_TIMESTAMP=`echo $LAST_MESSAGE | awk '{print $NF}'`

        if [[ $LAST_EVENT == "start" ]]; then
            echo " * Motion started on $LAST_CAM"
            mosquitto_pub -h $MQTT_SERVER -p $MQTT_PORT $MQTT_USER_PASS -r $MQTT_ID_OPT -t $MQTT_TOPIC_BASE/$LAST_CAM -m "{\"status\":\"$MQTT_ON_PAYLOAD\",\"timestamp\":$LAST_TIMESTAMP,\"camera_id\":\"$LAST_CAM_ID\"}" &
        else
            echo " * Motion stopped on $LAST_CAM"
            mosquitto_pub -h $MQTT_SERVER -p $MQTT_PORT $MQTT_USER_PASS -r $MQTT_ID_OPT -t $MQTT_TOPIC_BASE/$LAST_CAM -m "{\"status\":\"$MQTT_OFF_PAYLOAD\",\"timestamp\":$LAST_TIMESTAMP,\"camera_id\":\"$LAST_CAM_ID\"}" &
        fi
    fi
done
