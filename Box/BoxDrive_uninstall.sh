#!/bin/sh
## https://community.box.com/t5/Getting-Started-with-Box-Drive/Uninstalling-Box-Drive/ta-p/35833

/usr/bin/pkill -f "/Applications/Box.app"
/Library/Application\ Support/Box/uninstall_box_drive_r

exit 0