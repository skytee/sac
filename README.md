# SAC - Serial Access Concentrator

## General Info
This script acts as a serial access concentrator, i.e. it makes a number of local serial ports accessible via SSH. It makes a number of devices that have a serial console port for management available over the network.

This is facilitated by the SSH daemon also listing on port 4000 and above.
The serial port is then selected based on the TCP port of the incoming SSH connection.

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

A hook in the user's .bashrc will call a script after successful login. The script checks if the login originated from an SSH session. If true, it will evaluate the incoming TCP port of that session. If the script finds a mapped serial port for the incoming TCP port, it will open a screen session, otherwise it will exit.

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
* If you're using USB-serial cables, get some with an FTDI chip, because these all have a serial number. The serial number makes it possible to uniquely identify a USB-serial cable and further the device that is attached to it.


## Setup


### Configure SSH Daemon
Configure the SSH Daemon to listen on more ports than just 22. Edit /etc/sshd/sshd_config and add a number of ports like so:
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
* Edit the file: adapt the serial numbers
* Restart the udev daemon.

### Copy script and configuration
Copy `connect.sh` into a place where the user stores executables, e.g. `~/bin/connect.sh`
Copy `serialports.json` to the user's home.

### Add hook to bashrc
Add the call to the script to the beginning of bashrc, e.g.
```
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

. ~/bin/connect.sh
```


