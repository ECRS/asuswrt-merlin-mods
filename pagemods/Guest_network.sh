#!/bin/bash

# Remove insecure Authentication Methods
/bin/sed --in-place '/>Open System</d; />Shared Key</d; />WPA-Personal</d; />WPA-Auto-Personal</d; />WPA-Enterprise</d; />WPA-Auto-Enterprise</d' $1
