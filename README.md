ebusd-configuration-ariston-bridgenet
# Ebusd Configuration file for Ariston/Chaffoteaux/Elco Bridgenet Bus

This repository contains a work in progress CSV configuration file for Ebusd (https://github.com/john30/ebusd)

##I'm not a software developer, so I'm a noob on github, I can make mistake on publishing new releases etc.

## Requirements:
- working installation of Ebusd
- adapter to access bus data (see https://github.com/john30/ebusd/wiki/6.-Hardware)
- basic knowledge of the boiler/heatpump wiring to access bus 

For Ebusd I personally use Docker since I already have other applications running on it, it's been simpler to setup. 
You need to configure Ebusd with the option requided for your environment (MQTT parameters, adapter details fitting your device). You can find the run script I use in the script folder, it's specific for my installation, if you plan to use it you need to adapt it's settings.

**BEWARE:**  connecting external device to your heating system may void warranty and cause malfunctions, the HVAC system runs with power grid voltages, be really,really, really carefull! Also consider that adding custom circuit to your system may void your warranty, be aware of this issue and use my configuration and advices at your own risk.

As an adapter I now use the "official" ebusd adapter from John, I switched from my previous adapter as I had an old version of Daniel's adapter that didn't "natively" support external power, I had some problem with bus power and choose to switch to John's adapter that has a USB port to power the shield. I've noticed that Daniel's adapter last version does indeed have the USB port to power the adapter indipendently from the bus. 

If using the latest John's version of the adapter you can simply connect it to the bus, power it via USB and it should activate the built in AP, connect to this wifi and configure the adapter (http://192.168.4.1), it's really smooth and, once joined to your router's SSID find it's IP and connect to it.
Pay attention on which protocol you chose (standard or enhanced) as it need to be reflected on ebusd configuration as well.

I'm leaving this paragraph in case someone choose to use Daniel's adapter (https://lectronz.com/products/ebus-to-wifi-adapter). 
It's cheap, small and simple to use since it's powered directly by the bus, avoiding the necessity of external power adapter and being electrically isolated, I managed to wire it near the boiler/energy manager, but be careful: you need to balance some aspects, latency, wifi signal, number of device present on the bus line used are the primary ones.
I struggled to set it up correctly, you need to find the correct polarity of the cables, since Bridgenet is 0-24v powered, so inverting the cables may be required. I started with the adapter near the remote interface (Sensys+Light GW) but the cable lenght from the energy manager and the devices already powered by that ebus port caused tension loss, random bus reconfigurations and errors; I moved the adapter near the boiler where I connected the wires directy at the boiler ebus port,this solved the issue but can cause latency errors with the bus (Ebusd-->wifi-->Esp32-->bus-->esp32-->wifi-->Ebusd), I blindily increased the ebusd latency parameter and added reading and writing retries to avoid most of the problems.
The adapter I choose has a potentiometer that need to be carefully trimemd to your specific environment as explained in details here:  https://github.com/danielkucera/esp8266-arduino-ebus

I followed this procedure (specific for Daniel Kucera adapter, may be tweaked for other wifi/ethernet adapter):
1) set up Ebusd
2) leave empty the config folder
3) remove power to the HVAC system
4) connect the adapter
5) restore power to the HVAC
6) configure adapter wifi (the adapter create automatically an hot spot at first power on, connect to it and set up your wifi), the device will reboot and join the wifi network
7) find the adapter IP address (ping esp-ebus.local should do, if it does't work connect to you wifi AP/Router and search in the list of connected devices)
8) Start Ebusd in signal test mode (see here: https://github.com/john30/ebusd/wiki/6.-Hardware#adjusting-the-potentiometer)
9) set the potentiometer setting
10) loose a lot of time getting the correct setting
11) loose another lot of time retrying :)
12) once happy with the potentiometer configuration, stop ebusd
13) copy ariston.csv on the ebusd config folder
14) start ebusd with standard settings
15) knock on wood/cross your fingers

