#!/bin/sh
## Use fswatch to monitor path(s) with legible output
## https://madcoda.com/2016/10/simple-command-monitor-directory-changes-on-mac/

fswatch -0 $@ | while read -d "" event; \
do \
    echo ${event};
done