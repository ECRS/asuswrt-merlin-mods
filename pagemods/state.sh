#!/bin/bash

# Set the default password check to 0
#
# TODO:would be nice to find a way for this to be re-enabled
# post-deployment but for now this will have to do.
/bin/sed --in-place 's/^var notice_pw_is_default =.*/var notice_pw_is_default = 0;/g' $1




# Disable SNMP support
/bin/sed --in-place 's/^var snmp_support =.*/var snmp_support = 0;/g' $1




# Fix event.srcElement incompatability
LINE="var evtTarget = evt.target || evt.srcElement;"
if ! /bin/grep --quiet "var evtTarget" $1
then
    LINENUM=`/bin/grep --line-number "var target =" $1 | /usr/bin/cut --delimiter=: --fields=1`

    /bin/sed --in-place "${LINENUM}i${LINE}" $1
    /bin/sed --in-place 's/evt.srcElement/evtTarget/g' $1
fi




# Add ECRS logo branding modifications
if ! /bin/grep --quiet "ecrs_asuswrt.svg" $1
then
    NEWLINE="banner_code +='<div style=\"margin-left:25px;width:160px;margin-top:5px;float:left;\" align=\"left\"><span><a href=\"https://ecrs.com\" target=\"_blank\"><img src=\"images/ecrs_asuswrt.svg\" style=\"border: 0;\"></span></div>';"

    /bin/sed --in-place "s|.*merlin-logo\.png.*|${NEWLINE}|g" $1
fi
