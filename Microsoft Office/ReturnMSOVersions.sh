if [ -x "/Applications/Microsoft Word.app" ]; then /usr/bin/defaults read "/Applications/Microsoft Word.app/Contents/Info.plist" CFBundleShortVersionString ; else echo "Not Installed"; fi

if [ -x "/Applications/Microsoft Excel.app" ]; then /usr/bin/defaults read "/Applications/Microsoft Excel.app/Contents/Info.plist" CFBundleShortVersionString ; else echo "Not Installed"; fi

if [ -x "/Applications/Microsoft OneNote.app" ]; then /usr/bin/defaults read "/Applications/Microsoft OneNote.app/Contents/Info.plist" CFBundleShortVersionString ; else echo "Not Installed"; fi

if [ -x "/Applications/Microsoft Powerpoint.app" ]; then /usr/bin/defaults read "/Applications/Microsoft Powerpoint.app/Contents/Info.plist" CFBundleShortVersionString ; else echo "Not Installed"; fi

if [ -x "/Applications/Microsoft Outlook.app" ]; then /usr/bin/defaults read "/Applications/Microsoft Outlook.app/Contents/Info.plist" CFBundleShortVersionString ; else echo "Not Installed"; fi

if [ -x "/Applications/Skype for Business.app" ]; then /usr/bin/defaults read "/Applications/Skype for Business.app/Contents/Info.plist" CFBundleShortVersionString ; else echo "Not Installed"; fi
