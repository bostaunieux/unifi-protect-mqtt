const mqtt = require('mqtt');
const Tail = require('tail').Tail;

const WATCH_FILE = process.env.WATCH_FILE || '/srv/unifi-protect/logs/events.cameras.log';
const DOORBELL_CAMERA = process.env.DOORBELL_CAMERA;


const client = mqtt.connect(process.env.MQTT_HOST, {
  username: process.env.MQTT_USER, 
  password: process.env.MQTT_PASS,
  will: {
    topic: 'unifi-protect-mqtt/availability',
    payload: 'offline',
    qos: 1,
    retain: true
  }
});

/**
 * 
 * @param {string} line Line to parse
 * @param {Regex} regex Expression to match
 */
const extractData = (line, regex) => {
  const match = line.match(regex);
  if (match) {
    return match[match.length - 1];
  }
  return null;
};

const parseRingLine = (data) => {
  return data.includes("type: 'ring'");
};

const parseMotionLine = (data) => {
  if (!data.includes('verbose: motion')) {
    return {};
  }

  console.log('Processing line', data);
  const cameraId = extractData(data, /\[(\w+) @/); // 12-char camera id
  const eventType = extractData(data, /motion\.(\w+)/); // start or stop
  const timestamp = Number(extractData(data, /\d\] (\d+)/)); // unix timestamp
  const cameraName = extractData(data, /\) ([\w\s]+) \[/); // camera display name
  const cameraNameTopic = cameraName.toLowerCase().replace(/[^a-zA-Z0-9\-]+/g, '_');
  
  return { cameraId, cameraName, cameraNameTopic, eventType, timestamp };
};

console.info('Initializing unifi protect mqtt bridge');


client.on('error', (error) => {
  console.error('MQTT connect error: ' + error);
});

client.on('connect', async () => {
  client.publish('unifi-protect-mqtt/availability', 'online', {qos: 1, retain: true});

  console.info('Connected to home automation mqtt broker');
  console.info(`Setting up file watcher on ${WATCH_FILE}`);

  watcher = new Tail(WATCH_FILE, { separator: null});

  watcher.on('line', (line) => {
    const isRing = parseRingLine(line);
    if (isRing && DOORBELL_CAMERA) {
      client.publish(`homebridge/doorbell`, DOORBELL_CAMERA);
      return;
    }

    const { cameraId, cameraName, cameraNameTopic, eventType, timestamp } = parseMotionLine(line);
    if (!cameraId || !eventType || isNaN(timestamp)) {
      return;
    }

    if (eventType === 'start') {
      console.log('Publishing camera event motion start topic');
      client.publish(`unifi/camera/motion/${cameraNameTopic}`, JSON.stringify({
        status: 'ON',
        timestamp,
        camera_id: cameraId,
        camera_name: cameraName,
      }));
      client.publish(`homebridge/motion`, cameraName);

    } else if (eventType === 'stop') {
      console.log('Publishing camera event motion stop topic');
      client.publish(`unifi/camera/motion/${cameraNameTopic}`, JSON.stringify({
        status: 'OFF',
        timestamp,
        camera_id: cameraId,
        camera_name: cameraName,
      }));

    } else {
      console.log('Unknown event type: ', eventType);
    }
  });

  watcher.on('error', (error) => {
    console.log('File watch error: ', error);
  });

});
