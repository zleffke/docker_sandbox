#!/bin/bash

#Configuration Script for pybombs installation inside of Docker Container.
#This script gets passed to container via ADD commands in the Dockerfile then executed.

#System upgrade
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y tzdata
echo "America/New_York" > /etc/timezone
DEBIAN_FRONTEND=noninteractive apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install python-pip -y
DEBIAN_FRONTEND=noninteractive apt-get install python-apt -y
DEBIAN_FRONTEND=noninteractive apt-get install apt-utils -y
DEBIAN_FRONTEND=noninteractive apt-get install python-virtualenv -y
#stress-ng is optional, not required for a pybombs/gnuradio install, but useful for stress testing on various platforms.
DEBIAN_FRONTEND=noninteractive apt-get install stress-ng -y
DEBIAN_FRONTEND=noninteractive apt-get install openssh-server

# Start configuring SSH to be the main container process
mkdir /var/run/sshd
#!!!!CHANGE YOUR PASSWORDS!!!!!!!
echo 'root:gnuradio' | chpasswd
#!!!!DON'T FORGET - CHANGE YOUR PASSWORDS!!!!
# Ubuntu 18.04
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# Ubuntu 16.04
#sed -i 's/PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
#sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#setup and install pybombs
mkdir -p /gnuradio/target
mkdir -p /gnuradio/flowgraphs

cd /gnuradio
pip install --upgrade pip
pip install pybombs
pybombs auto-config
pybombs config makewidth 8
#configure prefix
pybombs prefix init /gnuradio/target -a target
pybombs recipes add-defaults
pybombs install boost doxygen
pybombs install libtool autoconf automake
pybombs install qwt5 sip lxml
pybombs install pygtk pycairo pyqwt5 python-requests six mako numpy
pybombs install gsl fftw
pybombs install zeromq python-zmq
pybombs install libusb alsa
pybombs install cppunit liblog4cpp



#Test gnuradio install
#source /home/shared/gnuradio/setup_env.sh
#echo "Python interpreter: " $(which python)
#echo "Python version: " $(python --version)
#echo "GNU Radio version: " $(gnuradio-config-info -v)
