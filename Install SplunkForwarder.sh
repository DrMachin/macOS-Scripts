#!/bin/bash
#Install or Upgrade Splunk Forwarder

##FOLDER LOCATIONS
DOWNLOAD="/tmp"
TARGET="/Applications"
SPLUNK="$TARGET/splunkforwarder/bin/splunk"
LOG_NAME="COMPANY:SplunkForwarder"

logger -t $LOG_NAME "Starting Splunk Install"

if [ -x "$SPLUNK" ]; then 
	logger -t $LOG_NAME "Stopping Splunk"
	$SPLUNK stop > /dev/null 2>&1; 
fi

logger -t $LOG_NAME "Unpacking to $TARGET"
tar -xzf "$DOWNLOAD/"splunkforwarder*.tgz -C $TARGET/
chflags hidden /Applications/splunkForwarder

logger -t $LOG_NAME "Staring service"
$SPLUNK start --accept-license --answer-yes > /dev/null 2>&1
$SPLUNK enable boot-start > /dev/null 2>&1
logger -t $LOG_NAME "Setting server"
$SPLUNK set deploy-poll SERVERADDRESS:PORT -auth USER:PASS > /dev/null 2>&1
logger -t $LOG_NAME "Restaring service"
$SPLUNK restart > /dev/null 2>&1

logger -t $LOG_NAME "Install complete"