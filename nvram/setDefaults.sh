#!/bin/bash

# Set variables
ROOT=/home/asus/asuswrt-merlin/release/src
FILE=$ROOT/router/shared/defaults.c

# Restore to stock defaults
cd $ROOT/router/shared
/usr/bin/git checkout -- .




# *** Set all nvram defaults ***
declare -A DEFAULTS # Declare array

# Set defaults needed to bypass the initial setup wizard
# and to set stock credentials
DEFAULTS[x_Setting]=1               # Bypass the QIS Wizard page
DEFAULTS[http_username]=admin       # Set default username to admin
DEFAULTS[http_passwd]=admin         # Set default ECRS password - to be changed before shipping

# Set defaults for settings that were removed from the UI
DEFAULTS[jffs2_format]=0            # Disable the "Format JFFS partition at next boot" - this would erase all custom scripts
DEFAULTS[jffs2_scripts]=1           # Enable support for JFFS custom scripts and configs
DEFAULTS[http_enable]=1             # HTTPS only over LAN
DEFAULTS[https_lanport]=443         # Port the router admin is accessible from on LAN
DEFAULTS[misc_http_x]=0             # Disable web access from WAN
DEFAULTS[misc_httpport_x]=0         # Disable http port for web access from WAN
DEFAULTS[misc_httpsport_x]=0        # Disable https port for web access from WAN
DEFAULTS[http_autologout]=30        # Set the auto logout to 30min
DEFAULTS[nat_redirect_enable]=0     # Disable the WAN down browser redirect notice
DEFAULTS[http_dut_redir]=0          # Disable webui access at router.asus.com
DEFAULTS[http_client]=0             # Disable the allow only specified IP address
DEFAULTS[sshd_enable]=2             # LAN only
DEFAULTS[sshd_forwarding]=0         # Disable SSH Port forwarding
DEFAULTS[sshd_port]=22              # Set SSH port
DEFAULTS[sshd_pass]=1               # Allow SSH password login
DEFAULTS[sshd_bfp]=1                # Enable SSH Bruteforce protection
DEFAULTS[sshd_authkeys]=""          # Clear any SSH Auth keys

# Set any other defaults available in defaults.c
DEFAULTS[time_zone]=EST5DST
DEFAULTS[ntp_server0]=pool.ntp.org
DEFAULTS[ntp_server1]=time.nist.giv
DEFAULTS[fw_pt_sip]=0
DEFAULTS[webdav_https_port]=8443

for D in "${!DEFAULTS[@]}";
do
    # awk is fucking stupid
    LINE=`/usr/bin/awk -F "," '/"'$D'"/ {$2=", \"'${DEFAULTS[$D]}'\" },"; print $1$2}' $FILE`
    # sed is almost as stupid
    /bin/sed --in-place -e 's/.*"'"$D"'".*/'"$LINE"'/g' $FILE
done




# *** Set default Wi-Fi values ***
# Remove defaults for Wi-Fi config values that are in defaults.c
REMOVE=(wl1_ssid)

for R in "${REMOVE[@]}";
do
    /bin/sed --in-place -e "/.*\"$R\".*/d" $FILE
done

# Set defaults for config values that are not in defaults.c
# wl0 = 2.4GHz, wl1 = 5GHz
declare -A DEFAULTS2 # Declare array
DEFAULTS2[wl0_radio]=1              # Enable the wireless radio
DEFAULTS2[wl1_radio]=1
DEFAULTS2[wl0_ssid]=ECRS24G         # Set the default SSID for 2.4GHz
DEFAULTS2[wl1_ssid]=ECRS5G
DEFAULTS2[wl0_closed]=0             # Do not hide the SSID
DEFAULTS2[wl1_closed]=0
DEFAULTS2[wl0_nmode_x]=0            # Set wireless mode to Auto (Auto, N Only, N/AC Mixed, Legacy)
DEFAULTS2[wl1_nmode_x]=0
DEFAULTS2[wl0_auth_mode_x]=psk2     # Set wireless Authentication Mode to WPA2-Personal (psk2)
DEFAULTS2[wl1_auth_mode_x]=psk2
DEFAULTS2[wl0_crypto]=aes           # Set the wireless cryptography to AES
DEFAULTS2[wl1_crypto]=aes
DEFAULTS2[wl0_wpa_psk]=changeme     # Set the default wireless password to "changeme"
DEFAULTS2[wl1_wpa_psk]=changeme
DEFAULTS2[time_zone_x]=EST5DST

LINE=`/bin/grep --line-number "\"wl_ssid\"" $FILE | /usr/bin/cut --delimiter=: --fields=1`
DEF=""
if [ $LINE ]
then
    if ! /bin/grep --quiet "wl0_radio" $FILE
    then
        for D in "${!DEFAULTS2[@]}";
        do
            DEF="$DEF{ \"$D\", \"${DEFAULTS2[$D]}\" },\n"
        done

        /bin/sed --in-place -e "${LINE}i${DEF}" $FILE
    fi
fi




# *** Set defaults for ECRS values ***
declare -A DEFAULTS3
DEFAULTS3[ecrs_vpn_bidirectional]=1		# Enable bidirectional comm script by default; can be disabled by vpn UI
DEFAULTS3[ecrs_hht_kiosk_enable]=0		# Do not enable prerouting to kiosk by default
DEFAULTS3[ecrs_hht_kiosk_ip]="10.217.1.2"	# Set the default kiosk IP address
DEFAULTS3[ecrs_backup_usb_enable]=0		# Set the USB backup to be disabled by default
DEFAULTS3[ecrs_backup_usb_status]=-1		# Set the USB backup status to be PENDING
DEFAULTS3[ecrs_backup_usb_failcount]=0		# Set the USB backup fail count to 0
DEFAULTS3[ecrs_backup_usb_notifycount]=0	# Set the USB backup notify count to 0
DEFAULTS3[ecrs_backup_usb_text]=""		# Set the USB backup text to empty
DEFAULTS3[ecrs_backup_usb_notifyurl]="https://support.ecrsoft.com/services/notifyAsusBackupFailed.php" # Set the USB backup notify url
DEFAULTS3[ecrs_myecrs_account_id]=""		# Set the myECRS account id to empty
DEFAULTS3[ecrs_myecrs_account_name]=""		# Set the myECRS account name to empty
DEFAULTS3[ecrs_router_serial]=""		# Set the router serial to empty

LINE=`/bin/grep --line-number "\"restore_defaults\"" $FILE | /usr/bin/cut --delimiter=: --fields=1`
DEF=""
if [ $LINE ]
then
    if ! /bin/grep --quiet "ecrs_vpn_bidirectional" $FILE
    then
        for D in "${!DEFAULTS3[@]}";
        do
            DEF="$DEF{ \"$D\", \"${DEFAULTS3[$D]}\" },\n"
        done

        /bin/sed --in-place -e "${LINE}i${DEF}" $FILE
    fi
fi
