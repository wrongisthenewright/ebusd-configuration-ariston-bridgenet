# ebusd-configuration-ariston-bridgenet
Ebusd Configuration file for Ariston/Chaffoteaux/Elco Bridgenet Bus

This repository contains a work in progress CSV configuraiton file for Ebusd (https://github.com/john30/ebusd)

Requirements:
- working installation of Ebusd
- adapter to access bus data (see https://github.com/john30/ebusd/wiki/6.-Hardware)
- basic knowledge of the boiler/heatpump wiring to access bus 

For Ebusd I personally use Docker since I already have other aplication running on it, so it's been simple to setup. You need to configure Ebusd with the option requided for your setup (MQTT parameters, adapter details fitting your environment). You can find the run script I use in the script folder, it's specific for my installation, if you plan to use it you need to adapt it's settings.

BEWARE: connecting external device to your heating system may void warranty and cause malfunctions, hte HVAC system runs with you home electrc grid power, be really,really, really carefull!

As an adapter I use this: https://lectronz.com/products/ebus-to-wifi-adapter. 
It's cheap, small and simple to use since it's powered directly by the bus, avoiding the necessity of external power adapter and being electrically isolated, I managed to wire it near the boiler/energy manager, but be careful: you need to balance some aspects, latency, wifi signal, number of device present on the bus line used.
I struggled to set it up correctly, you need to find the correct polarity of the cables since Bridgenet is 0-24v powered so inverting the cables may be required. I started with the adapter near the remote interface (Sensys+Light GW) but the cable lenght from the energy manager and the device already powered by that ebus port caused random bus reconfigurations and errors, I moved the adapter near the boiler where I connected the wires directy at the boiler ebus port,this solved the issue but can cause latency issues with the bus (Ebusd-->wifi-->Esp32-->bus-->esp32-->wifi-->Ebusd).
The adapter I choose has a potentiometer that need to be carefully trimed to your specific environment as explained in details here: https://github.com/john30/ebusd/wiki/6.-Hardware#adjusting-the-potentiometer.

I followed this procedure:
1) set up Ebusd
2) leave empty the config folder
3) remove power to the HVAC system
4) connect the adapter
5) restore power to the HVAC
6) configure adapter wifi (the adapter create automatically an hot spot at first power on, connect to it and set up your wifi)
7) Start Ebus in signal test mode (see link above on adjusting the potentiometer)
8) set the potentiometer setting
9) loose a lot of time getting the correct setting
10) loose another lot of time retrying :)
11) once happy with the potentiometer stop ebusd
12) copy ariston.csv on the ebusd config folder
13) start ebusd with standard settings
14) knock on wood/cross your fingers






