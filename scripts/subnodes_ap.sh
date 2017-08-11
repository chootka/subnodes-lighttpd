#!/bin/sh
# /etc/init.d/subnodes_ap
# starts up lighttpd, ap0 interface, hostapd, and dnsmasq for broadcasting a wireless network with captive portal

NAME=subnodes_ap
DESC="Brings up wireless access point for connecting to web server running on the device."
DAEMON_PATH="/home/pi/subnodes"
PIDFILE=/var/run/$NAME.pid
PHY="phy1"

	case "$1" in
		start)
			echo "Starting $NAME access point..."

			# associate the ap0 interface to a physical devices
			WLAN1=`iw dev | awk '/Interface/ { print $2}' | grep wlan1`
			if [ -n "$WLAN1" ] ; then
				ifconfig $WLAN1 down
				iw $WLAN1 del

				# assign ap0 to the hardware device found
				iw phy $PHY interface add ap0 type __ap
			fi

			# add ap0 to our bridge
			brctl addif br0 ap0

			# bring up ap0 wireless access point interface
			ifconfig ap0 up

			# start services
			service dnsmasq start
			hostapd -B /etc/hostapd/hostapd.conf
			service lighttpd start
			;;
		status)
		;;
		stop)

			ifconfig ap0 down

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
