#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly
# gst-rpicamsrc from source
apt-get install -y git autoconf automake libtool pkg-config libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libraspberrypi-dev
git clone https://github.com/thaytan/gst-rpicamsrc /tmp/gst-rpicamsrc
cd /tmp/gst-rpicamsrc
./autogen.sh --prefix=/usr --libdir=/usr/lib/arm-linux-gnueabihf/
make -j$(nproc)
make install
rm -rf /tmp/gst-rpicamsrc
