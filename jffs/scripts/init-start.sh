#!/bin/sh

# Force reset of dangerous nvram values
#nvram set jffs2_format="0"
#nvram set jffs2_scripts="1"

#nvram set http_enable="1"
#nvram set https_lanport="443"
#nvram set misc_http_x="0"
#nvram set misc_httpport_x="0"
#nvram set misc_httpsport_x="0"
#nvram set http_autologout="30"
#nvram set nat_redirect_enable="0"
#nvram set http_dut_redir="0"
#nvram set http_client="0"

#nvram set sshd_enable="2"
#nvram set sshd_forwarding="0"
#nvram set sshd_port="22"
#nvram set sshd_pass="1"
#nvram set sshd_bfp="1"
#set sshd_authkeys=""

nvram set ecrs_test="This is a test"

nvram commit
