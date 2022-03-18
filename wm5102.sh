#!/bin/bash
if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root"
 exit 1
fi

rpi-update

if ! grep -q "#dtparam=audio=on" /boot/config.txt; then
 echo "Disabling on-board audio..."
 sed -i "/^dtparam=audio=on/s/^/#/g" /boot/config.txt
else
 echo "On-board audio already disabled..."
fi

if ! grep -q "dtoverlay=rpi-cirrus-wm5102" /boot/config.txt; then
 echo "Enabling WM5102 audio..."
 echo "# Enable WM5102 audio" >> /boot/config.txt
 echo "dtoverlay=rpi-cirrus-wm5102" >> /boot/config.txt
else
 echo "WM5102 already enabled..."
fi

if ! grep -qs "softdep arizona-spi pre: arizona-ldo1" /etc/modprobe.d/cirrus.conf; then
 echo "Defining module dependencies..."
 echo "softdep arizona-spi pre: arizona-ldo1" > /etc/modprobe.d/cirrus.conf
else
 echo "Module dependencies already defined..."
fi

if [[ ! -d "/home/pi/bin" ]]; then
 cd /home/pi
 echo "Downloading use-case scripts..."
 wget http://www.horus.com/~hias/tmp/cirrus/cirrus-ng-scripts.tgz
 mkdir bin
 cd bin
 tar zxf ../cirrus-ng-scripts.tgz
 rm ../cirrus-ng-scripts.tgz
 chown pi:pi /home/pi/bin
else
 echo "Use-case scripts folder already exists..."
fi
