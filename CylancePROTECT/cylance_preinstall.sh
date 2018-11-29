#!/bin/bash
#CylancePROTECT agent pre-install script
#Also required for updating package

##FOLDER LOCATIONS
UNINSTALL="/Applications/Cylance/Uninstall CylancePROTECT.app/Contents/MacOS/Uninstall CylancePROTECT"
PASSWORD="INSTALL_PASSWORD"

## Check if Uninstaller exists
if /bin/[ -x "$UNINSTALL" ]; then 
    "$UNINSTALL" --password="${PASSWORD}uninstall" --noui
fi

## Create Install Token File
## File from Cylance pkg postinstall script
## NoCylanceUI to hide icon from menubar
/bin/cat > /tmp/YvUnIpzc2omyt1ln << EOF
$PASSWORD
NoCylanceUI
EOF

exit 0