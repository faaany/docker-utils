#!/bin/bash

device="$1"
task="$2"
workspace="$3"

docker run -it \
	--privileged \
	-e http_proxy=${http_proxy} \
	-e https_proxy=${https_proxy} \
	-e no_proxy=${no_proxy} \
	-v ${HF_HOME}:/root/.cache/huggingface \
	-v ${workspace}:/workspace \
	-w /workspace \
	--runtime=nvidia \
	--gpus all \
	--entrypoint /bin/bash \
	--name ${task} \
	fanli/${task}-${device}:latest
