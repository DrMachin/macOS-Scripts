#!/bin/bash
#CylancePROTECT agent uninstall script

##FOLDER LOCATIONS
UNINSTALL="/Applications/Cylance/Uninstall CylancePROTECT.app/Contents/MacOS/Uninstall CylancePROTECT"
PASSWORD="INSTALL_PASSWORD"

"$UNINSTALL" --password="${PASSWORD}uninstall" --noui
## Forget Receipt (Just in case)
/usr/sbin/pkgutil --forget com.cylance.agent

exit 0