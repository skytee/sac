# SAC - Serial Access Concentrator
This project makes a number of devices that have a serial console port for management available over the network.
I like the Opengear CM7100 Console Servers. This is a budget alternative.

## Table of contents
* [General info](#general-info)
* [Requirements](#requirements)
* [Setup](#setup)

## General Info
This is a script that acts as a serial access concentrator, i.e. it makes a number of local serial ports accessible via SSH. It leverages on-board technologies, such as SSH for secure access and udev for device management.

Besides port 22 the SSH daemon is configured to also listen on port 4000 and above. The user logs in, and depending on the port the user selected the script selects a serial port.

This will connect to the first serial port
```
ssh -p4000 user@host 
```
This will connect to the second serial port
```
ssh -p4001 user@host 
```
And so on, while this will connect to a regular shell
```
ssh user@host 
```

On successful login, a hook in the user's .bashrc (or equivalent) will call a script. The script checks if the login originated from an SSH session. If true, it will evaluate the incoming TCP port of that session. It will look up the TCP port in a configuration file. If the script finds a mapped serial port for the incoming TCP port, it will open a screen session, otherwise it will exit.

The mapping of TCP port to serial port, along with baudrate and a comment, is stored in a configuration file: serialports.json
```
	{
			"port": "4000",
			"device": "/dev/ttySLAB0",
			"baudrate": "115200",
			"comment": "#A9J7NQ5D iLO"
	},
	{
			"port": "4001",
			"device": "/dev/ttySLAB1",
			"baudrate": "115200",
			"comment": "#AL02JQ1T iLO"
	},
```

## Requirements
* jq - Command-line JSON processor
* If you're using USB-serial cables, I recommend getting those an FTDI chip, because these have a serial numbers. The serial number makes it possible to uniquely identify a USB-serial cable and further the device that is attached to it.


## Setup


### Configure SSH Daemon
Configure the SSH Daemon to listen on more ports. Edit /etc/sshd/sshd_config and add a number of ports like so:
```
Port 22
Port 4000
Port 4001
Port 4002
Port 4003
Port 4004
Port 4005
Port 4006
```

### Configure udev
The udev daemon helps getting a static mapping between selected TCP port and device we're trying to connect to. When using USB-serial cables we use the serial number of each cable to identify it across reboots. 
```
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="A9J7NQ5D", SYMLINK+="ttySLAB0"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="AL02JQ1T", SYMLINK+="ttySLAB1"
```
* Copy the file `70-serial-port.rules` to `/etc/udev/rules.d/`
* Edit t: adapt the serial numbers to match your cables
* Restart the udev daemon.

### Copy script and configuration
Copy `connect.sh` into a place where the user stores executables, e.g. `~/bin/connect.sh`
Copy `serialports.json` to the user's home.

### Add hook to bashrc
Add the call to the script to the beginning of `~/.bashrc` (or equivalent), e.g.
```
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

. ~/bin/connect.sh
```


