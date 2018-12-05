#!/usr/bin/python

import sys
import subprocess
from pkg_resources import parse_version

deployversion = '4.0.7-5'
plistFile = '/Applications/GlobalProtect.app/Contents/Info.plist'
plistKey = 'CFBundleShortVersionString'

#Get Version Number
currentversion = str(subprocess.check_output(['defaults','read',plistFile, plistKey])).rstrip()
print currentversion

#Compare Versions
if parse_version(currentversion) < parse_version(deployversion):
	#Install
	sys.exit(0)
else:
	#Don't Install
	sys.exit(1)