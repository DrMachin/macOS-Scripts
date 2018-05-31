#!/bin/bash
#Install or Upgrade Splunk Forwarder

##------------VARIABLES-----------
##FILE/FOLDER LOCATIONS
DOWNLOAD="/tmp"
LIMITS="$DOWNLOAD/limits.conf"
USERSEED="$DOWNLOAD/user-seed.conf"
TARGET="/Applications"
APPROOT="$TARGET/splunkforwarder"
SPLUNK="$APPROOT/bin/splunk"
LOG_NAME="COMPANY:SplunkForwarder"

##CONFIG DETAILS
SERV_IP="SERVERADDRESS:PORT"
AUTH="USER:PASS"
##---------------------------------

logger -t $LOG_NAME "Starting Splunk Install"

if [ -x "$SPLUNK" ]; then 
	logger -t $LOG_NAME "Stopping Splunk"
	$SPLUNK stop > /dev/null 2>&1
	rm -r "$APPROOT"
fi

## Unpack to Applications folder
logger -t $LOG_NAME "Unpacking to $TARGET"
tar -xzf "$DOWNLOAD/"splunkforwarder*.t[ag][rz] -C $TARGET/
# Move config file
mv $LIMITS "$APPROOT/etc/system/local/"
mv $USERSEED "$APPROOT/etc/system/local/"
# Hide application folder
chflags hidden $APPROOT

#Add server settings
logger -t $LOG_NAME "Setting server"
$SPLUNK set deploy-poll "$SERV_IP" -auth "$AUTH" --accept-license --answer-yes --auto-ports --no-prompt > /dev/null 2>&1 

#Start Service
logger -t $LOG_NAME "Staring service"
$SPLUNK enable boot-start > /dev/null 2>&1
$SPLUNK start --accept-license --answer-yes --no-prompt > /dev/null 2>&1

logger -t $LOG_NAME "Install complete"