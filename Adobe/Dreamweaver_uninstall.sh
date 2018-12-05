#!/bin/sh
## Adobe Dreamweaver Uninstallers

## 2019
if [[ -d "/Applications/Adobe Dreamweaver CC 2019" ]]; then
	"/Applications/Utilities/Adobe Creative Cloud/HDCore/Setup" --uninstall=1 --sapCode=DRWV --baseVersion=19.0 --platform=osx10-64
fi

exit 0