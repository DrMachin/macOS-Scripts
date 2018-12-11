#!/bin/bash
# FlashPlayer Disable Auto Update Settings
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

CFG_FOLDER="/Library/Application Support/Macromedia"
CFG_FILE="${CFG_FOLDER}/mms.cfg"

if [[ -f "$CFG_FILE" ]]; then
	sed -i -e 's/AutoUpdateDisable=0/AutoUpdateDisable=1/g' "$CFG_FILE"
else
	mkdir -p "$CFG_FOLDER"
	echo "AutoUpdateDisable=1" > "$CFG_FILE" 
fi