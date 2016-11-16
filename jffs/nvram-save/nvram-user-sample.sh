#!/bin/sh

# User exit nvram-user.sh
# Parameters passed
# $1 current save id string "-yyyymmdd-macid"
# $2 the working backup directory

# Sample to create a tar backup of nvram-save data
echo "Creating nvram-backup"$1".tar.gz"
tar -zcf "$2/nvram-backup"$1".tar.gz" "$2/nvram-restore"$1".sh" "$2/jffs"$1
exit 0

