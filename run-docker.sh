#!/bin/bash

# Default variable values
device="xpu"
task="hf-dev"
workspace=${PWD}
name="hf-dev"

# Function to display script usage
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help            Display this help message"
 echo " -d, --device          Hardware Device[xpu, cuda]"
 echo " -t, --task            Task Name[hf-dev]"
 echo " -w, --workspace       The local directory to be mounted inside the container"
 echo " -n, --name            The container name"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -d | --device*)
        if ! has_argument $@; then
          echo "Device name not specified." >&2
          usage
          exit 1
        fi

        device=$(extract_argument $@)

        shift
        ;;
      -t | --task*)
        if ! has_argument $@; then
          echo "Task name not specified." >&2
          usage
          exit 1
        fi

        task=$(extract_argument $@)

        shift
        ;;
      -w | --workspace)
        workspace=$(extract_argument $@)
        shift
        ;;
      -n | --name)
        name=$(extract_argument $@)
        shift
        ;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"


if [[ $device == "cuda" ]]; then
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
		--name ${name} \
		fanli/${task}-${device}:latest
elif [[ $device == "xpu" ]]; then
	docker run -it \
		--privileged  \
		-e http_proxy=${http_proxy} \
		-e https_proxy=${https_proxy} \
		-e no_proxy=${no_proxy} \
		-v ${HF_HOME}:/root/.cache/huggingface \
		-v ${workspace}:/workspace \
		-w /workspace \
		--device=/dev/dri \
		--ipc=host \
		--entrypoint /bin/bash \
		--name ${name} \
		fanli/${task}-${device}:latest

else
	echo "the given device is not supported."
fi
