#!/bin/bash
# Installer for IP update
# Victor Manuel Fernandez Castro
# 10 April 2016

# Configuration

I_OWNER="root"
I_GROUP="root"
I_XMODE="755"
I_FMODE="644"
I_SYSTEMD="/etc/systemd/system"
I_SYSVINIT="/etc/init.d"
I_BIN_FILE="noip.sh"
I_SERVICE="noip"
I_UNIT_FILE="$I_SERVICE.service"
I_CONF_DIR="/etc/noip"
I_CONF_FILE="noip_conf"

# Functions

function escape() {
	echo $(echo $1 | sed "s_/_\\\\/_g")
}

# Default values

def_latency=300
def_install="/usr/local/bin"

# User input

echo "This application will install the IP-update daemon."

if [ "$USER" != "root" ]; then
	echo "Please run this script with root permissions."
	exit 1
fi

while [ -z "$noip_user" ]; do
	read -p "  Enter your NoIP username: " noip_user
done

while [ -z "$noip_pass" ]; do
	read -s -p "  Enter your NoIP password: " noip_pass
	echo "********"
done

while [ -z "$noip_host" ]; do
	read -p "  Enter your NoIP hostname: " noip_host
	
	if [ -z "$(echo $noip_host | egrep '^.+\..+\..+' )" ]; then
		echo "Error: a hostname must be in the form x.y.z"
		noip_host=""
	fi
done

while [ -z "$latency" ]; do
	read -p "  Enter the updating frequency [$def_latency]: " latency
	
	if [ -z "$latency" ]; then
		latency=$def_latency
	elif [ -z "$(echo $latency | egrep '^[0-9]+$' )" ]; then
		echo "Error: this value must be numeric"
		latency=""
	fi 
done

while [ -z "$installdir" ]; do
	read -p "  Enter the installation directory [$def_install]: " installdir

	if [ -z "$installdir" ]; then
		installdir=$def_install
	elif [ -z "$(echo $installdir | egrep '^/$|^(/[A-Za-z\._-]+)+$' )" ]; then
		echo "Error: this value must be a path"
		installdir=""
	fi
done

# Determinate whether using Systemd or SysVinit

if [ -n "$(ps -e | egrep ^\ *1\ .*systemd$)" ]; then
	SYSTEM="systemd"
elif [ -n "$(ps -e | egrep ^\ *1\ .*init$)" ]; then
	SYSTEM="sysvinit"
else
	echo "Unknown booting system"
	exit 1
fi

# Modify config file

echo "USER=$noip_user" > $I_CONF_FILE.tmp
echo "PASSWD=$noip_pass" >> $I_CONF_FILE.tmp
echo "HOST=$noip_host" >> $I_CONF_FILE.tmp
echo "TIME=$latency" >> $I_CONF_FILE.tmp

bin=$(escape "/bin/sh $installdir/noip.sh")

if [ "$SYSTEM" = "systemd" ]; then
	sed "s/^ExecStart=.*/ExecStart=$bin/g" $I_UNIT_FILE > $I_UNIT_FILE.tmp
else
	sed "s/^NOIP=.*/NOIP=\"$bin\"/g" $I_SERVICE > $I_SERVICE.tmp
fi

# Install files

if ! [ -d $installdir ]; then
	install -d -m $I_XMODE -o $I_OWNER -g $I_GROUP $installdir
fi

install -m $I_XMODE -o $I_OWNER -g $I_GROUP $I_BIN_FILE $installdir/$I_BIN_FILE
rm -f noip.sh.tmp

if ! [ -d $I_CONF_DIR ]; then
	install -d -m $I_XMODE -o $I_OWNER -g $I_GROUP $I_CONF_DIR
fi

install -m $I_FMODE -o $I_OWNER -g $I_GROUP $I_CONF_FILE.tmp $I_CONF_DIR/$I_CONF_FILE

if [ "$SYSTEM" = "systemd" ]; then
	install -m $I_FMODE -o $I_OWNER -g $I_GROUP $I_UNIT_FILE.tmp $I_SYSTEMD/$I_UNIT_FILE
	systemctl enable $I_SERVICE
	systemctl daemon-reload
	systemctl start $I_SERVICE
	rm -f $I_UNIT_FILE.tmp
else
	install -m $I_XMODE -o $I_OWNER -g $I_GROUP $I_SERVICE.tmp $I_SYSVINIT/$I_SERVICE
	insserv $I_SERVICE
	service start $I_SERVICE
	rm -f $I_SERVICE.tmp
fi

echo "Daemon installed successfully. Please check the status running:"

if [ "$SYSTEM" = "systemd" ]; then
	echo "  systemctl status $I_SERVICE"
else
	echo "  service $I_SERVICE status"
fi
