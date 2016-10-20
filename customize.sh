#!/bin/bash

# Setup variables
RELEASE=/home/asus/asuswrt-merlin/release
ECRS=$RELEASE/ecrs
ROOT=$RELEASE/src-rt-6.x




# Add copying of ECRS boot-time scripts to the image. This code is not run
# until after the scripts have been copied into router/rom/scripts dir.
PATH=$ROOT/router/rom/Makefile
if ! /bin/grep --quiet "ECRS mod to load prebuilt scripts" $PATH
then
    echo -e "#\tECRS mod to load prebuilt scripts" >> $PATH
    echo -e "\tmkdir -p \$(INSTALLDIR)/rom/scripts" >> $PATH
    echo -e "\tcp -rf scripts/* \$(INSTALLDIR)/rom/scripts" >> $PATH
fi




# Apply all patches
PATH=$ECRS/patches
declare -A PATCHES

PATCHES[jffs2.c.patch]="$ROOT/router/rc/jffs2.c"

for P in "${!PATCHES[@]}";
do
    # Change to the dir and checkout clean version
    DIR=`/usr/bin/dirname "${PATCHES[$P]}"`
    FILE=`/usr/bin/basename "${PATCHES[$P]}"`
    cd $DIR
    /usr/bin/git checkout -- $FILE

    # Apply patch to file
    /usr/bin/patch --forward "${PATCHES[$P]}" "$PATH/$P"
done
