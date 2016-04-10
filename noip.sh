# /usr/local/bin/noip.sh
# Victor Manuel Fernandez Castro
# 2 October 2015

################################################################################

# NoIP user name and password
USER="user"
PASSWD="password"

# Host name
HOST="hostname"

# Time between checking (seconds)
TIME=300

# PID file (for service stopping)
PIDFILE="/run/noip.pid"

################################################################################

oldip=''
echo $$ > $PIDFILE

while true; do
	ip=$(curl -sG "ip1.dynupdate.no-ip.com")

	if [ "$ip" != "$oldip" ]; then
		resp=$(curl -sG "$USER:$PASSWD@dynupdate.no-ip.com/nic/update?hostname=$HOST&myip=$ip" | tr -d '\r')
		echo "IP updated to $ip"

		if ! ([ "$resp" = "good $ip" ] || [ "$resp" = "nochg $ip" ]); then
			echo "Error. $resp"
			exit 1
		fi

		oldip=$ip
	fi

	sleep $TIME
done

