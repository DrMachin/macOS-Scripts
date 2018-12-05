#!/bin/sh

BDRIVE="/Applications/Box.app"
BSYNC="/Applications/Box Sync.app"
currentuser=$(/usr/bin/stat -f%Su /dev/console)

#Check if Box Sync is installed and remove
if /bin/[ -x "$BSYNC" ]; then
    /usr/bin/pkill -f "$BSYNC"
    /bin/rm -r "$BSYNC"
    /bin/rm -rf "/Users/${currentuser}/Library/Application Support/Box/Box Sync/"
    /bin/rm -rf "/Users/${currentuser}/Library/Logs/Box/Box Sync/"
    /bin/rm -f "/Library/PrivilegedHelperTools/com.box.sync.bootstrapper"
    /bin/rm -f "/Library/PrivilegedHelperTools/com.box.sync.iconhelper"
fi

#Check if Box Drive is currently running (for updates)
if /bin/[ -x "$BDRIVE" ]; then
    /usr/bin/pkill -f "$BDRIVE"
fi

exit 0