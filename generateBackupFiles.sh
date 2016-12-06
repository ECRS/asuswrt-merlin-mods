#!/bin/bash
#
# @author       astclair
# @version      12.6.2016
#
# Generate 30 days worth of biolerplate files


for i in {1..30}
do
    NUM=$(/usr/bin/expr 30 - $i)

    FNAME=`/bin/date --date="-${NUM} day" +"%Y%m%d%H%M"`
    TS=`/bin/date --date="-${NUM} day" +"%y%m%d%H%M"`

    /bin/dd if=/dev/zero of=$FNAME.tar.gz bs=1M count=1 > /dev/null 2>&1
    /usr/bin/touch -t $TS $FNAME.tar.gz
done
