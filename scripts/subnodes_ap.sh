#!/bin/sh
# /etc/init.d/subnodes-lighttpd_ap
#
# starts up ap0 interface, dnsmasq and hostapd for broadcasting a wireless network
# Sarah Grant
# Updated 01 Nov 2015

NAME=subnodes_ap
DESC="Brings up wireless access point for connecting to lighttpd web server running on the device."
DAEMON_PATH="/home/pi/subnodes"

PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
WLAN="wlan0"
PHY="phy0"

	case "$1" in
		start)
			echo "Starting $NAME access point..."

			# associate the ap0 interface to a physical devices
			# check to see if wlan1 exists; use that radio, if so.
			FOUND=`iw dev | awk '/Interface/ { print $2}' | grep wlan1`
			if  [ -n "$FOUND" ] ; then
				WLAN="wlan1"
				PHY="phy1"
			fi
			ifconfig $WLAN down
			iw $WLAN del
			ifconfig ap0 down
			iw phy $PHY interface add ap0 type __ap
			ifconfig ap0 up

			# start the hostapd and dnsmasq services
			service hostapd restart
			service dnsmasq restart
			service lighttpd force-reload

			;;
		status)
		;;
		stop)
			printf "%-50s" "Shutting down $NAME…"
			service hostapd stop
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
