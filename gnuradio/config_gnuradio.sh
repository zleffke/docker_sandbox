#!/bin/bash

#Configuration Script for pybombs installation inside of Docker Container.
#This script gets passed to container via ADD commands in the Dockerfile then executed.
#This script updates the ubuntu image, then installs pybombs, then installs GNU Radio.
#May also include the extra GR out of tree modules needed for the VCC mission.

#System upgrade
echo "---Configuring Ubuntu---"
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
echo "---Configuring SSH---"
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

echo "---Configuring Filesystem for GNU Radio---"
#setup filesystem structure related to gnuradio
mkdir -p /gnuradio/target     #location for installation of gnuradio
mkdir -p /gnuradio/flowgraphs #location for flowgraphs
mkdir -p /gnuradio/captures   #location for recordings

#setup and install pybombs
echo "---Configuring PyBOMBS---"
cd /gnuradio
pip install --upgrade pip
pip install pybombs
pybombs auto-config
pybombs config makewidth 8 #change this to match available cores
#configure prefix
pybombs prefix init /gnuradio/target -a target
pybombs recipes add-defaults

#install common dependencies, may not be comprehensive
echo "---Installing Common Dependencies for PyBOMBS---"
pybombs -vvv install boost doxygen
pybombs -vvv install libtool autoconf automake
pybombs -vvv install qwt5 sip lxml
pybombs -vvv install pygtk pycairo pyqwt5 python-requests six mako numpy
pybombs -vvv install zeromq python-zmq
pybombs -vvv install gsl fftw
pybombs -vvv install libusb alsa
pybombs -vvv install cppunit liblog4cpp

#install UHD and GNU Radio
echo "---Installing GNU Radio---"
pybombs -vvv install uhd
pybombs -vvv install gnuradio37 #don't upgrade to 3.8 yet.

#Install VCC specific Out of Tree Modules (OOTMs)
echo "---Installing VCC OOTMs---"
pybombs recipes add gr-vtgs-recipes git+https://github.com/vt-gs/recipes.git
pybombs -vvv install gr-kiss    #kiss / ax.25 processing blocks
pybombs -vvv install gr-sigmf   #for signal recording and playback
pybombs -vvv install gr-vcc     #Custom blocks for VCC mission.
pybombs -vvv install gr-foo     #Custom blocks for VCC mission.
pybombs -vvv install gr-pdu_utils
pybombs -vvv install gr-timing_utils
pybombs -vvv install gr-message_tools

#Test gnuradio install
source /gnuradio/target/setup_env.sh
echo "Python interpreter: " $(which python)
echo "Python version: " $(python --version)
echo "GNU Radio version: " $(gnuradio-config-info -v)
