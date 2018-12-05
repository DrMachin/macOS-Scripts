#!/bin/bash
LOG_NAME="COMPANY:CylancePROTECT"
if [[ `/usr/sbin/pkgutil --pkgs | grep -i com.cylance.agent` ]]; then
	if [[ `/usr/sbin/pkgutil --pkg-info=com.cylance.agent | grep -i 2.0.1500` ]]; then
		/usr/bin/logger -t $LOG_NAME "CylancePROTECT Already Updated"
	else
		/usr/bin/sudo "/Applications/Cylance/Uninstall CylancePROTECT.app/Contents/MacOS/Uninstall CylancePROTECT" --password="UNINSTALL_PASSWORD" --noui  > /dev/null 2>&1
	fi
fi