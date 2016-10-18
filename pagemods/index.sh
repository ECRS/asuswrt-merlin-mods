#!/bin/bash

# Insert the ECRS stylesheet
NEWLINE='<link rel="stylesheet" type="text/css" href="ecrs.css">'
if ! /bin/grep --quiet "${NEWLINE}" $1
then
    LINENUM=`/bin/grep --line-number '<link rel="stylesheet" type="text/css".*' $1 | /usr/bin/tail -1 | /usr/bin/cut --delimiter=: --fields=1`
    ((LINENUM++))
    /bin/sed --in-place "${LINENUM}i${NEWLINE}" $1
fi
