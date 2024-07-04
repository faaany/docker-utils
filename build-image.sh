#!/bin/bash

device="$1"
task="$2"

cd $device

docker build \
	-f Dockerfile.${task} . \
	--build-arg http_proxy=${http_proxy} \
	--build-arg https_proxy=${https_proxy} \
	--build-arg no_proxy=${no_proxy} \
	-t fanli/${task}-${device}
