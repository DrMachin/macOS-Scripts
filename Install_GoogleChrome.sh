#!/bin/bash
# Download & Install Google Chrome

DOWNLOAD_URL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
DOWNLOAD_TARGET="/tmp"
INSTALL_TARGET="/Applications/"
DMGNAME="googlechrome"
MOUNTPOINT="$DOWNLOAD_TARGET/googlechrome"
LOG_NAME="COMPANY:ChromeInstaller"

finalDownloadUrl=$(curl "$DOWNLOAD_URL" -s -L -I -o /dev/null -w '%{url_effective}')
pkgName=$(printf "%s" "${finalDownloadUrl[@]}" | sed 's@.*/@@')
pkgPath="$DOWNLOAD_TARGET/$pkgName"

logger -t $LOG_NAME "Downloading $pkgName"

# modified to attempt restartable downloads and prevent curl output to stderr
until curl --retry 1 --retry-max-time 180 --max-time 180 --fail --silent -L -C - "$finalDownloadUrl" -o "$pkgPath"; do
# Retries if the download takes more than 3 minutes and/or times out/fails
	logger -t $LOG_NAME "Preparing to re-try failed download: $pkgName"
    sleep 10
done

# mount dmg image
logger -t $LOG_NAME "Mounting $pkgName"
hdiutil attach "$pkgPath" -mountpoint "$MOUNTPOINT" > /dev/null 2>&1
agentPkg=`echo "$MOUNTPOINT"/*[Cc]hrome*.app`
logger -t $LOG_NAME "Moving to $INSTALL_TARGET"

# Move app to Applications folder
echo $agentPkg
echo $INSTALL_TARGET
cp -R "$agentPkg" $INSTALL_TARGET #> /dev/null 2>&1

logger -t $LOG_NAME "Unmounting $pkgName"
hdiutil detach "$MOUNTPOINT" > /dev/null 2>&1
logger -t $LOG_NAME "Cleaning Up"
rm "$pkgPath"

logger -t $LOG_NAME "Script Complete"