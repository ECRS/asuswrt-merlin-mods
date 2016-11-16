#!/bin/sh

# nvram-excp-codename.sh
# Adjust nvram parameters for code specific issues
# Supports OEM and Merlin firmware ONLY

# Changelog
#------------------------------------------------
# Version 24			  2-May-2016
# - set qos_type if moving from early code level
#
# Version 23			  3-April-2016
# - handle mac_list differences between fw levels
# - auto correct bad wl_band vars
# - some changes dependent on not in migration mode
# - remove code to delete unused vars (use clean restore instead)
# - fixes not applied if ASUS OEM code detected
# - ensure do not enable scripts in migration mode

# Version 22			  27-October-2015
# - version variable name update
# - update Merlin/Fork unique variables
#
# Version 21			  6-August-2015
# - fix bug in setting jffs options moving from <378 to 378.55
# - add syslog entry for exception processing
#	
# Version 20			  3-August-2015
# - update Merlin/Fork unique variables
#
# Version 19			  16-June-2015	
# - version update only for ini
#
# Version 18			  14-June-2015
# - add more Merlin/Fork unique variables
# - remove code to remove vars on downlevel
#   (use '-clean' option instead)
# - force media dirs on upgrade
#
# Version 17			  29-April-2015
# - version update only for ini
#
# Version 16			  16-April-2015
# update fork specific vars for removal
# update (^378) vars for removal
#
# Version 15a			  6-March-2015
# add check for numeric extendno for ASUS OEM code
#
# Version 15			  25-February-2015
# - remove SNMP vars if not supported
# - update fork specific vars for removal
# - add version string for consistency check
#
# Version 14			  7-February-2015
# - update script name to include codename
# - update fork variables for delete
# - force jffs on for move to 378 code if off
#	if jffs already active, turn on scripts
# - use new vpn_server var for move to 378 code	
#
# Version 12                      1-February-2015			
# - use previous code in determining actions
#
# Version 11                      29-January-2015
# - Initial release into overall package
# - (378)  single maclist for filtering
# - (^378) delete Merlin specific variables
# - (^374) delete fork specific variables
#
#------------------------------------------------
Version=24
scr_name=nvram-excp-merlin
logger -s -t $scr_name  "NVRAM Exception Processing - Version $Version"

# Get current code level
buildno=$(nvram get buildno)
major=$(echo "$buildno" | awk -F"." '{ print $1; }')
minor=$(echo "$buildno" | awk -F"." '{ print $2; }' | awk -F"-" '{ print $1; }')
if [ "$minor" == "" ]; then
	minor=0
fi

# Get previous code level
buildno_org=$(nvram get buildno_org)
major_org=$(echo "$buildno_org" | awk -F"." '{ print $1; }')
minor_org=$(echo "$buildno_org" | awk -F"." '{ print $2; }' | awk -F"-" '{ print $1; }')
if [ "$minor_org" == "" ]; then
	minor_org=0
fi

# Check for numeric extendno (ASUS release)
asusno=$(nvram get extendno)
if ! [[ "$asusno" -eq "$asusno" ]] 2>/dev/null; then
	asusno=0
fi

# Update nvram based on code level specifics

update_maclist(){
	# Update mac filter lists
	OLDIF=$IFS
	IFS="<"

	tmpmac="";tmpmac_x=""
	for ENTRY in $(nvram get "$1_x")
	do
		if [ "$ENTRY" = "" ]; then
			continue
		fi
									
		mac=$(echo $ENTRY | cut -d ">" -f 1)
		tmpmac="$tmpmac $mac"
		tmpmac_x="$tmpmac_x<$mac"
	done
	IFS=$OLDIFS

	$(nvram set $1="$tmpmac")
	$(nvram set $1_x="$tmpmac_x")
}

if [[ $asusno -eq 0 ]]; then
	# Only process exceptions for Merlin builds

if [[ $major -eq 378 && $minor -le 55 && $major_org -lt 378 ]]; then
		# No longer separate maclist filters per radio
		wla_maclist_x=$(nvram get wl0_maclist_x | sed 's/</\n/g' | grep ":" | awk -F">" '{ print $1">"$2; }')
		wla_maclist_x=$wla_maclist_x"\n"$(nvram get wl1_maclist_x | sed 's/</\n/g' | grep ":" | awk -F">" '{ print $1">"$2; }')
		wla_maclist_x=$(echo -e "$wla_maclist_x" | sort -u | awk -F">" '{ print $1">"$2; }')
		wla_maclist_x=$(echo -e "$wla_maclist_x" | sed 's/^/</g' | tr -d '\n' )

		$(nvram set wl0_maclist_x="$wla_maclist_x")
		$(nvram set wl1_maclist_x="$wla_maclist_x")
fi

if [[ $major -ge 378 && $minor -gt 55 ]] && [[ $major_org -lt 378 || $minor_org -le 55 ]] ; then
		# Strip names from maclist for later levels
		update_maclist "wl0_maclist"
		update_maclist "wl1_maclist"
		update_maclist "wl2_maclist"
		update_maclist "wl0.1_maclist"
		update_maclist "wl0.2_maclist"
		update_maclist "wl0.3_maclist"
		update_maclist "wl1.1_maclist"
		update_maclist "wl1.2_maclist"
		update_maclist "wl1.3_maclist"
fi

if [[ $major -ge 378 && $major_org -lt 378 ]]; then
		# Force jffs on
		if [[ $minor -lt 55 ]]; then
			nvram set jffs2_on="1"
		else
			nvram set jffs_enable="1"
			nvram set jffs2_format="1"
			nvram set jffs2_scripts="0"
		fi
		# jffs already on, enable scripts
		if [[ "$1" != "MIGR" ]]; then
			nvram set jffs2_scripts="1"
		fi
		
		# New vpn server var
		nvram set vpn_serverx_start="$(nvram get vpn_serverx_eas)"

		# New neighbor solication var
		nvram set ipv6_ns_drop=0

		# Force display of media dirs
		nvram set dms_dir_manual=1
fi

if [[ $major -eq 374 && $minor -eq 43 ]]; then
		# Force jffs on
		if [ $(nvram get jffs2_on) == "0" ]; then
			nvram set jffs2_on="1"
			nvram set jffs2_format="1"
			nvram set jffs2_scripts="1"
		else
		# jffs already on, enable scripts
			nvram set jffs2_scripts="1"
		fi
fi

else
	logger -s -t $scr_name  "NVRAM Exception Processing - skipped for ASUS OEM Firmware"
fi # end asusno

if [[ $major -ge 376 ]]; then
		# Fix bad radio settings
		nvram set wl0_nband="2"
		nvram set wl1_nband="1"
fi

if [[ $major -ge 376 && $major_org -lt 376 ]]; then
		# Set traditional qos
		if [ $(nvram get qos_type) == "1" ]; then
			nvram set qos_type="0"
		fi
fi

exit 0