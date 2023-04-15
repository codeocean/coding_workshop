#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  set_log_msg "No arguments supplied to capsule" "info"
else
  set_log_msg "Capsule args: $*" "info"
fi

# if $1 (the first command line argument) is not supplied
# then assign the value of $cpus using the get_cpu_count 
# command, otherwise assign the value of $cpus using $1
if [ -z $1 ]; then
  cpus=$(get_cpu_count)
else
  cpus="${1}"
fi

if [ -z $2 ]; then
  compression=6
else
  compression="${2}"
fi