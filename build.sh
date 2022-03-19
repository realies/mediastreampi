#!/bin/bash
export LATEST_IMAGE=$(curl -s https://www.raspberrypi.com/software/operating-systems/ | egrep -o 'https?://[^"]+' | grep armhf-lite.zip$ | grep -i oldstable)
cat ./raspios*.json | \
jq '.builders[].file_urls[] = env.LATEST_IMAGE' | \
jq '.builders[].file_checksum_url = "\(env.LATEST_IMAGE).sha256"' | \
jq '.builders[].image_path = "mediastreampi-raspios-arm64.img"' | \
jq '.builders[].image_size = "3G"' | \
jq '.builders[].image_build_method = "resize"' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "script": "gstreamer.sh"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "script": "ffmpeg.sh"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "script": "wm5102.sh"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "inline": "echo \"start_x=1\ngpu_mem=256\" >> /boot/config.txt"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "inline": "touch /boot/ssh"}' | \
jq '.provisioners[.provisioners| length] += {"type": "file", "source": "0-gopro.rules", "destination": "/etc/udev/rules.d/0-gopro.rules"}' | \
jq '.provisioners[.provisioners| length] += {"type": "file", "source": "wpa_supplicant.conf", "destination": "/boot/wpa_supplicant.conf"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "script": "screen.sh"}' | \
jq '.provisioners[.provisioners| length] += {"type": "file", "source": "stream.sh", "destination": "/home/pi/stream.sh"}' | \
jq '.provisioners[.provisioners| length] += {"type": "file", "source": "rc.local", "destination": "/etc/rc.local"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "inline": "chmod +x /home/pi/stream.sh /etc/rc.local"}' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "inline": "chown pi:pi /home/pi/stream.sh"}' \
> latest.os.json
docker image pull mkaczanowski/packer-builder-arm
time docker run --rm --privileged -v /dev:/dev -v ${PWD}:/build mkaczanowski/packer-builder-arm build latest.os.json
rm latest.os.json

# jq '."post-processors" = [{"type": "flasher", "device": "/dev/disk2", "block_size": "4096", "interactive": true }]'
