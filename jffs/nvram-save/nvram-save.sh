#!/bin/sh

# nvram-save.sh
# Save nvram user variables for restore after factory reset

# Changelog
#------------------------------------------------
# Version 24			    2-May-2016
# - add hhmm to file timestamp naming
#
# Version 23			    3-April-2016
# - pass macid to exception processing
#
# Version 22			    27-October-2015
# - show version numbers with -v
# - print ini version to syslog
# - add ini version to runlog
# - only set file permissions on non-FAT format drives
#
# Version 21			    6-August-2015
# - fix call to exception processing if not running from current directory
#
# Version 20			    3-August-2015
# - enable running script from other than current directory
# - strip CR from custom strings during save
#
# Version 19			    16-June-2015	
# - version update only for ini
#
# Version 18			    14-June-2015	
# - add -clean option (for nvram-restore) to only 
#   only restore nvram variables which exist
#   (useful if backleveling fw to clean 
#   nvram variables added for new function)
# - force clean mode when generating migration script
# - add codelevel to runlog
# - remove sort for nvram-all saved text file
#
# Version 17			    29-April-2015
# - version update only for ini
#
# Version 16			    16-April-2015
# - add -nouser option to not execute user script
# - implement runlog to aid in restore operations
# - add consistency check for nvram-restore.sh
#
# Version 15			    25-February-2015
# - add help option -h
# - add print version option -v (also perform consistency chk)
# - add option to specify custom ini -i inifile
# - add -clk option to include clkfreq var
# - add -nojffs option to NOT backup jffs
# - consistency check for script/ini versions during runtime
# - save txt files of all and usr nvram variables
#
# Version 14			    7-February-2015
# - add version info to save/restore scripts
# - escape back-quote and double-quote characters
# - change handling of embedded lf chars
# - add short delay after commit before exiting script
# - changed name of inifile to indicate code family supported
# - log results of save and restore scripts to syslog
#
# Version 12			    1-February-2015
# - add nvram var for previous code level
# - add call to user exit nvram-user.sh	
#
# Version 11                        29-January-2015
# - add exit for code specific updates
#
# Version 10                        18-January-2015
# - backup /jffs if it exists
#
# Version 9              	    24-December-2014
# - nvram.ini update only
#
# Version 8                         17-December-2014
# - nvram.ini update only
#
# Version 7                         12-December-2014
# - nvram.ini update only
#
# Version 6			    3-December-2014
# - handle '$' special character
#
# Version 5                         20-November-2014
# - nvram.ini update only
#
# Version 4                         03-November-2014
# - Added Backup/Migration modes (switch -M)
#
# Version 3a                        28-October-2014
# - Fix getting mac address for AC87U
#
# Version 2                         14-October-2014
# - Add last two mac address bytes
#       to output restore file name (allows saving
#       restore files from multiple routers to one
#       USB stick)
#
# Version 1                         11-Sepember-2014
# - Initial release
#
#------------------------------------------------
# variable definitions
version=24
codename=merlin                 # Configured for asuswrt-merlin, asus-oem
buildno=$(nvram get buildno)
extendno=$(nvram get extendno)
lval=$(echo ${#extendno})
    if [ $lval -gt 0 ]; then
	codelevel=$buildno\_$extendno
    else
	codelevel=$buildno
    fi

# filename definitions
#cwd=$(pwd)
cwd=$(dirname $(readlink -f $0))
if [[ -d "$cwd/backup" ]]; then
	dwd=$cwd/backup;
else
	dwd=$cwd
fi
mntpnt=$(echo "$cwd" | awk -F'/' '{ print "/"$2"/"$3"/"$4 }')
isfat=0
isfat=0; mount | grep "$mntpnt" | grep -q "fat" && let isfat=1
restorescript="nvram-restore"
nvramall="nvram-all"
nvramusr="nvram-usr"
dash="-"
space4="    "
inifile=nvram-$codename.ini
excfile=nvram-excp-$codename.sh
jffsfile=jffs-restore.sh
restfile=nvram-restore.sh	
rundate=$(date +%Y%m%d%H%M)
migrate=0
jffsbackup=1
userscript=1
clean=1
setstring="nvram set"
skipvar="#### clkfreq"
initype="standard"
cmdopts="$*"
scr_name=$(basename $0)
runlog="$cwd/nvram-util.log"

while [[ $# -gt 0 ]]; do
input=$1
case "$input" in
	"-H"|"-h")
		echo "NVRAM User Save/Restore Utility"
		echo "nvram-save.sh Version $version"
		echo " Options: -h           this help msg"
		echo "          -v           Print version/perform consistency check"
		echo "          -b           Backup mode - save for restore to same router (default)"
		echo "          -m           Migration mode - transfer settings to another router"
		echo "          -i inifile   Specify custom nvram variable ini file"
		echo "          -clk         Include clkfreq/overclock setting (Backup mode only)"
		echo "          -nojffs      Skip backup of jffs storage"
		echo "          -nouser      Skip execution of user exit script"
#		echo "          -noclean     Create old style restore script to restore all variables only"
		echo ""
		exit 0
		;;
        "-M"|"-m")
                migrate=1
                ;;
	"-I"|"-i")
		inifile=$2
		initype="custom"
		shift
		;;
        "-B"|"-b")
                migrate=0
                ;;
	"-V"|"-v")
		echo "NVRAM User Save/Restore Utility"
		echo "Working Directory $cwd"
		echo ""
		echo "$scr_name Version=$version" | awk '{ printf "%-30s %-20s\n", $1, $2}'
		echo "$inifile `grep -m 1 "Version=" $cwd/$inifile | sed 's/#//'`" | awk '{ printf "%-30s %-13s", $1, $2}' && \
		grep -q "Version=$version" "$cwd/$inifile"  && echo "" || echo "<<< WARNING: mismatched version"
		echo "$excfile `grep -m 1 "Version=" $cwd/$excfile | sed 's/#//'`" | awk '{ printf "%-30s %-13s", $1, $2}' && \
		grep -q "Version=$version" "$cwd/$excfile"  && echo "" || echo "<<< WARNING: mismatched version"
		echo "$restfile `grep -m 1 "Version=" $cwd/$restfile | sed 's/#//'`" | awk '{ printf "%-30s %-13s", $1, $2}' && \
		grep -q "Version=$version" "$cwd/$restfile" && echo "" || echo "<<< WARNING: mismatched version"
		echo "$jffsfile `grep -m 1 "Version=" $cwd/$jffsfile | sed 's/#//'`" | awk '{ printf "%-30s %-13s", $1, $2}' && \
		grep -q "Version=$version" "$cwd/$jffsfile" && echo "" || echo "<<< WARNING: mismatched version"
		echo ""
		exit 0
		;;
	"-nojffs"|"-NOJFFS")
		jffsbackup=0
		;;
	"-nouser"|"-NOUSER")
		userscript=0
		;;
	"-clk"|"-CLK")
		skipvar=${skipvar//clkfreq/} # for include -clk option
		;;
	"-noclean"|"-NOCLEAN")
		clean=0
		;;
	*)
		echo "Unknown option $1"
		echo "Program exit"
		echo ""
		exit 1
		;;
        esac
