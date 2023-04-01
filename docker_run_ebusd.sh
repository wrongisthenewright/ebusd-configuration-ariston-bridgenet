#|/bin/bash
docker stop ebusd
docker rm ebusd

docker pull john30/ebusd

#scanconfig enabled
docker run -d --name=ebusd \
	--network mynetwork \     #Optional, to allow docker name resolution between containers
	-p 8888:8888 \
	-p 8008:8008 \
	-v /..../Ebusd/configuration:/etc/ebusd \   
	-v /..../Docker/Ebusd/scripts:/scripts \       #Optional, this allows me to execute script directly inside the container
	-v /..../Docker/Ebusd/html:/var/ebusd/html \   #unused Ebusd Website feature
	-v /etc/timezone:/etc/timezone:ro \
	-v /etc/localtime:/etc/localtime:ro \
	john30/ebusd:latest \
	--mqtthost=mosquitto \           #here use the MQTT server IP address, here I can use docker name using the --network docker feature
	--mqttport=1883 \
	--mqttuser=USERNAME \
	--mqttpass=PASSWORD \
	--mqttjson \
	--mqttint=/etc/ebusd/mqtt-hassio.cfg \
	--mqtttopic=ebusd/%circuit/%name \
	--enablehex \
	--configpath=/etc/ebusd \
	-d x.x.x.x:3333 \    #Adapt this to your device IP or serial port
	--receivetimeout=5000 \
	--latency=20000 \
	--pollinterval=30 \
	--sendretries=10 \
	--acquireretries=5 \
	--acquiretimeout=20 \
	--log=all:error
