#!/bin/bash

# Define global variables
RELEASE=/home/asus/asuswrt-merlin/release
ROOT=$RELEASE/src-rt-6.x




# Prepare the ECRS firmware
/bin/echo -e "Preparing the ECRS firmware"
/bin/bash prepareEcrsFirmware.sh




# Build the Asus RT-AC66U Firmware
#/bin/echo -e "Building firmware"
#cd $ROOT
#/usr/bin/make clean
#/usr/bin/make rt-ac66u
