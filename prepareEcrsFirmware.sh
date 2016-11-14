#!/bin/bash

# Define global variables
RELEASE=/home/asus/asuswrt-merlin/release
ECRS=$RELEASE/ecrs
ROOT=$RELEASE/src-rt-6.x
MODEL="RT-AC66U"




# Set version
cd $RELEASE
/usr/bin/git checkout $RELEASE/src-rt/version.conf
cd $ECRS
EXTENDNO=`awk -F "=" '/EXTENDNO/ {print $2}' $RELEASE/src-rt/version.conf`
SEP=""
if [ ! -z "EXTENDNO" ]
then
    SEP="_"
fi
ECRSTAG=`awk -F "=" '/ECRSTAG/ {print $2}' version.conf`
ECRSB=`awk -F "=" '/ECRSB/ {print $2}' version.conf`
/bin/sed --in-place '/^EXTENDNO=/ s/$/'$SEP$ECRSTAG'.'$ECRSB'/' $RELEASE/src-rt/version.conf
((ECRSB++))
/bin/sed --in-place 's/^ECRSB=.*$/ECRSB='$ECRSB'/g' version.conf




# Apply any changes that need to occur to build from the
# stock source.
/bin/echo -e "Applying any necessary changes to the stock environment"
/bin/bash fixStockSetup.sh




# Apply all ECRS customizations to stock files
/bin/echo -e "Applying any necessary changes to the stock make files"
/bin/bash customize.sh




# Build the Asus RT-AC66U Firmware
#/bin/echo -e "Building firmware"
#cd $ROOT
#/usr/bin/make clean
#/usr/bin/make rt-ac66u