shift
done

# start of script
echo ""
logger -s -t $scr_name  "NVRAM User Save Utility - Version $version"
logger -s -t $scr_name  "Saving settings from firmware "$codelevel
if [ "${#cmdopts}" -gt 0 ]; then
	logger -s -t $scr_name  "Runtime options: $cmdopts"
fi

# check for ini file
if [[ $inifile == "${inifile##*/}" ]]; then
	infile=$cwd/$inifile
else
	infile=$inifile
fi
if [ ! -f "$infile" ]; then
	logger -s -t $scr_name  "NVRAM variable file not found: $inifile"
	echo "Program exit"
	echo ""
	exit 2
else
	logger -s -t $scr_name  "Using $initype NVRAM variable file: $inifile `grep "Version=" $infile | sed 's/#//'`"		
fi

# set mode vars
if [ $migrate = 0 ]; then
	macid=$(nvram get "et0macaddr")
	if [ "$macid" = "" ]; then
		macid=$(nvram get "et1macaddr")
	fi
	macid=`echo $macid | cut -d':' -f 5,6 | tr -d ':' | tr 'a-z' 'A-Z'`
	logger -s -t $scr_name  "Running in Backup Mode"
else
	macid="MIGR"
	logger -s -t $scr_name  "Running in Migration Mode"
