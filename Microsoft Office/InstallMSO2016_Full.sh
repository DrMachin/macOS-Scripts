#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");  you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# Not intended for prod ¯\_(ツ)_/¯ yet

# -- Modified from Script originally published at https://gist.github.com/opragel/bda5626c3b13c3fe5467
# -- Then modified from script from script published at https://code.vmware.com/samples/1447/airwatch---shell-script-to-install-microsoft-office-2016-for-mac
# -- Added Skype For Business

# Comment any download url below to skip install or change the order of items.
# These corresspond to the names set in my Custom Attributes.
OFFICE_PKGS=( \
  "Outlook" \
  "Word" \
  "Excel" \
  "PowerPoint" \
  "OneNote" \
  "SkypeForBusiness"
  "Autoupdater" \
  )

# DO NOT UNCOMMENT OR CHANGE ORDER.
DOWNLOAD_URLS=( \
  # Outlook
  "https://go.microsoft.com/fwlink/?linkid=525137" \
  # Word 
  "https://go.microsoft.com/fwlink/?linkid=525134" \
  # Excel
  "https://go.microsoft.com/fwlink/?linkid=525135" \
  # Powerpoint
  "https://go.microsoft.com/fwlink/?linkid=525136" \
  # Autoupdater
  "https://go.microsoft.com/fwlink/?linkid=830196" \
  # OneNote
  "http://go.microsoft.com/fwlink/?linkid=820886" \
  # Skype For Business
  "https://go.microsoft.com/fwlink/?linkid=832978" \
  )

MAU_PATH="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
SECOND_MAU_PATH="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app"
INSTALLER_TARGET="LocalSystem"

syslog -s -l notice "MSOFFICE2016 - Starting Download/Install sequence."

## Turn on a case-insensitive matching
shopt -s nocasematch

for packageName in "${OFFICE_PKGS[@]}"; do
  skipInstall=false
  #Check if individual packages are installed and skip
  case $packageName in
    *Outlook*)       #Outlook
      if [ -x "/Applications/Microsoft Outlook.app" ]; then
        skipInstall=true
      else
        downloadUrl=${DOWNLOAD_URLS[0]}
      fi
    ;;
    *Word*)          #Word
      if [ -x "/Applications/Microsoft Word.app" ]; then
        skipInstall=true
      else
        downloadUrl=${DOWNLOAD_URLS[1]}
      fi
    ;;
    *Excel*)         #Excel
      if [ -x "/Applications/Microsoft Excel.app" ]; then
        skipInstall=true
      else
        downloadUrl=${DOWNLOAD_URLS[2]}
      fi
    ;;
    *PowerPoint*)    #Powerpoint
      if [ -x "/Applications/Microsoft Powerpoint.app" ]; then
        skipInstall=true
      else
        downloadUrl=${DOWNLOAD_URLS[3]}
      fi
    ;;
    *Autoupdater*)   #AutoUpdater
      downloadUrl=${DOWNLOAD_URLS[4]}
    ;;
    *OneNote*)       #OneNote
      if [ -x "/Applications/Microsoft OneNote.app" ]; then
        skipInstall=true
      else
        downloadUrl=${DOWNLOAD_URLS[5]}
      fi
    ;;
    *SkypeForBusiness*)       #OneNote
      if [ -x "/Applications/Skype for Business.app" ]; then
        skipInstall=true
      else
        downloadUrl=${DOWNLOAD_URLS[6]}
      fi
    ;;
    *)                  #Just in case
      syslog -s -l warning "MSOFFICE2016 - Invalid Package Name: - $packageName"
      continue
    ;;
  esac

  if [ $skipInstall = true ]; then
    syslog -s -l notice "MSOFFICE2016 - Skipping Package: $packageName - Already Installed"
    continue
  fi

  finalDownloadUrl=$(curl "$downloadUrl" -s -L -I -o /dev/null -w '%{url_effective}')
  pkgName=$(printf "%s" "${finalDownloadUrl[@]}" | sed 's@.*/@@')
  pkgPath="/tmp/$pkgName"
  syslog -s -l notice "MSOFFICE2016 - Downloading $pkgName"
  # modified to attempt restartable downloads and prevent curl output to stderr
  until curl --retry 1 --retry-max-time 180 --max-time 180 --fail --silent -L -C - "$finalDownloadUrl" -o "$pkgPath"; do
  # Retries if the download takes more than 3 minutes and/or times out/fails
    syslog -s -l warning "MSOFFICE2016 - Preparing to re-try failed download: $pkgName"
    sleep 10
  done
  syslog -s -l warning "MSOFFICE2016 - Installing $pkgName"
  # run installer with stderr redirected to dev null
  installerExitCode=1
  while [ "$installerExitCode" -ne 0 ]; do
    sudo /usr/sbin/installer -pkg "$pkgPath" -target "$INSTALLER_TARGET" > /dev/null 2>&1
    installerExitCode=$?
    if [ "$installerExitCode" -ne 0 ]; then
      syslog -s -l error "MSOFFICE2016 - Failed to install: $pkgPath"
      syslog -s -l error "MSOFFICE2016 - Installer exit code: $installerExitCode"
    fi
  done
  if [ "$installerExitCode" -eq 0 ]; then
    syslog -s -l notice "MSOFFICE2016 - Successfully Installed $pkgName"
  fi
  rm "$pkgPath"

done

## Turn off a case-insensitive matching
shopt -u nocasematch

# -- Modified from Script originally published at https://gist.github.com/erikng/7cede5be1c0ae2f85435
syslog -s -l error "MSOFFICE2016 - Registering Microsoft Auto Update (MAU)"
if [ -e "$MAU_PATH" ]; then
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "$MAU_PATH"
  if [ -e "$SECOND_MAU_PATH" ]; then
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "$SECOND_MAU_PATH"
  fi
fi
syslog -s -l notice "MSOFFICE2016 - SCRIPT COMPLETE"