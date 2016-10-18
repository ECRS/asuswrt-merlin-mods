#!/bin/bash

# Hide insecure wireless methods
if ! /bin/grep --quiet "Hide insecure wireless methods" $1
then
    NEWLINE=<< CSS
/* Hide insecure wireless methods */
select[name="wl_auth_mode_x"] option[value="open"]      /* Open System */
, select[name="wl_auth_mode_x"] option[value="pskpsk2"] /* WPA-Auth-Personal */
, select[name="wl_auth_mode_x"] option[value="wpawpa2"] /* WPA-Auto-Enterprise */
{
    display: none;
}
CSS

    NEWLINESHORT='/* Hide insecure wireless methods */ select[name="wl_auth_mode_x"] option[value="open"], select[name="wl_auth_mode_x"] option[value="pskpsk2"], select[name="wl_auth_mode_x"] option[value="wpawpa2"]{display: none;}'

    /bin/sed --in-place "1i${NEWLINESHORT}" $1
fi
