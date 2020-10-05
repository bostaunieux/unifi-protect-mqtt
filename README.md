# unifi-protect-mqtt

This service will listen for motion events on any Unifi cameras conneted to the Unifi Protect platform and publish messages to an MQTT broker for each start and stop event. While you can alternatively poll the Unifi Protect API for updates, this approach is less resource-intensive, although more invasive. If Unifi ever releases a real-time events API for the Cloud Key, this will no longer be needed.

You use this at your own risk and I provide no warranties against breaking anything on your Unifi hardware.

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
    * `WATCH_FILE`=/foo/bar (Optional: Override the camera events file to watch)
    * `DOORBELL_CAMERA`=Front Door (Optional: Set to the camera name for any doorbell; will monitor for ring events)
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
