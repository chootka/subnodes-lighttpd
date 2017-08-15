#!/bin/bash
# /etc/init.d/subnodes_ap
# starts up node.js app, access point interface, hostapd, and dnsmasq for broadcasting a wireless network with captive portal

### BEGIN INIT INFO
# Provides:          subnodes_ap
# Required-Start:    dbus
# Required-Stop:     dbus
# Should-Start:	     $syslog
# Should-Stop:       $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Subnodes Access Point
# Description:       Subnodes Access Point script
### END INIT INFO

NAME=subnodes_ap
DESC="Brings up wireless access point for connecting to web server running on the device."
DAEMON_PATH="/home/pi/subnodes"
PIDFILE=/var/run/$NAME.pid

# get first PHY WLAN pair
readarray IW < <(iw dev | awk '$1~"phy#"{PHY=$1}; $1=="Interface" && $2~"wlan"{WLAN=$2; sub(/#/, "", PHY); print PHY " " WLAN}')

IW0=( ${IW[0]} )

PHY=${IW0[0]}
WLAN0=${IW0[1]}

echo $PHY $WLAN0 > /tmp/ap.log

	case "$1" in
		start)
			echo "Starting $NAME access point on interfaces $PHY:$WLAN0..."

			# associate the access point interface to a physical devices
			ifconfig $WLAN0 down
			# put iface into AP mode
			iw phy $PHY interface add $WLAN0 type __ap

			# add access point iface to our bridge
			if [[ -x /sys/class/net/br0 ]]; then
				brctl addif br0 $WLAN0
			fi

			# bring up access point iface wireless access point interface
			ifconfig $WLAN0 up

			# start the hostapd and dnsmasq services
			service dnsmasq start
			hostapd -B /etc/hostapd/hostapd.conf
			service lighttpd start
			;;
		status)
		;;
		stop)

			ifconfig $WLAN0 down

			# delete access point iface to our bridge
			if [[ -x /sys/class/net/br0 ]]; then
				brctl delif br0 $WLAN0
			fi

			/etc/init.d/hostapd stop
            service dnsmasq stop
            service lighttpd stop
		;;

		restart)
			$0 stop
			$0 start
		;;

*)
		echo "Usage: $0 {status|start|stop|restart}"
		exit 1
esac
