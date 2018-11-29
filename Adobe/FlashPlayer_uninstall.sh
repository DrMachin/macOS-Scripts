#!/bin/bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

MANAPP="/Applications/Utilities/Adobe Flash Player Install Manager.app"
MANAGER="${MANAPP}/Contents/MacOS/Adobe Flash Player Install Manager"

if [[ -d "$MANAPP" ]]; then
   "$MANAGER" -uninstall
   if [[ -d "$MANAPP" ]]; then
       echo "Adobe Flash was NOT removed"
       exit 1
   else
       echo "Adobe Flash was successfully removed"
       exit 0
   fi
else
   echo "Adobe Flash Player Install Manager not found"
   exit 0
fi