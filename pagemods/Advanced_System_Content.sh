#!/bin/bash

# Set variables
ROOT=/home/asus/asuswrt-merlin/release/src-rt-6.x




# Remove Persistent JFFS2 partition block from the webui
LINENUM=`/bin/grep --line-number ">Persistent JFFS2 partition<" $1 | /usr/bin/cut --delimiter=: --fields=1`
if [ $LINENUM ]
then
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "<table"`
    do
        ((LINENUM--))
    done
    STARTNUM=$LINENUM
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "</table"`
    do
        ((LINENUM++))
    done
    ENDNUM=$LINENUM
    /bin/sed --in-place --expression="${STARTNUM},${ENDNUM}d" $1
fi




# Remove SSH Daemon block from the webui
LINENUM=`/bin/grep --line-number ">SSH daemon<" $1 | /usr/bin/cut --delimiter=: --fields=1`
if [ $LINENUM ]
then
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "<table"`
    do
        ((LINENUM--))
    done
    STARTNUM=$LINENUM
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "</table"`
    do
        ((LINENUM++))
    done
    ENDNUM=$LINENUM
    /bin/sed --in-place --expression="${STARTNUM},${ENDNUM}d" $1
fi




# Remove Web Interface block from the webui
LINENUM=`/bin/grep --line-number ">Web interface<" $1 | /usr/bin/cut --delimiter=: --fields=1`
if [ $LINENUM ]
then
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "<table"`
    do
        ((LINENUM--))
    done
    STARTNUM=$LINENUM
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "</table"`
    do
        ((LINENUM++))
    done
    ENDNUM=$LINENUM
    /bin/sed --in-place --expression="${STARTNUM},${ENDNUM}d" $1
fi




# Remove Specified IP List block from the webui
LINENUM=`/bin/grep --line-number "<#System_login_specified_Iplist#>" $1 | /usr/bin/cut --delimiter=: --fields=1`
if [ $LINENUM ]
then
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "<table"`
    do
        ((LINENUM--))
    done
    STARTNUM=$LINENUM
    while ! `/bin/sed --quiet "${LINENUM}p" $1 | /bin/grep --quiet "</table"`
    do
        ((LINENUM++))
    done
    ENDNUM=$LINENUM
    /bin/sed --in-place --expression="${STARTNUM},${ENDNUM}d" $1
fi




# Remove HTTP Client List block from the webui
/bin/sed --in-place '/id="http_clientlist_Block"/d' $1