Since Bridgenet (Ariston Group ebus implementation) uses PBSB specific commands to read and write the data the configuration as of now is configured mainly for read operations, albeit with many direct ask instructions (a direct ask instruction actually write on the bus to request a device to answer back some parameter/settings).
Many if not all the data are broadcasted on regular basis on the bus by the various device connected, It should be possible to get the same values simply sniffing the traffic, ATM I read from broadcasted messages most of the common parameters and set a cron script to read the parameters not broadcasted but interesting to my use case (see read_custom.sh script, it's a quick and dirty solution but it serves my needs).


## Added Writing lines to change system parameters

In the CSV tere are now many lines enabling the writing of system patameters/settings. ATM I've added the ones more interesting in my use case, thus permitting to:
- enable/disable operating modes (Cooling, Heating, DHW, Climatic Thermoregulation) 
- change Day, Night temp
- change climatic thermoregulation parametes (slope, offset, room temp infl., LWTmin, LWTmax)
- change Hybrid sysytem energy costs (gas/electric)

The CSV lines for those parameters are now primarily coded for Home Assistant integration via MQTT but with some simple thinkering should be possible to adapt it to other domotic applications.

Eg. these 3 lines allow to change the operating mode of the system, thus activating dhw production, cooling and heating

```
w,sensys,heating_status_w,Heating Status,,fe,2020,0120,,s,onoff
w,sensys,dhw_status_w,Heatig Status,,fe,2020,0220,,s,onoff
w,sensys,cooling_status_w,Cooling Status,,fe,2020,0f23,,s,onoff
```

these need a string argument to set the desired setting "off" or "on", so writing an "on" in the cooling_status_w command activate the cooling mode, all the other settings (temps, cooling logic etc.) must be set in advance. You could also change these params integrating ebusd with MQTT and sending a MQTT message to these topics:

```
ebusd/sensys/heating_status_w/set
ebusd/sensys/dhw_status_w/set
ebusd/sensys/cooling_status_w/set
```

with "on" or "off" will activate/deactivate the desired feature. If using HA automations to publish MWTT messages to change parameters you can use also the numeric form, 0 for OFF 1 for ON, this is also valid for multiple choice parameters.


**BEWARE:** I have tested these changes only with my system, use it at your own risk. I've had no error and the settings change are detected by the HVAC systems and are reflected on the thermostat (sensys for Ariston brand) and on the remote thermo website so the system is accepting these commands. Pay attention on the firsts uses to ebusd logs for arbitration loss or other errors, adding some latency and retry parameters to ebusd command line/docker run chould mitigate/solve the problem. 
**BEWARE2:** I have added upon request the writing lines also for Z2 and Z3, but I haven't been able to test these as I have a single zone system
 
**NOTE FOR HOME ASSISTANT INTEGRATION:** All writing rules added to the CSV (the one above and the ones related to the most frequently modified parameters), are unavailable in HA until you edit the mqtt-hassio.cfg line related to filtering the data direction:

the line:
`filter-direction = r|u`

should be modified as follow:

`filter-direction = r|u|^w`

I've added version of my mqtt-hassio.cfg file, that has the write filter removed and with other minor changes to map correctly ebusd data in HA

**ANOTHER IMPORTANT NOTE:** you MUST impose correct limits and stepping on the input variables in HA to avoid sending on the bus wrong/unsupported values (eg. temp of 21,33333333°C where the stepping is 0.1 or 0.5 degrees), otherwise the system may fallback to some default value upon writing the wrong value parameter.
The limits and the stepping should be set following the HVAC installer manual for the specific configuration (eg. the tmin and Tmax are for an underfloor heating configuration). 
To impose those limits I use this section of the configuration.yaml in HA:

```
homeassistant:
.....
  customize:
.....
    number.ebusd_energymgr_z1_heat_offset:
      name: Z1 Heat Offset
      min: -7
      max: 7
      step: 1
      mode: box
    number.ebusd_energymgr_z1_heat_slope:
      name: Z1 Heat Slope
      min: 0.2
      max: 1
      step: 0.1
      mode: box
    number.ebusd_energymgr_z1_day_temp:
      name: Z1 Day Temp
      min: 10
      max: 30
      step: 0.5
      mode: box
    number.ebusd_energymgr_z1_night_temp:
      name: Z1 Night Temp
      min: 10
      max: 30
      step: 0.5
      mode: box
    number.ebusd_energymgr_electric_cost:
      name: Electric Cost
      min: 0.1
      max: 99.9
      step: 0.1
      mode: box
    number.ebusd_energymgr_gas_cost:
      name: Gas Cost
      min: 0.1
      max: 99.9
      step: 0.1
      mode: box
    number.ebusd_energymgr_z1_heat_room_temp_infl:
      name: Z1 Room Temp Infl
      min: 0
      max: 20
      step: 1
      mode: box
    number.ebusd_energymgr_z1_heat_water_max_temp:
      name: Z1 Heat Max LWT
      min: 20
      max: 45
      step: 1
      mode: box
    number.ebusd_energymgr_z1_heat_water_min_temp:
      name: Z1 Heat Min LWT
      min: 20
      max: 45
      step: 1
      mode: box

```
## Added Error messages decoding

The error messages processing had been decoded (see https://github.com/ysard/ebusd_configuration_chaffoteaux_bridgenet?tab=readme-ov-file#protocol-for-the-errors) with the help of Ysard brute force error detection script I've gathered and translated the error codes bindings in `_template.csv`, the codes are valid for a Genus One Hybrit Net HVAC system (boiler, heatpump, energymanager, wifi gateway and remote control panel), as it seems that the error codes are peculiar for each system configuration my list and template should be adapted for every use on different devices.
You should use the python script to meticulously generate, retreive and reset every error message that your plant support/implement.
In my case I had to increment the max error code value generated in the script to 255, from:

```
    generate_errors(load_results(), end=128, zone_commands=True)
``` 
to
```
    generate_errors(load_results(), end=255, zone_commands=True)
```
in one of the last lines of the script.

## Fixed Bus reset option

I needed a way to start a full discovery process on the bus via Home Assistant input, the solutio was to craft a write line in the CSV 

`w,broadcast,ebus_reset,Reset ebus,,fe,2031,ffffffffffffffffffffffff23fe00,ebus_reset,m,BCD,,,,,,,,,,,,,,,,,,,,,,`

with this line present in the CSV I then added an helper button in HA and added an automation that, on pressing this virtual button, sends a MQTT message to `ebusd/broadcast/ebus_rest/set` with a payload of 20 (but I think that all non-zero values are good). 
This cause a bs discovery process and a full system reset.


## Credits

All the working codes are the result of a fantastic job made by some user of the italian forum energeticambiente.it, many thanks Gruppo and friends!

Some boiler codes came from https://github.com/komw/ariston-bus-bridgenet-ebusd.

The writing rules are inspired by ysard repo https://github.com/ysard/ebusd_configuration_chaffoteaux_bridgenet , from the same repo I've used the error messages brute force discovery script to find the meaning of the codes sent on the bus.



