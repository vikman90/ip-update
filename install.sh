#!/bin/bash
################################################################################
# Installer for IP update
# Victor Manuel Fernandez Castro
# 10 April 2016
#
# Usage:
# ./install.sh [--uninstall]
################################################################################

# Configuration

I_OWNER="root"
I_GROUP="root"
I_XMODE="755"
I_RMODE="600"
I_BIN_FILE="noip.sh"
I_CONF_DIR="/etc/noip"
I_CONF_FILE="noip_conf"
I_CRON_FILE="crontab.tmp"

# Default values

DEF_LATENCY=5
DEF_INSTALL="/usr/local/bin"

# Functions

function escape() {
    echo $(echo $1 | sed "s/\\$2/\\\\\\$2/g")
}

# Help

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "IP-Update application by Vikman."
    echo "Usage: $0 [--uninstall]"
    exit 0
fi

# Test whether user is root

if [ "$USER" != "root" ]; then
    echo "Please run this script with root permissions."
    exit 1
fi

# Uninstall

if [ "$1" = "--uninstall" ]; then
    echo "This application will uninstall the IP-Update application."
    
    # User input
    
    while [ -z "$install_dir" ]; do
        read -p "  Enter the installation directory [$DEF_INSTALL]: " install_dir

        if [ -z "$install_dir" ]; then
            install_dir=$DEF_INSTALL
        elif [ -z "$(echo $install_dir | egrep '^/$|^(/[A-Za-z\._-]+)+$' )" ]; then
            echo "Error: this value must be a path"
            install_dir=""
        fi
    done
    
    # Delete files
    
    rm -f $install_dir/$I_BIN_FILE
    rm -f $I_CONF_DIR/$I_CONF_FILE
    rmdir $I_CONF_DIR
    
    # Remove line from cron
    
    cron_tmp=$(mktemp)

    if [ -z "$cron_tmp" ]; then
        echo "Warning: couldn't create temporary file."
        cron_tmp="crontab.tmp"
    fi

    crontab -l > $cron_tmp 2> /dev/null
    sed -ri "\:^\*/[0-9]+ \* \* \* \* .*$(escape $I_BIN_FILE '.')\$:d" $cron_tmp
    crontab $cron_tmp
    rm -f $cron_tmp
    
    echo "Application uninstalled."
    exit 0
fi

# User input

echo "This application will install IP-Update."

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
    read -p "  Enter the updating frequency (minutes) [$DEF_LATENCY]: " latency

    if [ -z "$latency" ]; then
        latency=$DEF_LATENCY
    elif [ -z "$(echo $latency | egrep '^[0-9]+$' )" ]; then
        echo "Error: this value must be numeric"
        latency=""
    fi
done

while [ -z "$install_dir" ]; do
    read -p "  Enter the installation directory [$DEF_INSTALL]: " install_dir

    if [ -z "$install_dir" ]; then
        install_dir=$DEF_INSTALL
    elif [ -z "$(echo $install_dir | egrep '^/$|^(/[A-Za-z\._-]+)+$' )" ]; then
        echo "Error: this value must be a path"
        install_dir=""
    fi
done

echo "Installing..."

# Create config file

conf_tmp=$(mktemp)

if [ -z "$conf_tmp" ]; then
    echo "Warning: couldn't create temporary file."
    conf_tmp="$I_CONF_FILE.tmp"
fi

echo "USER=$noip_user" > $conf_tmp
echo "PASSWD=$noip_pass" >> $conf_tmp
echo "HOST=$noip_host" >> $conf_tmp
echo "LAST_IP=" >> $conf_tmp

# Install files

if ! [ -d $install_dir ]; then
    install -d -m $I_XMODE -o $I_OWNER -g $I_GROUP $install_dir
fi

install -m $I_XMODE -o $I_OWNER -g $I_GROUP $I_BIN_FILE $install_dir/$I_BIN_FILE

if ! [ -d $I_CONF_DIR ]; then
    install -d -m $I_XMODE -o $I_OWNER -g $I_GROUP $I_CONF_DIR
fi

install -m $I_RMODE -o $I_OWNER -g $I_GROUP $conf_tmp $I_CONF_DIR/$I_CONF_FILE
rm -f $conf_tmp

# Add task to cron

cron_tmp=$(mktemp)

if [ -z "$cron_tmp" ]; then
    echo "Warning: couldn't create temporary file."
    cron_tmp="crontab.tmp"
fi

crontab -l > $cron_tmp 2> /dev/null

if [ -n "$(egrep "^\*/[0-9]+ \* \* \* \* .*$I_BIN_FILE$" $cron_tmp)" ]; then
    sed -ri "s:^\*/[0-9]+ \* \* \* \* .*$(escape $I_BIN_FILE '.')\$:*/$latency * * * * $install_dir/$I_BIN_FILE:g" $cron_tmp
else
    echo "*/$latency * * * * $install_dir/$I_BIN_FILE" >> $cron_tmp
fi

crontab $cron_tmp
rm -f $cron_tmp

echo "Application installed successfully."

$install_dir/$I_BIN_FILE
