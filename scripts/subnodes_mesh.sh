#!/bin/sh
# /etc/init.d/subnodes-lighttpd_mesh
#
# starts up mesh0, bat0, br0 interfaces
# Sarah Grant
# Updated 01 Nov 2015

NAME=subnodes_mesh
DESC="Brings our BATMAN-ADV mesh point up."
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
WLAN="wlan0"
PHY="phy0"

	case "$1" in
		start)
			echo "Starting $NAME mesh point..."

			# associate the mesh0 interface to a physical device
			ifconfig $WLAN down
			iw $WLAN del
			iw phy $PHY interface add mesh0 type adhoc
			ifconfig mesh0 down
			ifconfig mesh0 mtu 1532
			iwconfig mesh0 mode ad-hoc essid SSID channel CHAN
			sleep 1
			iwconfig mesh0 ap CELL_ID 

			# bring down interfaces and bridge
			ifconfig br0 down
			ifconfig mesh0 down
			ifconfig bat0 down

			# add the interface to batman
			batctl if add mesh0
			batctl ap_isolation 1

			# bring up the BATMAN adv interfaces and bridge
			ifconfig mesh0 up
			ifconfig bat0 up
			ifconfig br0 up
			;;
		status)
			batctl o
		;;
		stop)
			# bring down interfaces and bridge
			ifconfig bat0 down
			batctl if del mesh0
			ifconfig mesh0 mtu 1500
			iwconfig mesh0 mode managed
		;;

		restart)
			$0 stop
			$0 start
		;;

*)
		echo "Usage: $0 {status|start|stop|restart}"
		exit 1
esac
