#!/bin/bash

# This script acts as a serial access concentrator, i.e. 
# It makes a number of local serial ports accessible via SSH. 
# The serial port is selected based on the TCP port of the incoming SSH connection.
# The mapping of TCP port to serial port is stored in a configuration file: serialports.json
# If the script finds a mapped serial port for the selected TCP port it will open a screen session,
# otherwise it will exit.

declare -r PORT=$(echo $SSH_CLIENT | cut -f 3 -d ' ')
if [ "${PORT:0:3}" == "400" ] ; then 
	readarray -t PARAM < <(jq -r  ".ports[] | select(.port==\"$PORT\")| .device,.baudrate " ${HOME}/serialports.json)
	[ ${#PARAM[@]} -eq 0 ] && exit 0;
	exec screen "${PARAM[0]}" "${PARAM[1]}"
fi
