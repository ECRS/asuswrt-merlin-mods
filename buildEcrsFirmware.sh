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
ECRSNO=`awk -F "=" '/ECRSNO/ {print $2}' version.conf`
/bin/sed --in-place '/^EXTENDNO=/ s/$/'$SEP$ECRSTAG'.'$ECRSNO'/' $RELEASE/src-rt/version.conf
((ECRSNO++))
/bin/sed --in-place 's/^ECRSNO=.*$/ECRSNO='$ECRSNO'/g' version.conf




# Apply any changes that need to occur to build from the
# stock source.
/bin/echo -e "Applying any necessary changes to the stock environment"
/bin/bash fixStockSetup.sh




# Apply any changes that need to occur to stock make files
/bin/echo -e "Applying any necessary changes to the stock make files"
/bin/bash customize.sh




# Apply all pagemods
/bin/echo -e "Applying all necessary changes to the Website UI"
PATH=$ROOT/router/www
for file in $ECRS/pagemods/*
do
    if [ ! -d "$file" ]
    then
        # Remove the path from the filename
        f=${file##*/}

        # Execute the modifications in the file
        /bin/bash $file $PATH/${f%.*}.*
    fi
done
for file in $ECRS/pagemods/device-map/*
do
    if [ ! -d "$file" ]
    then
        # Remove the path from the filename
        f=${file##*/}

        # Execute the modifications in the file
        /bin/bash $file $PATH/device-map/${f%.*}.*
    fi
done
for file in $ECRS/pagemods/sysdep/$MODEL/www/*
do
    if [ ! -d "$file" ]
    then
        # Remove the path from the filename
        f=${file##*/}

        # Execute the modifications in the file
        /bin/bash $file $PATH/sysdep/$MODEL/www/${f%.*}.*
    fi
done




# Apply all nvram changes
/bin/echo -e "Applying nvram default settings"
for file in $ECRS/nvram/*
do
    # Execute the modifications in the file
    /bin/bash $file
done




# Prepare all jffs scripts
/bin/echo -e "Moving scripts into place that should load at time of boot"
PATH=$ROOT/router/rom/scripts
for file in $ECRS/jffs/scripts/*
do
    # Set the script to be executable
    /bin/chmod a+rx $file
done
/bin/rm --recursive --force $PATH
/bin/cp --recursive --force --preserve=mode,timestamps $ECRS/jffs/scripts $PATH




# Insert all custom CSS, JS, img, etc files to the www directory
/bin/echo -e "Moving custom web files into place"
PATH=$ROOT/router/www
for file in $ECRS/www/*
do
    # Copy the file into place
    /bin/cp --force --recursive $file $PATH
done




# Build the Asus RT-AC66U Firmware
#/bin/echo -e "Building firmware"
#cd $ROOT
#/usr/bin/make clean
#/usr/bin/make rt-ac66u
