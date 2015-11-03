#! /bin/bash
#
# Raspberry Pi network configuration / AP, MESH install script
# Light webserver instructions taken from http://www.penguintutor.com/linux/light-webserver
# Sarah Grant
# Updated 01 Nov 2015
#
# TO-DO
# - allow a selection of radio drivers
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SOME DEFAULT VALUES
#
# WIRELESS RADIO DRIVER
RADIO_DRIVER=nl80211

# ACCESS POINT
AP_COUNTRY=US
AP_SSID=subnodes
AP_CHAN=1
AP_IP=192.168.3.1
AP_NETMASK=255.255.255.0

# DNSMASQ STUFF
DHCP_START=192.168.3.101
DHCP_END=192.168.3.254
DHCP_NETMASK=255.255.255.0
DHCP_LEASE=1h

# FLAGS
DO_SET_MESH=Nn

# BRIDGE
BRIDGE_IP=192.168.3.1
BRIDGE_NETMASK=255.255.255.0

# MESH POINT
MESH_SSID=meshnode
MESH_CHAN=3
CELL_ID=02:12:34:56:78:90

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CHECK USER PRIVILEGES
(( `id -u` )) && echo "This script must be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# BEGIN INSTALLATION PROCESS
#
echo "////////////////////////////////////////////////"
echo "// Welcome to Subnodes with lighttpd installed!"
echo "//"
echo ""

read -p "This installation script will install a lighttpd / php / mysql server and a wireless access point, and will give you the option of additionally configuring a BATMAN-ADV mesh point. Make sure you have one or two USB wifi radios connected to your Raspberry Pi before proceeding. Press any key to continue..."
echo ""
#
# CHECK USB WIFI HARDWARE IS FOUND
# also, i will need to check for one device per network config for a total of two devices
#if [[ -n $(lsusb | grep RT5370) ]]; then
#    echo "The RT5370 device has been successfully located."
#else
#    echo "The RT5370 device has not been located, check it is inserted and run script again when done."
#    exit 1
#fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SOFTWARE INSTALL
#
# update the packages
echo "Updating apt-get and installing iw package for network interface configuration..."
apt-get update && apt-get install -y iw lighttpd mysql-server php5-common php5-cgi php5 php5-mysql
lighty-enable-mod fastcgi-php
service lighttpd force-reload
# Change the directory owner and group
chown www-data:www-data /var/www
# allow the group to write to the directory
chmod 775 /var/www
# Add the pi user to the www-data group
usermod -a -G www-data pi
echo ""

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CONFIGURE A MESH POINT?
#
clear
echo "////////////////////////////////////////"
echo "// Access Point + Mesh Point Settings"
echo "// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "Please answer the following questions. Hitting return will continue with the default 'No' option"
echo ""
read -p "Do you wish to continue and set up your Raspberry Pi as a Mesh Point? [N] " yn
DO_SET_MESH=$yn

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CONFIGURE AN ACCESS POINT WITH CAPTIVE PORTAL + MESH POINT IF SELECTED
#
echo ""

# check that iw list does not fail with 'nl80211 not found'
echo -en "checking that nl80211 USB wifi radio is plugged in...				"
iw list > /dev/null 2>&1 | grep 'nl80211 not found'
rc=$?
if [[ $rc = 0 ]] ; then
	echo -en "[FAIL]\n"
	echo "Make sure you are using a wifi radio that runs on the nl80211 driver."
	exit $rc
else
	echo -en "[OK]\n"
fi

# install required packages
echo ""
case $DO_SET_MESH in
	[Yy]* )
		clear
		echo "Configuring Raspberry Pi with access point and mesh point..."
		echo -en "Installing bridge-utils, batctl, hostapd and dnsmasq... 			"
		apt-get install -y bridge-utils hostapd dnsmasq batctl
		echo "Enabling the batman-adv kernel..."
		# add the batman-adv module to be started on boot
		sed -i '$a batman-adv' /etc/modules
		modprobe batman-adv;
		echo ""
	;;

	[Nn]* ) clear
		echo "Configuring Raspberry Pi with access point only..."
		echo -en "Installing hostapd and dnsmasq... 			"
		apt-get install -y hostapd dnsmasq
	;;
esac
echo -en "[OK]\n"

# ask how they want to configure their access point
read -p "Wifi Country [$AP_COUNTRY]: " -e t1
if [ -n "$t1" ]; then AP_COUNTRY="$t1";fi

read -p "Wifi Channel Name [$AP_CHAN]: " -e t1
if [ -n "$t1" ]; then AP_CHAN="$t1";fi

read -p "Wifi SSID [$AP_SSID]: " -e t1
if [ -n "$t1" ]; then AP_SSID="$t1";fi

case $DO_SET_MESH in
	[Nn]* )
		read -p "AP IP [$AP_IP]: " -e t1
		if [ -n "$t1" ]; then AP_IP="$t1";fi

		read -p "AP NETMASK [$AP_NETMASK]: " -e t1
		if [ -n "$t1" ]; then AP_NETMASK="$t1";fi
	;;

	[Yy]* )
		read -p "Bridge IP [$BRIDGE_IP]: " -e t1
		if [ -n "$t1" ]; then BRIDGE_IP="$t1";fi	

		read -p "Bridge Subnet Mask [$BRIDGE_NETMASK]: " -e t1
		if [ -n "$t1" ]; then AP_CHAN="$t1";fi	

		# ask how they want to configure their mesh point
		read -p "Mesh Point SSID [$MESH_SSID]: " -e t1
		if [ -n "$t1" ]; then MESH_SSID="$t1";fi

		read -p "Mesh Point Channel [$MESH_CHAN]: " -e t1
		if [ -n "$t1" ]; then MESH_CHAN="$t1";fi

		read -p "Mesh Point Cell ID [$CELL_ID]: " -e t1
		if [ -n "$t1" ]; then CELL_ID="$t1";fi
	;;
