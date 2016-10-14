#!bin/bash

# Set the default password check to 0; would be nice to find
# a way for this to be re-enabled post-deployment but for now
# this will have to do.
/bin/sed --in-place 's/^var notice_pw_is_default =.*/var notice_pw_is_default = 0;/g' $1
