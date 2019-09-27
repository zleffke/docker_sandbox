#!/bin/bash
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)

if [ -z "$1" ]; then
  echo "Name for the container image is required!"
  exit -1
fi

IMAGE_NAME=$1
BUILD_LOG="build-"$IMAGE_NAME"_"$TIMESTAMP".log"
echo "Building container:" $IMAGE_NAME
echo "Logging To: " $BUILD_LOG

# Build the container
docker build -t $IMAGE_NAME -f gnuradio-18.04.Dockerfile . >> $BUILD_LOG

# Remove the temporary directories
rm -rf tmp
