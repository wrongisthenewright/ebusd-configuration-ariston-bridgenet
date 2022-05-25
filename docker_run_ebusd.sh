#|/bin/bash
docker pull john30/ebusd
docker stop ebusd
docker rm ebusd

docker pull john30/ebusd


#scanconfig enabled
#For DanMan adapter  YOUR_DEVICE_DETAILS=DEVICE_IP_ADDRESS:3333
docker run -d --name=ebusd --network YOUR_NETWORK -p 8888:8888 -p 8008:8008 \
-v /YOUR_PATH/Ebusd/configuration:/etc/ebusd \
-v /YOUR_PATH/Ebusd/scripts:/scripts \
-v /YOUR_PATH/Docker/Ebusd/html:/var/ebusd/html \
-v /etc/timezone:/etc/timezone:ro \
-v /etc/localtime:/etc/localtime:ro john30/ebusd \
--mqtthost=YOUR_MQTT_HOST --mqttport=YOUR_MQTT_PORT --mqttuser=YOUR_MQTT_USER --mqttpass=YOUR_MQTT_PASS \
--mqttjson --mqttint=/etc/ebusd/mqtt-hassio.cfg --mqtttopic=ebusd/%circuit/%name--scanconfig=full --enablehex --configpath=/etc/ebusd \
-d YOUR_DEVICE_DETAILS --latency=10000
