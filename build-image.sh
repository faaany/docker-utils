#!/bin/bash

# Default variable values
device="xpu"
task="hf-dev"

# Function to display script usage
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help            Display this help message"
 echo " -d, --device          Hardware Device[xpu, cuda]"
 echo " -t, --task            Task Name[hf-dev, trans-ut]"
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
    esac
    shift
  done
}

# Main script execution
handle_options "$@"


cd $device

docker build \
	-f Dockerfile.${task} . \
	--build-arg http_proxy=${http_proxy} \
	--build-arg https_proxy=${https_proxy} \
	--build-arg no_proxy=${no_proxy} \
	-t fanli/${task}-${device}