esac

read -p "DHCP starting address [$DHCP_START]: " -e t1
if [ -n "$t1" ]; then DHCP_START="$t1";fi

read -p "DHCP ending address [$DHCP_END]: " -e t1
if [ -n "$t1" ]; then DHCP_END="$t1";fi

read -p "DHCP netmask [$DHCP_NETMASK]: " -e t1
if [ -n "$t1" ]; then DHCP_NETMASK="$t1";fi

read -p "DHCP length of lease [$DHCP_LEASE]: " -e t1
if [ -n "$t1" ]; then DHCP_LEASE="$t1";fi

# create hostapd init file
echo -en "Creating default hostapd file...			"
cat <<EOF > /etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	echo ""
	exit $rc
else
	echo -en "[OK]\n"
fi

# create hostapd configuration with user's settings
echo -en "Creating hostapd.conf file with your settings...				"
case $DO_SET_MESH in
	[Yy]* )
		cat <<EOF > /etc/hostapd/hostapd.conf
interface=ap0
bridge=br0
driver=$RADIO_DRIVER
country_code=$AP_COUNTRY
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHAN
beacon_int=100
wmm_enabled=1
ap_isolate=1
EOF
	;;

	[Nn]* )
		cat <<EOF > /etc/hostapd/hostapd.conf
interface=ap0
driver=$RADIO_DRIVER
country_code=$AP_COUNTRY
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHAN
beacon_int=100
wmm_enabled=1
EOF
	;;
esac

rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	exit $rc
else
	echo -en "[OK]\n"
fi

# backup the existing interfaces file
echo -en "Creating backup of network interfaces configuration file... 			"
cp /etc/network/interfaces /etc/network/interfaces.bak
rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	exit $rc
else
	echo -en "[OK]\n"
fi

# CONFIGURE /etc/network/interfaces
		echo -en "Creating new network interfaces configuration file with your settings... 	"
case $DO_SET_MESH in
	[Yy]* )
		cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto mesh0
iface mesh0 inet static
	wireless-channel $MESH_CHAN
	wireless-essid $MESH_SSID
	wireless-mode ad-hoc
	wireless-ap $CELL_ID

# create bridge
iface br0 inet static
  bridge_ports ap0 bat0
  bridge_stp off
  address $BRIDGE_IP
  netmask $BRIDGE_NETMASK

iface default inet dhcp
EOF
	;;

	[Nn]* )
		cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

iface ap0 inet static
	address $AP_IP
	netmask $AP_NETMASK

iface default inet dhcp
EOF
	;;
esac

rc=$?
if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
	echo ""
	exit $rc
else
	echo -en "[OK]\n"
fi

# CONFIGURE dnsmasq
echo -en "Creating dnsmasq configuration file... 			"
case $DO_SET_MESH in
	[Yy]* )
		cat <<EOF > /etc/dnsmasq.conf
interface=br0
address=/#/$BRIDGE_IP
address=/apple.com/0.0.0.0
dhcp-range=$DHCP_START,$DHCP_END,$DHCP_NETMASK,$DHCP_LEASE
EOF
	;;

	[Nn]* )
		cat <<EOF > /etc/dnsmasq.conf
interface=br0
address=/#/$AP_IP
address=/apple.com/0.0.0.0
dhcp-range=$DHCP_START,$DHCP_END,$DHCP_NETMASK,$DHCP_LEASE
EOF
	;;
esac

rc=$?
if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
	echo ""
	exit $rc
else
	echo -en "[OK]\n"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# COPY OVER THE ACCESS POINT START UP SCRIPT + enable services
#
clear
update-rc.d hostapd enable
update-rc.d dnsmasq enable
cp scripts/subnodes_ap.sh /etc/init.d/subnodes_ap
chmod 755 /etc/init.d/subnodes_ap
update-rc.d subnodes_ap defaults

case $DO_SET_MESH in
	[Yy]* )
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		# COPY OVER THE MESH POINT START UP SCRIPT
		#
		# pass the selected mesh ssid into mesh startup script
		sed -i "s/SSID/$MESH_SSID/" scripts/subnodes_mesh.sh
		sed -i "s/CHAN/$MESH_CHAN/" scripts/subnodes_mesh.sh
		sed -i "s/CELL_ID/$CELL_ID/" scripts/subnodes_mesh.sh
		echo ""
		echo "Adding startup script for mesh point..."
		cp scripts/subnodes_mesh.sh /etc/init.d/subnodes_mesh
		chmod 755 /etc/init.d/subnodes_mesh
		update-rc.d subnodes_mesh defaults
	;;

	[Nn]* ) ;;
esac

read -p "Do you wish to reboot now? [N] " yn
	case $yn in
		[Yy]* )
			reboot;;
		Nn]* ) exit 0;;
	esac
