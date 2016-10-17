#!/bin/bash

# Remove insecure Authentication Methods
/bin/sed --in-place '/>Open System</d; />Shared Key</d; />WPA-Personal</d; />WPA-Auto-Personal</d; />WPA-Enterprise</d; />WPA-Auto-Enterprise</d' $1




# Can't get the insecure auth methods to go away... they
# seem to be being added back by js - brute force them
LINENUM=`/bin/grep --line-number "</head>" $1 | /usr/bin/cut --delimiter=: --fields=1`
if [ $LINENUM ]
then
    SCRIPT='<script>
                var id = "brute-force-insecure-auth";
                Array.prototype.forEach.call(
                    document.querySelectorAll("option"),
                    function (i)
                    {
                        var arr = ["open", "pskpsk2", "wpawpa2"];
                        if (arr.indexOf(i.value) > -1)
                        {
                            elem.parentNode.removeChild(elem);
                        }
                    }
                );
            </script>'

    SHORTSCRIPT='<script>var id = "brute-force-insecure-auth";Array.prototype.forEach.call(document.querySelectorAll("option"),function (i){var arr = ["open", "pskpsk2", "wpawpa2"];if (arr.indexOf(i.value) > -1){elem.parentNode.removeChild(elem);}});</script>'
    
    if ! /bin/grep --quiet "brute-force-insecure-auth" $1
    then
        /bin/sed --in-place "${LINENUM}i${TESTSCRIPT}" $1
    fi
fi
