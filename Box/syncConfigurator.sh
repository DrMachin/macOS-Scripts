#!/bin/sh
## Sync IPSW files from Shared folder in local Box Drive volume to Apple Configurator cache

currentuser=$(/usr/bin/stat -f%Su /dev/console)
HOME="/Users/${currentuser}"
BOX="${HOME}/Box"

SOURCE="${BOX}/Apple Configurator Files/Firmware"
DEST="${HOME}/Library/Group Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Firmware"


if [[ -d $SOURCE ]]; then
	echo Found $SOURCE
elif [[ -d $BOX ]]; then
	echo Box Drive mounted, but source folder not found
else
	echo Box Drive not mounted
fi
echo
if [[ -d $DEST ]]; then
	#find . -name "*.mkv" -exec rsync -av --progress  {} [destination]. \;
	find "${SOURCE}/" -name "*.ipsw" -exec rsync -av --progress {} "${DEST}/". \;
else
	echo Apple Configurator Firmware Cache Not Found
fi