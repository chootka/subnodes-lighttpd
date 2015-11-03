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
PHY="phy0"

	case "$1" in
		start)
			echo "Starting $NAME access point..."

			# associate the ap0 interface to a physical devices
			# check to see if wlan1 exists; use that radio, if so.
			FOUND=`iw dev | grep phy#1`
			if  [ -n "$FOUND" ] ; then
				#WLAN="wlan1"
				PHY="phy1"
			fi
			
			# delete wlan0 and wlan1, if they exist
			WLAN0=`iw dev | awk '/Interface/ { print $2}' | grep wlan0`
			if [ -n "$WLAN0" ] ; then
				ifconfig $WLAN0 down
				iw $WLAN0 del
			fi

			WLAN1=`iw dev | awk '/Interface/ { print $2}' | grep wlan1`
			if [ -n "$WLAN1" ] ; then
				ifconfig $WLAN1 down
				iw $WLAN1 del
			fi

			# assign ap0 to the hardware device found
			ifconfig ap0 down
			iw phy $PHY interface add ap0 type __ap
			ifconfig ap0 up

			# start the hostapd and dnsmasq services
			service hostapd start
			service dnsmasq start
			service lighttpd start

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
