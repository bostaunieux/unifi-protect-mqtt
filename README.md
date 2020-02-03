# unifi-protect-mqtt

## Installation

The installation should be done on your Cloud Key G2

```
apt update
apt install -y inotify-tools mosquitto-clients
cp unifi-protect-mqtt.sh /usr/local/bin
chmod a+x /usr/local/bin/unifi-protect-mqtt.sh
cp unifi-protect-mqtt.service /etc/systemd/system
systemctl daemon-reload
systemctl enable unifi-protect-mqtt
```

## Setup

Update `unifi-protect-mqtt.sh` with your mqtt host, preferred prefix, and user and password

## Guide
This will publish start and stop events when motion is detected. The body will be JSON-formatted with the following keys

| Key       | Description                                                                    |
|-----------|--------------------------------------------------------------------------------|
| camera_id | Unifi protect camera identifier |
| timestamp | Unix timestamp of the event                                                    |
| status    | Start or end of camera motion; one of "ON" or "OFF"                            |

Sample payload
```
{
    "timestamp": 580696117,
    "camera_id": "FFAC42D9B32C",
    "status": "ON"
}
```
