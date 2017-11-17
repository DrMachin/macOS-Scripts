#!/bin/sh
LOG_NAME="COMPANY:FileShareMounter"

if [ ! -e /Library/Scripts/Enterprise-Connect/LoginFileShareMounter.py ]; then
	logger -t LOG_NAME "LoginFileShareMounter script not found"
else
	logger -t LOG_NAME "Starting Mount Script"
	python /Library/Scripts/Enterprise-Connect/LoginFileShareMounter.py $1 $2
fi

exit 0