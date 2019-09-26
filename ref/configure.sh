#!/bin/bash

#System upgrade
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y tzdata
echo "America/New_York" > /etc/timezone

# Install gnuradio and other tools
#DEBIAN_FRONTEND=noninteractive apt install -y openssh-server gnuradio htop vim python-click python-pip python-virtualenv
DEBIAN_FRONTEND=noninteractive apt install -y openssh-server gnuradio python-pip python-virtualenv stress-ng

# Start configuring SSH to be the main container process
mkdir /var/run/sshd
echo 'root:gnuradio' | chpasswd
# Ubuntu 18.04
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# Ubuntu 16.04
sed -i 's/PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create required directories for throughput testing
mkdir -p /home/gnuradio/ferret
mkdir -p /home/shared

# Move files to the correct locations
mv /tmp/install/ferret /home/shared/
mv /tmp/install/gnuradio.tar.gz /home/shared/gnuradio.tar.gz
rmdir /tmp/install

# Extract the GNU Radio build
cd /home/shared
tar -zxf gnuradio.tar.gz
rm gnuradio.tar.gz

# Setup the virtual environment
cd /home/shared
virtualenv env
source env/bin/activate

# Install required python packages
cd /home/shared/ferret
pip install -r requirements-worker.txt

# Test to see if gnuradio was installed properly
source /home/shared/env/bin/activate
source /home/shared/gnuradio/setup_env.sh
echo "Python interpreter: " $(which python)
echo "Python version: " $(python --version)
echo "GNU Radio version: " $(gnuradio-config-info -v)

