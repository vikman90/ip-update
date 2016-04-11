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

# Modify sources

noip_pass=$(escape "$noip_pass")
sed "s/^USER=.*/USER=\"$noip_user\"/g" noip.sh > noip.sh.tmp
sed -i "s/^PASSWD=.*/PASSWD=\"$$noip_pass\"/g" noip.sh.tmp
sed -i "s/^HOST=.*/HOST=\"$noip_host\"/g" noip.sh.tmp
sed -i "s/^TIME=.*/TIME=$latency/g" noip.sh.tmp

bin=$(escape "/bin/sh $installdir/noip.sh")

if [ "$SYSTEM" = "systemd" ]; then
	sed "s/^ExecStart=.*/ExecStart=$bin/g" noip.service > noip.service.tmp
else
	sed "s/^NOIP=.*/NOIP=\"$bin\"/g" noip > noip.tmp
fi

# Install files

if ! [ -d $installdir ]; then
	install -d -m $I_XMODE -o $I_OWNER -g $I_GROUP $installdir
fi

install -m $I_XMODE -o $I_OWNER -g $I_GROUP noip.sh.tmp $installdir/noip.sh
rm -f noip.sh.tmp

if [ "$SYSTEM" = "systemd" ]; then
	install -m $I_FMODE -o $I_OWNER -g $I_GROUP noip.service.tmp $I_SYSTEMD/noip.service
	systemctl enable noip
	systemctl daemon-reload
	systemctl start noip
	rm -f noip.service.tmp
else
	install -m $I_XMODE -o $I_OWNER -g $I_GROUP noip.tmp $I_SYSVINIT/noip
	insserv noip
	service start noip
	rm -f noip.tmp
fi

echo "Daemon installed successfully. Please check the status running:"

if [ "$SYSTEM" = "systemd" ]; then
	echo "  systemctl status noip"
else
	echo "  service noip status"
fi

