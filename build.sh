#!/bin/bash
export LATEST_IMAGE=$(curl -s https://www.raspberrypi.org/software/operating-systems/ | egrep -o 'https?://[^"]+' | grep armhf-lite.zip$)
cat ./raspios*.json | \
jq '.builders[].file_urls[] = env.LATEST_IMAGE' | \
jq '.builders[].file_checksum_url = "\(env.LATEST_IMAGE).sha256"' | \
jq '.builders[].image_path = "mediastreampi-raspios-arm64.img"' | \
jq '.builders[].image_size = "2G"' | \
jq '.builders[].image_build_method = "resize"' | \
jq '.provisioners[.provisioners| length] += {"type": "shell", "script": "gstreamer.sh"}' > latest.os.json 
docker image pull mkaczanowski/packer-builder-arm
time docker run --rm --privileged -v /dev:/dev -v ${PWD}:/build mkaczanowski/packer-builder-arm build latest.os.json
rm latest.os.json
