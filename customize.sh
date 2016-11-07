#!/bin/bash

# Setup variables
RELEASE=/home/asus/asuswrt-merlin/release
ECRS=$RELEASE/ecrs
ROOT=$RELEASE/src-rt-6.x




# Add copying of ECRS boot-time scripts to the image. This code is not run
# until after the scripts have been copied into router/rom/scripts dir.
PATH=$ROOT/router/rom
cd $PATH
PATH=$ROOT/router/rom/Makefile
/usr/bin/git checkout -- $PATH
if ! /bin/grep --quiet "ECRS mod to load prebuilt configs and scripts" $PATH
then
    echo -e "#\tECRS mod to load prebuilt scripts" >> $PATH
    echo -e "\techo -e \"Adding default configs and scripts to rom\"" >> $PATH
    echo -e "\tmkdir -p \$(INSTALLDIR)/rom/configs" >> $PATH
    echo -e "\tmkdir -p \$(INSTALLDIR)/rom/scripts" >> $PATH
    echo -e "\tcp -rfv configs/* \$(INSTALLDIR)/rom/configs" >> $PATH
    echo -e "\tcp -rfv scripts/* \$(INSTALLDIR)/rom/scripts" >> $PATH
    echo -e "\tfind \$(INSTALLDIR)/rom -name \"*\"" >> $PATH
fi
cd $ECRS




# Create and apply all router patches
for D in `/usr/bin/find router -maxdepth 1 -type d | /usr/bin/tail -n +2`
do
    DIRNAME=`/usr/bin/basename $D`
    DIRPATH=$RELEASE/src/router/$DIRNAME
    ORIGPATH=$ECRS/router/$DIRNAME/original
    MODSPATH=$ECRS/router/$DIRNAME/mods
    PATCHPATH=$ECRS/router/$DIRNAME/patches

    cd $DIRPATH
    /usr/bin/git checkout -- .

    for f in $ORIGPATH/*
    do
        FILE=`/usr/bin/basename $f`
        /usr/bin/diff --unified $f $MODSPATH/$FILE > $PATCHPATH/$FILE.patch
    done

    for f in $PATCHPATH/*.patch
    do
        FILE=`/usr/bin/basename $f`
        FILE=${FILE%.*}
        /usr/bin/patch --forward $DIRPATH/$FILE < $f
    done
done




# Insert all new files needed for ECRS customization
/bin/echo -e "Moving custom web files into place"
PATH=$ROOT/router/www
for file in $ECRS/router/www/new/*
do
    # Copy the file into place
    /bin/cp --force --recursive --verbose $file $PATH
done




# Apply all nvram changes
/bin/echo -e "Applying nvram default settings"
for file in $ECRS/nvram/*
do
    # Execute the modifications in the file
    /bin/bash $file
done




# Prepare all jffs configs and scripts
/bin/echo -e "Moving configs and scripts into place that should load at time of boot"
DIRPATH=$ROOT/router/rom
for file in $ECRS/jffs/scripts/*
do
    # Set the script to be executable
    /bin/chmod a+rx $file
done
/bin/rm --recursive --force $DIRPATH/configs $DIRPATH/scripts
/bin/cp --recursive --force --preserve=mode,timestamps --verbose $ECRS/jffs/configs $DIRPATH
/bin/cp --recursive --force --preserve=mode,timestamps --verbose $ECRS/jffs/scripts $DIRPATH
