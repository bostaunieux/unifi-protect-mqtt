# unifi-protect-mqtt

## Installation

The installation should be done on your Cloud Key G2

```
apt update
apt install -y inotify-tools mosquitto-clients
mkdir /usr/local/lib/unifi-protect-mqtt
cp package.json, package-lock.json and index.js /usr/local/lib/unifi-protect-mqtt
cd /usr/local/lib/unifi-protect-mqtt && npm install
cp unifi-protect-mqtt.service /etc/systemd/system
systemctl daemon-reload
systemctl enable unifi-protect-mqtt
```

## Setup

1. Create .env file in the unifi-protect-mqtt directory with the following properties:
    * `MQTT_HOST`=mqtt://192.168.1.6
    * `MQTT_USER`=unifi-mqtt
    * `MQTT_PASS`=password
2. Confirm the service starts without errors by running
    ```
    /usr/bin/node -r dotenv/config /usr/local/lib/unifi-protect-mqtt/index.js
    ```

## Guide
This will publish start and stop events when motion is detected to a topic with the following format: `unifi/camera/motion/{snakecase_camera_name}`

Sample topic
```
unifi/camera/motion/front_door
```

The body will be JSON-formatted with the following keys

| Key         | Description                                         |
|-----------  |-----------------------------------------------------|
| camera_id   | Unifi protect camera identifier/mac address         |
| camera_name | Unifi protect camera name                           |
| timestamp   | Unix timestamp of the event                         |
| status      | Start or end of camera motion; one of "ON" or "OFF" |

Sample payload
```
{
    "timestamp": 1598979756369,
    "camera_id": "FFAC42D9B32C",
    "camera_name": "Front Door",
    "status": "ON"
}
```
