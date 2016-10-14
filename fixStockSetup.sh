#!/bin/bash

# Set up variables
ROOT=/home/asus/asuswrt-merlin/release/src-rt-6.x


# Fix nano automake 1.15 dependency; autoreconf will run
# autoheader, aclocal, automake, autpoint and libtoolize
# as required. This will make sure the automake that's
# installed on the system will be required in the Makefile.
cd $ROOT/router/nano
autoreconf --force --install
