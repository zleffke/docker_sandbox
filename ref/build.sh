#!/bin/bash

if [ -z "$1" ]; then
  echo "Name for the container image is required!"
  exit -1
fi

IMAGE_NAME=$1
echo "Building container:" $IMAGE_NAME

echo "*** Cloning repositories ***"
# Create a temporary directory for cloning
mkdir tmp;

# Clone and copy everything to the tmp directory.
# These all then get copied over to the container in the /tmp directory.
git clone git@code.vt.edu:beta-5/ferret.git tmp/ferret
#cd tmp/ferret; git checkout refactor2; cd ../..
cp /home/shared/gnuradio.tar.gz tmp/

echo "*** Building Container ***"
# Build the container
docker build -t $IMAGE_NAME -f gnuradio-16.04.Dockerfile .

# Remove the temporary directories
rm -rf tmp

