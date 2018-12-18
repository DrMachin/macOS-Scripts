#!/usr/bin/python
#serial_number=2018121801
#serial above is yyyymmdd## for when the script is updated
#Tested with Enterprise Connect v1.9.5

import subprocess
import sys
import platform
import syslog
from SystemConfiguration import SCDynamicStoreCopyConsoleUser
from distutils.version import StrictVersion

### From https://gist.github.com/pudquick/1362a8908be01e23041d
### Modified From https://gist.github.com/ehemmete/2f893815bd03d96d89855feb4e9b7237
import objc, CoreFoundation, Foundation
from CoreFoundation import CFPreferencesCopyAppValue

#############################################
##### File Share Settings
con_type = 'smb://'
g_drive = '/FOLDER'
    
##### AD Group and Path
ad_groups = {
    #'AD GROUP' : 'NETWORK PATH',
    'SECURITY-GROUP1'       :   'SERVER-PATH' + g_drive,
    'SECURITY-GROUP2'       :   'SERVER-PATH' + g_drive + '/MIS_DEPT'
}

##### LOG SETTINGS
log_name = 'COMPANY:FileShareMounter'

##### Enterprise Connect Settings
## Plist File Name
plistFileName = 'com.apple.Enterprise-Connect.plist'
## Path to Enterprise Connect CLI
_ECCL = '/Applications/Enterprise Connect.app/Contents/SharedSupport/eccl'
#############################################

syslog.openlog(log_name)

def log(message):
    #Log Progress and Errors to Syslog
    if message is not None:
        syslog.syslog(syslog.LOG_ALERT, message)

def eccl(*arg):
    #Send commands to Enterprise Connect CLI
    command = [_ECCL]
    for x in arg:
        command.append(x)
    return subprocess.check_output(command).rstrip()

# Get User and domain info from Enterprise Connect
username = eccl('-p', 'adUsername').split(' ')[1]
ldap_url = eccl('-p', 'adDomain').split(' ')[1]

class attrdict(dict): 
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__

NetFS = attrdict()
# Can cheat and provide 'None' for the identifier, it'll just use frameworkPath instead
# scan_classes=False means only add the contents of this Framework
NetFS_bundle = objc.initFrameworkWrapper('NetFS', frameworkIdentifier=None, frameworkPath=objc.pathForFramework('NetFS.framework'), globals=NetFS, scan_classes=False)

# https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
# Fix NetFSMountURLSync signature
del NetFS['NetFSMountURLSync']
objc.loadBundleFunctions(NetFS_bundle, NetFS, [('NetFSMountURLSync', 'i@@@@@@o^@')])

def mount_share(share_path):
    # Mounts a share at /Volumes, returns the mount point or raises an error
    sh_url = CoreFoundation.CFURLCreateWithString(None, share_path, None)
    
    if StrictVersion(platform.mac_ver()[0]) < StrictVersion('10.13'):
        # Set UI to reduced interaction
        open_options  = {NetFS.kNAUIOptionKey: NetFS.kNAUIOptionNoUI}
        # Allow mounting sub-directories of root shares
        mount_options = {NetFS.kNetFSAllowSubMountsKey: True}
    else:
        ## Support for change in High Sierra
        open_options  = None
        mount_options = None
    # Mount!
    result, output = NetFS.NetFSMountURLSync(sh_url, None, None, None, open_options, mount_options, None)

    # Check if it worked
    if result != 0:
        if result == 17:
            log('File share already exists')
        else:
            log('Error mounting url "%s": "%s" with error code "%s"' % (share_path, output, result))
        return None
    # Return the mountpath
    return str(output[0])
    
###

log('Finding groups for ' + username + ' on domain ' + ldap_url)

# find what groups they are a part of
memberOf = eccl('-a', 'memberOf').splitlines()

groups = []
for item in memberOf:
    groups.append((item.split(',')[0])[13:])

for group, path in ad_groups.iteritems():
    # groups is a list of just the names i.e. groups = ['GROUP1', '', 'GROUP2', 'GROUP3']
    if group in groups:
        log('Group Found: ' + group + ' ==> ' + con_type + path)
        log(mount_share(con_type + path))

log('Script Complete')
sys.exit(0)