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
