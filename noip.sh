# /usr/local/bin/noip.sh
# Victor Manuel Fernandez Castro
# 2 October 2015

################################################################################

# Configuration file
CONF_FILE="/etc/noip/noip_conf"

# PID file (for service stopping)
PID_FILE="/run/noip.pid"

################################################################################

oldip=''
echo $$ > $PID_FILE

if ! [ -f $CONF_FILE ]; then
    echo "Error: No such file $CONF_FILE"
    exit 1
fi

. $CONF_FILE

ip=$(curl -sG "ip1.dynupdate.no-ip.com")

if [ "$ip" != "$LAST_IP" ]; then
    resp=$(curl -sG "$USER:$PASSWD@dynupdate.no-ip.com/nic/update?hostname=$HOST&myip=$ip" | tr -d '\r')

    if ! ([ "$resp" = "good $ip" ] || [ "$resp" = "nochg $ip" ]); then
        echo "Error: $resp"
        exit 1
    fi

    sed -i "s/^LAST_IP=.*/LAST_IP=$ip/g" $CONF_FILE
    echo "IP updated to $ip"
fi
