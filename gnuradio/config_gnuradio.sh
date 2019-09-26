#!/bin/bash




# Test to see if gnuradio was installed properly
source /home/shared/gnuradio/setup_env.sh
echo "Python interpreter: " $(which python)
echo "Python version: " $(python --version)
echo "GNU Radio version: " $(gnuradio-config-info -v)

