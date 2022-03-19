#!/bin/bash
/home/pi/bin/Cirrus_listen.sh line line
/home/pi/bin/Record_from_Linein.sh

GST_DEBUG=3
gst-launch-1.0 -e -vvvv \
rpicamsrc bitrate=5000000 preview=true ! \
video/x-h264,width=1280,height=720,framerate=60/1,profile=high ! \
h264parse ! \
queue ! \
flvmux name=mux streamable=true alsasrc device=hw:RPiCirrus ! \
audio/x-raw,rate=44100,channels=2 ! \
queue ! \
voaacenc bitrate=320000 ! \
queue ! \
aacparse ! \
queue ! \
mux. mux. ! \
rtmpsink location="rtmp://192.168.1.100/live/$(hostname) live=1"
