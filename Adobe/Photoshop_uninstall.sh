#!/bin/sh
## Adobe Photoshop Uninstallers

## 2015.5
if [[ -d "/Applications/Adobe Photoshop CC 2015.5" ]]; then
	"/Applications/Utilities/Adobe Creative Cloud/HDCore/Setup" --uninstall=1 --sapCode=PHSP --baseVersion=17.0 --platform=osx10-64 --deleteUserPreferences=true
fi

## 2018
if [[ -d "/Applications/Adobe Photoshop CC 2018" ]]; then
	"/Applications/Utilities/Adobe Creative Cloud/HDCore/Setup" --uninstall=1 --sapCode=PHSP --baseVersion=19.0 --platform=osx10-64 --deleteUserPreferences=true
fi

## 2019
if [[ -d "/Applications/Adobe Photoshop CC 2019" ]]; then
	"/Applications/Utilities/Adobe Creative Cloud/HDCore/Setup" --uninstall=1 --sapCode=PHSP --baseVersion=20.0 --platform=osx10-64
fi

exit 0