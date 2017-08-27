#!/bin/bash

interface=wlan0
wpa_exist=0

# check if the wpa_supplicant is running
wpa_exist=$(ps -e | grep wpa_supplicant | grep -v grep | awk '{ print $1 }')
if [[ $wpa_exist -gt 0 ]]; then
   echo "[error] wpa_supplicant is running now. don't overwrite it."
   echo "please execute <wifi_off.sh> or <kill -9 pid> to terimate the running wpa_supplicant"
   exit
fi

# check if the command line is correct
if [ -z "$1" ]; then
   echo "[error] no input parameter"
   echo "usage: wifi_on.sh wpa_supplicant.conf" 
   exit
fi

# check if the wpa_supplicant.conf is exist
if [ -f "$1" ]; then
   conf=$1
else
   echo "[error] no such file:" $1
   exit
fi

# start wpa_suppliant to connect to wifi ap
sudo wpa_supplicant -B -i $interface -c $conf -Dwext&
echo "connecting..."
sleep 3

# clear the old ip-address and request ip-address from wifi-ap
sudo dhclient $interface -r
sudo dhclient $interface
sleep 3

# check if connection is established.
wlan_ip=$(ifconfig $interface | awk '/inet addr/{print substr($2,6)}')
if [ -z "$wlan_ip" ]; then
   echo "[error] connect failure: don't get ip-address."
   echo "please check if the settings of wpa_supplicant.conf is correct."
else
   echo "[finished] connect success: ip-address<$wlan_ip>"
fi
