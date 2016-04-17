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

. $CONF_FILE

while true; do
	ip=$(curl -sG "ip1.dynupdate.no-ip.com")

	if [ "$ip" != "$oldip" ]; then
		resp=$(curl -sG "$USER:$PASSWD@dynupdate.no-ip.com/nic/update?hostname=$HOST&myip=$ip" | tr -d '\r')

		if ! ([ "$resp" = "good $ip" ] || [ "$resp" = "nochg $ip" ]); then
			echo "Error. $resp"
			exit 1
		fi

		oldip=$ip
		echo "IP updated to $ip"
	fi

	sleep $TIME
done