fi

if [ "$initype" = "standard" ]; then
	grep -q "Version=$version" "$infile" || logger -s -t $scr_name  "WARNING: $inifile is mismatched version"
fi
grep -q "Version=$version" "$cwd/$excfile"  || logger -s -t $scr_name  "WARNING: $excfile is mismatched version"
grep -q "Version=$version" "$cwd/$restfile" || logger -s -t $scr_name  "WARNING: $restfile is mismatched version"
grep -q "Version=$version" "$cwd/$jffsfile" || logger -s -t $scr_name  "WARNING: $jffsfile is mismatched version"


# versioned file definitions
#if [ $clean = 1 ]; then
#	restorescript="nvram-clean-restore"
#fi
outfile="$dwd/$restorescript$dash$rundate$dash$macid.sh"
nvramallfile="$dwd/$nvramall$dash$rundate$dash$macid.txt"
nvramusrfile="$dwd/$nvramusr$dash$rundate$dash$macid.txt"

# generate the restore script based on ini file
echo "#!/bin/sh" >$outfile
echo >>$outfile
echo "# generated script to restore user nvram settings" >>$outfile
echo "scr_name=\"nvram-restore\"" >>$outfile
echo >>$outfile
echo "echo \"\"" >>$outfile
echo "logger -s -t \$scr_name \"NVRAM User Restore Utility - Version $version\"" >>$outfile
echo "logger -s -t \$scr_name \"Using $initype NVRAM variable file: $inifile `grep "Version=" $infile | sed 's/#//'`\"" >>$outfile
echo "logger -s -t \$scr_name \"Restoring settings from firmware $codelevel $rundate$dash$macid\"" >>$outfile
echo "`grep "#Version=" $infile`" >>$outfile
echo "codelevel=$codelevel" >>$outfile
if [ $clean = 1 ]; then
	echo "tmpfile=/tmp/nvram-clean.lst" >>$outfile
	if [ $migrate = 1 ]; then
		echo "op=\"-clean\"" >>$outfile
	else 
		echo "op=\$1" >>$outfile
	fi
	echo "if [ \"\$op\" == \"-clean\" ]; then" >>$outfile
	echo "op=false" >>$outfile
	echo "nvram show 2>/dev/null | sort | awk -F\"=\" '{print \$1}' >\$tmpfile" >>$outfile
	echo "logger -s -t \$scr_name \"Clean NVRAM option specified\"" >>$outfile
	echo "else" >>$outfile
	echo "op=true" >>$outfile
	echo "echo \"NvRaM NoClEaN\" >\$tmpfile" >>$outfile 
	echo "fi" >>$outfile
fi
echo "echo \"\"" >>$outfile
echo >>$outfile
echo "nvram set buildno_org="$(nvram get buildno) >>$outfile

# backup all nvram vars to text file
echo "All NVRAM Settings $rundate $macid" >$nvramallfile
echo "WARNING: Some values in this file contain system parameters which should not be user modified" >>$nvramallfile
echo "" >>$nvramallfile
nvram show 2>/dev/null >>$nvramallfile
if [ $isfat = 0 ]; then
	chmod a-x $nvramallfile
fi

#initialize nvram-usr text file
echo "NVRAM Saved User Settings $rundate $macid" >$nvramusrfile
echo "" >>$nvramusrfile

