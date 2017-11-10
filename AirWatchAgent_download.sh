#!/bin/bash
# Download & Install Latest AirWatch Agent for macOS

DOWNLOAD_URL="https://awagent.com/Home/DownloadMacOsxAgentApplication"
DOWNLOAD_TARGET="/tmp"
INSTALLER_TARGET="LocalSystem"
DMGNAME="AirWatchAgent"

downloadUrl=$(curl "$DOWNLOAD_URL" -s -L -I -o /dev/null -w '%{url_effective}')
pkgName=$(printf "%s" "${downloadUrl[@]}" | sed 's@.*/@@')
pkgPath="$DOWNLOAD_TARGET/$pkgName"


# modified to attempt restartable downloads and prevent curl output to stderr
until curl --retry 1 --retry-max-time 180 --max-time 180 --fail --silent -L -C - "$downloadUrl" -o "$pkgPath"; do
# Retries if the download takes more than 3 minutes and/or times out/fails
	syslog -s -l warning "AWAGENT - Preparing to re-try failed download: $pkgName"
    sleep 10
done
#mount dmg image
syslog -s -l Info "AWAGENT - Mounting $pkgName"
hdiutil attach "$pkgPath" > /dev/null 2>&1
agentPkg=`echo /Volumes/$DMGNAME/*[Aa]gent*.pkg`
syslog -s -l Info "AWAGENT - Installing Agent"
# run installer with stderr redirected to dev null

installerExitCode=1
while [ "$installerExitCode" -ne 0 ]; do
	sudo /usr/sbin/installer -pkg "$agentPkg" -target "$INSTALLER_TARGET" > /dev/null 2>&1
	installerExitCode=$?
	if [ "$installerExitCode" -ne 0 ]; then
		syslog -s -l error "AWAGENT - Failed to install: $pkgPath"
		syslog -s -l error "AWAGENT - Installer exit code: $installerExitCode"
	fi
done
if [ "$installerExitCode" -eq 0 ]; then
syslog -s -l Info "AWAGENT - Successfully Installed $pkgName"
fi
hdiutil detach "/Volumes/$DMGNAME" > /dev/null 2>&1
rm "$pkgPath"