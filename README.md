subnodes-lighttpd
=================

![](https://david-dm.org/chootka/subnodes.svg)

Subnodes is an open source project built for Raspberry Pi / Raspbian (as of this writing, Buster Lite) into an offline mesh node and wireless access point.

This project is an initiative focused on streamlining the process of setting up a Raspberry Pi as a wireless access point for distributing content, media, and shared digital experiences. The device becomes a web server, creating its own local area network, and does not connect with the internet. This is key for the sake of offering a space where people can communicate anonymously and freely, as well as maximizing the portability of the network (no dependibility on an internet connection means the device can be taken and remain active anywhere). 

The device can also be configured as a BATMAN Advanced mesh node, enabling it to join with other nearby BATMAN nodes into a greater mesh network, extending the access point range and making it possible to exchange information with each other. Support for Subnodes has been provided by Eyebeam. This code is published under the [AGPLv3](http://www.gnu.org/licenses/agpl-3.0.html).

How to Install
--------------
Assuming you are starting with a fresh [Raspbian Buster Lite](http://www.raspberrypi.org/downloads/) (Latest tested version: Feb 2020) installed on your SD card, these are the steps for setting up subnodes on your Raspberry Pi. It is also assumed that you have two wireless USB adapters attached to your RPi. They both must be running the nl80211 driver. [This guide](https://github.com/phillymesh/802.11s-adapters/blob/master/README.md) will help you find a suitable radio. If you are running a Raspberry Pi 3 or Pi Zero W, you only need one additional radio for the mesh point. Make sure the extra radio support ad hoc mode. The access point will be set up utilizing the Pi's internal wireless radio.

Also, if this is your first time connecting to your Raspberry Pi headlessly (i.e. via SSH), you must first enable SSH by placing an empty file with no filename extension simply called `ssh` in the root of your SD card.

* configure your Raspberry Pi with a new password and locale information. 
  
  **You must select "4 Localisation Options" and then "I4 Change Wi-fi Country" in order for wifi to work on the Raspberry Pi. Also, change your password!**

        sudo raspi-config

* update apt-get

        sudo apt-get update
        
* install git

        sudo apt-get install git -y

* clone the repository into your home folder (assuming /home/pi)

        git clone https://github.com/chootka/subnodes-lighttpd.git
        cd subnodes-lighttpd

* configure your wireless access point and mesh network in subnodes.config in any text editor, or in the command line you can use nano

        nano subnodes.config

* run the installation script

        sudo ./install.sh

The installation process takes about 5 minutes. After it has completed, you will have a running lighttpd php7 web server, wireless access point, and BATMAN Advanced mesh node (if you left DO_SET_MESH=y). Connecting to the network and navigating to a browser page will redirect you to your new captive portal page. It's only going to be a boilerplate (aka, default) lighttpd web page, so head into /var/www/html and create a new index.html file and go nuts.

From here, fork, build, share your ideas, and have fun!

References
----------
* [subnodes website](http://www.subnodes.org/)
* [Raspberry Pi](http://www.raspberrypi.org/)
* [eyebeam](http://eyebeam.org/)

License
----------
This code is published under the [AGPLv3](http://www.gnu.org/licenses/agpl-3.0.html).