echo ""
processvar=1
while read var
do
    lvar=$(echo ${#var})

    # Skip blank lines
    if [ $lvar -eq 0 ]; then
        continue
    fi

    linetype=${var:0:1}
    sectionexcl=${var:0:2}

    # skip excluded section
    if [ "$sectionexcl" = "#[" ]; then
        processvar=0
        continue
    fi

    # skip comments
    if [ "$linetype" = "#" ]; then
        continue
    fi

    # output category header
    if [ "$linetype" = "[" ]; then
        echo "Saving "$var
        echo "" >>$outfile
	echo "echo \"Restoring $var\"" >>$outfile
	
	echo "" >>$nvramusrfile
	echo $var >>$nvramusrfile

        processvar=1
        continue
    fi

    # skip vars in migrate mode
    if [ "$linetype" = "@" ]; then
        if [ $migrate = 1 ]; then
		# echo "Skipping "$var
		continue
        else
		let vlength=lvar-1
		var=${var:1:$vlength}
        fi
    fi

    # get and write nvram values
    if [ $processvar = 1 ] && [ "$skipvar" == "${skipvar%$var*}" ]; then
        value=$(nvram get $var)
        lval=$(echo ${#value})
        if [ $lval -gt 0 ]; then
	    	value=${value//$/\\$} 		# escape $ char
	    	value=${value//\"/\\\"}		# escape " char
	    	value=${value//\`/\\\`} 	# escape ` char
	    	esc=`expr index "$value" $'\n'`		# check for lf escape sequence
		if [ $clean = 1 ]; then
			grepstring="(\$op || grep -q \"$var\" \$tmpfile) &&"
			skipstring="|| echo -e \"\tSkipping $var\""
		else
			grepstring=""
			skipstring=""
		fi
            	if [ $esc -gt 0 ]; then
			valuex=${value//$'\r'/}		# remove cr
			valuex=${valuex//$'\n'/\\n}	# convert lf to escape sequence		
       			echo "$grepstring \$($setstring $var=\"\$(echo -e \"$valuex\")\") $skipstring" >>$outfile
			echo "$var=\"$value\"" >>$nvramusrfile
	    	else
			echo "$grepstring \$($setstring $var=\"$value\") $skipstring" >>$outfile
			echo "$var=\"$value\"" >>$nvramusrfile	
            	fi
    	fi
    else
        continue
    fi
done < $infile

echo "" >>$outfile
echo "echo \"\"" >>$outfile
if [ $isfat = 0 ]; then
	chmod a-x $nvramusrfile
fi

# Process code specific changes
if [ -f "$cwd/$excfile" ]; then
	echo "logger -s -t \$scr_name \"Applying code level exceptions $cwd/$excfile\"" >>$outfile
	echo "sh $cwd/$excfile $macid" >>$outfile
	echo "echo \"\"" >>$outfile
	echo "" >>$outfile
fi

# commit changes and close restore script
if [ $clean = 1 ]; then
	echo "rm -f \$tmpfile" >>$outfile
fi
echo "nvram commit" >>$outfile
echo "sleep 5" >>$outfile
echo "" >>$outfile
echo "logger -s -t \$scr_name  \"Complete: User NVRAM restored\"" >>$outfile
echo "echo \"Please reboot\"" >>$outfile
echo "echo \"\"" >>$outfile
echo "" >>$outfile
echo "exit 0" >>$outfile
if [ $isfat = 0 ]; then
	chmod 755 $outfile
fi

echo ""
logger -s -t $scr_name  "Complete: User NVRAM saved to "$outfile
echo ""
# Update runlog
echo "$(printf "%-20s" $scr_name)$(printf "%-20s" $rundate$dash$macid)$(date)$space4$(printf "%-20s" $codelevel)`grep "#Version=" $infile`" >>$runlog


# backup jffs storage if configured
if [[ -d "/jffs" && $jffsbackup -eq 1 ]]; then
        jffsdir="$dwd/jffs$dash$rundate$dash$macid"

        if [ ! -d "$jffsdir" ]; then
            mkdir "$jffsdir"
        fi
	if [ $isfat = 0 ]; then
	    cp -af "/jffs/." "$jffsdir"
	else
	    cp -dRf "/jffs/." "$jffsdir"
	fi
	touch "$jffsdir"
        logger -s -t $scr_name  "Complete: JFFS directory saved to "$jffsdir
        echo ""
	# Update runlog
	echo "$(printf "%-20s" jffs-save)$(printf "%-20s" $rundate$dash$macid)$(date)" >>$runlog

fi

# Process user exit if it exists
if [[ -f "$cwd/nvram-user.sh" && $userscript -eq 1 ]] ; then
	sh $cwd/nvram-user.sh $dash$rundate$dash$macid $dwd
	logger -s -t $scr_name  "Complete: Processed user exit script "$cwd"/nvram-user.sh"
	echo ""
fi

exit 0
