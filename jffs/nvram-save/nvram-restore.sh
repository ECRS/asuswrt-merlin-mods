#!/bin/sh

# nvram-restore.sh
# General front end to calling generated
# nvram-restore-yyyymmdd-macid scripts
# Supports OEM and Merlin firmware ONLY

# Changelog
#------------------------------------------------
# Version 24			    2-May-2016
# - version update only
#
# Version 23			    3-April-2016
# - add help text for clean restore
#
# Version 22			    27-October-2015
# - add ini version to runlog
# - version variable name update
#
# Version 21			    6-August-2015
# - version update only
#
# Version 20			    3-August-2015
# - enable running script from other than current directory
#
# Version 19			     16-June-2015	
# - version update only for ini
#
# Version 18			     14-June-2015
# - prompt for clean restore with file generated
#   by latest level
# - add codelevel to runlog
# - added exit for no valid restore scripts
#
# Version 17			    29-April-2015
# - version update only for ini
#
# Version 16			    16-April-2015
# - first release as part of Version 16 package	
# - use last run for restore if none specified
#
#------------------------------------------------

Version=24
restore_version=$1
opt=""
scr_name=$(basename $0)
#cwd=$(pwd)
cwd=$(dirname $(readlink -f $0))
if [[ -d "$cwd/backup" ]]; then
	dwd=$cwd/backup;
else
	dwd=$cwd
fi
runlog="$cwd/nvram-util.log"
space4="    "
codelevel=""


echo ""
if [ "$restore_version" == "" ] || [ "$1" == "Y" ]; then
	macid=$(nvram get "et0macaddr")
	if [ "$macid" = "" ]; then
		macid=$(nvram get "et1macaddr")
	fi
	macid=`echo $macid | cut -d':' -f 5,6 | tr -d ':' | tr 'a-z' 'A-Z'`

	restore_version=`grep "nvram-save.sh" $runlog | grep $macid | tail -1 | awk -F' ' '{print $2}'`
	if [ "$restore_version" == "" ]; then
		echo "No restore scripts found for MAC: "$macid
		echo "Exiting - Restore aborted"
		exit 2
	fi
		
	if [ "$1" != "Y" ]; then
		read -p "Restore last nvram save (nvram-restore-$restore_version.sh) [Y/N]?" input
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
fi
restore_file="nvram-restore-"$restore_version".sh"
grep -q "Clean NVRAM option specified" $dwd/$restore_file

if [ $? = 0 ]; then
	echo ""
	echo "A clean restore will restore only those NVRAM settings"
	echo "  which have been initialized by the router after a factory reset"
	echo "This option should by used when reverting to an earlier"
	echo "  firmware level, when updating past a single firmware release," 
	echo "  when moving betwwen OEM and Merlin firmware or"
	echo "  to ensure any special use or obsolete NVRAM variables are cleared"
	echo "If in doubt, answer Y to perform a clean restore"
	echo ""
	read -p "Perform a clean restore and remove ununsed NVRAM variables [Y/N]?" input
		case "$input" in
	        	"Y"|"y")
				opt="-clean"
				continue
	       			;;
        		*)
				opt=""
                		;;
        		esac
fi

echo ""
if [ ! -f "$dwd/$restore_file" ]; then
        echo "Script $restore_file does not exist. Exiting."
        echo ""
        exit 1
else
	sh $dwd/$restore_file $opt
fi

# Update runlog
codelevel=$(grep "codelevel=" $dwd/$restore_file | awk -F'=' '{print $2}')
version=$(grep "#Version=" $dwd/$restore_file | awk -F'=' '{print $2}')
echo "$(printf "%-20s" $scr_name)$(printf "%-16s" $restore_version)$(date)$space4$(printf "%-20s" $codelevel)#Version=$version" >>$runlog
echo ""
exit 0
