#!/bin/bash
ADOBEEXPIRYCHECK="/Library/Scripts/AdobeExpiryCheck"
if [ -x "$ADOBEEXPIRYCHECK" ]; then
	## CreativeCloud
	OUTPUT=`"$ADOBEEXPIRYCHECK" | grep 20181130 | grep CreativeCloud | cut -d" " -f1 | cut -d"." -f1`
	## Acrobat
	OUPTUT=`"$ADOBEEXPIRYCHECK" | grep 20181130 | grep Acrobat | cut -d" " -f1 | cut -d"." -f1`
	if [ -z "$OUTPUT" ]; then
		echo "No Serial"
	else
		echo "$OUTPUT"
	fi
else
	echo "Tool Not Installed"
fi
exit 0