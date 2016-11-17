#!/bin/sh


BACKUPDIR=/jffs/nvram-save
ARCHIVEDIR=/tmp/mnt/ASUS/archive


# Fail function
backupfail()
{
    FAILCOUNT=$(/bin/nvram get ecrs_backup_usb_failcount)
    FAILCOUNT=$((FAILCOUNT+1))
    
    /bin/nvram set ecrs_backup_usb_failcount=$FAILCOUNT
    /bin/nvram set ecrs_backup_usb_status=1

    if [ "$1" -eq "1" ]
    then
        MSG="Cannot locate backup medium"
    elif [ "$1" -eq "2" ]
    then
        MSG="Failed to create backup"
    elif [ "$1" -eq "3" ]
    then
        MSG="Failed to archive backup"
    elif [ "$1" -eq "4" ]
    then
        MSG="Cannot locate USB archive"
    else
        MSG="Unknown reason"
    fi

    /usr/bin/logger -t "USB BACKUP" "Failed to create scheduled backup - $MSG"
    /bin/nvram set ecrs_backup_usb_text="$MSG"
    
    /bin/nvram commit
    
    exit 1
}


# Success function
backupsuccess()
{
    TS=$(date +"%B %d, %Y %r")

    /bin/nvram set ecrs_backup_usb_status=0
    /bin/nvram set ecrs_backup_usb_failcount=0
    /bin/nvram set ecrs_backup_usb_notifycount=0
    /bin/nvram set ecrs_backup_usb_text="Last run: $TS"
    
    /usr/bin/logger -t "USB BACKUP" "Successfully created scheduled backup - $ARCHIVEDIR/$1.tar.gz"
    
    /bin/nvram commit
    
    exit 0
}


# Notify function
notify()
{
    /usr/bin/logger -t "USB BACKUP" "Sending backup notification"

    # Send email to support
    # How do?
    # /usr/sbin/sendmail -f info@ecrs.com -S smtp-relay.gmail.com -w 10 astclair@ecrs.com "Test Subject" "Test message text"
}




# Only perform the usb backup steps if it is enabled
USBBACKUPENABLED=$(/bin/nvram get ecrs_backup_usb_enable)
if [ "$USBBACKUPENABLED" -eq "1" ]
then
    /usr/bin/logger -t "USB BACKUP" "Starting USB backup"

    # Check if backup has failed for more than 7 days
    FAILCOUNT=$(/bin/nvram get ecrs_backup_usb_failcount)
    NOTIFYCOUNT=$(/bin/nvram get ecrs_backup_usb_notifycount)
    if [ "$FAILCOUNT" -ge "7" ]
    then
        # If 7 days have passed since the last time the notification was sent
        if [ "$(expr $FAILCOUNT / 7)" -gt "$NOTIFYCOUNT" ]
        then
            notify
            NOTIFYCOUNT=$((NOTIFYCOUNT+1))
            /bin/nvram set ecrs_backup_usb_notifycount=$NOTIFYCOUNT
        fi
    fi
    
    
    # Check if backups need rotating
    #
    # Qualifications for rotation:
    #     If 30 or more backup archives exist
    #         1. Move earliest file available into archive/weekly
    #         2. Remove earliest seven files avalable in archive
    if [ "$(/bin/ls -p "$ARCHIVEDIR" | /bin/grep -vc /)" -ge "30" ]
    then
        /usr/bin/logger -t "USB BACKUP" "Rotating weekly archive"

        # Obtain earliest (by timestamp) file in archive directory
        ONE=$(/bin/ls -pltr "$ARCHIVEDIR" | /bin/grep -v / | /usr/bin/awk '{print $9}' | /usr/bin/head -n 1)
        /usr/bin/logger -t "USB BACKUP" "Moving ${ARCHIVEDIR}/${ONE} to ${ARCHIVEDIR}/weekly/${ONE}"
        /bin/mv "$ARCHIVEDIR/$ONE" "$ARCHIVEDIR/weekly"
        
        # No arrays in standard sh, so do this manually
	i=0
	while [ $i -lt 6 ]
	do
            /usr/bin/logger -t "USB BACKUP" "Purging ${ARCHIVEDIR}/${FILE}"
            FILE=$(/bin/ls -pltr "$ARCHIVEDIR" | /bin/grep -v / | /usr/bin/awk '{print $9}' | /usr/bin/head -n 1)
            /bin/rm "$ARCHIVEDIR/$FILE"
            true $(( i++ ))
        done
    fi
    
    
    # After accounting for backup failures and the need to
    # rotate backups, attempt to create new backup
    if [ ! -d "$BACKUPDIR" ]
    then
        backupfail 1
    else
        TS=$(date +"%Y%m%d%H%M")
        
        # Try to do a backup
        if /bin/sh "$BACKUPDIR/nvram-save.sh" -nojffs -m -i "$BACKUPDIR/nvram-ecrs.ini"
        then
            # Verify archive directory exists
            if [ -d "$ARCHIVEDIR" ]
            then
                # Compress and archive backup
                if /bin/tar -zcf "$ARCHIVEDIR/$TS.tar.gz" "$BACKUPDIR/backup"
                then
                    /bin/rm -rf "$BACKUPDIR/backup"
                    /bin/mkdir "$BACKUPDIR/backup"
                    backupsuccess "$TS"
                else
                    backupfail 3
                fi
             else
                 backupfail 4
             fi
        else
            backupfail 2
        fi
    fi
fi
