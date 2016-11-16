#!/bin/sh

# jffs-restore.sh
# Save jffs directory for restore after factory reset
# Supports OEM and Merlin firmware ONLY

# Changelog
#------------------------------------------------
# Version 24			  2-May-2016
# - version update only
#
# Version 23			  3-April-2016
# - version update only
#
# Version 22			  27-October-2015
# - version variable name update
#
# Version 21			  6-August-2015
# - version update only
#
# Version 20			  3-August-2015
# - enable running script from other than current directory
#
# Version 19			  16-June-2015	
# - version update only for ini
#
# Version 18			  14-June-2015
# - added exit for no restore directory found
#
# Version 17			  29-April-2015
# - version update only for ini
#
# Version 16			  16-April-2015
# - use last run for restore if none specified
#
# Version 15			  25-February-2015
# - version update only
#
# Version 14			  7-February-2015
# - log results to syslog
#
# Version 12			  1-February-2015
# - do not hardcode jffs restore directory parent
#
# Version 11                      29-January-2015
# - no change
#
# Version 10 - first package release
# - restore /jffs directory       18-January-2015
#
#------------------------------------------------

Version=24
jffs_version=$1
if [ "${jffs_version:0:4}" == "jffs" ]; then
	jffs_dir=$jffs_version
	jffs_version=${jffs_version:5:13}
else
	jffs_dir="jffs-"$jffs_version
fi
scr_name=$(basename $0)
#cwd=$(pwd)
cwd=$(dirname $(readlink -f $0))
if [[ -d "$cwd/backup" ]]; then
	dwd=$cwd/backup;
else
	dwd=$cwd
fi
runlog="$cwd/nvram-util.log"

echo ""
if [ "$jffs_version" == "" ]; then
	macid=$(nvram get "et0macaddr")
	if [ "$macid" = "" ]; then
		macid=$(nvram get "et1macaddr")
	fi
	macid=`echo $macid | cut -d':' -f 5,6 | tr -d ':' | tr 'a-z' 'A-Z'`
	jffs_version=`grep "jffs-save" $runlog | grep $macid | tail -1 | awk -F' ' '{print $2}'`
	if [ "$jffs_version" == "" ]; then
		echo "No saved jffs directory found for MAC: "$macid
		echo "Exiting - Restore aborted"
		exit 2
	fi

	jffs_dir="jffs-"$jffs_version
	read -p "Restore last saved directory ($jffs_dir) [Y/N]?" input
	case "$input" in
	        "Y"|"y")
        		continue
	       		;;
        	*)
                	echo ""
                	echo "Exiting - Restore aborted"
                	echo ""
                	exit 1
                	;;
        	esac
fi

echo ""
if [ ! -d "$dwd/$jffs_dir" ]; then
        echo "Directory $jffs_dir does not exist. Exiting."
        echo ""
        exit 1
else
	logger -s -t $scr_name "JFFS Restore Utility - Version "$version
	logger -s -t $scr_name "Restoring /jffs directory:  "$jffs_dir
fi

echo ""
echo "WARNING:  This will overwrite/replace the current contents of your /jffs directory"
read -p "Do you want to continue [Y/N] " input
case "$input" in
        "Y"|"y")
        	echo "Deleting current contents of /jffs"
        	rm -r /jffs/*
        	echo "Restoring /jffs"
		cp -af "$dwd/$jffs_dir/." /jffs
                logger -s -t $scr_name  "/jffs restored from "$dwd"/"$jffs_dir
                echo ""
                ;;
        *)
                echo ""
                logger -s -t $scr_name  "Exiting - Restore aborted"
                echo ""
                exit 1
                ;;
        esac

echo "$(printf "%-20s" $scr_name)$(printf "%-16s" $jffs_version)$(date)" >>$runlog

echo "Please reboot manually"
echo ""
exit 0
