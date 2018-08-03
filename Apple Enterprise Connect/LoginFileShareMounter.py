#!/usr/bin/python
#serial_number=2017102501
#serial above is yyyymmdd## for when the script is updated

import subprocess
import sys
import platform
import syslog
import os.path
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

##### Enterprise-Connect Plist File Name
plistFileName = 'com.apple.Enterprise-Connect.plist'
#############################################

syslog.openlog(log_name)

def log(message):
    #Log Progress and Errors to Syslog
    if message is not None:
        syslog.syslog(syslog.LOG_ALERT, message)

#get version of macOS
mac_version = platform.mac_ver()[0]

# Get User and domain info from Enterprise Connect
username = sys.argv[1]
ldap_url = 'ldap://' + sys.argv[2]

# Check if username is UserPrincipleName or shortname
if '@' in username:
    userkey = 'userPrincipalName'
else:
    userkey = 'sAMAccountName'

plistFile = str(os.path.expanduser('~') + '/Library/Preferences/' + plistFileName)
base_dn = str(subprocess.check_output(['defaults','read',plistFile,'defaultNamingContext'])).rstrip()

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
groupMembership = subprocess.check_output(['ldapsearch', '-LLL', '-Q', '-H', ldap_url, '-b', base_dn, '(&(objectCategory=Person)(objectClass=User)({0}={1}))'.format(userkey, username), 'memberOf', '2>/dev/null'])

# clean up the output of the ldapsearch to end up with a list of group names
memberOf = groupMembership.splitlines()
grouplist = [x for x in memberOf if x.startswith('memberOf')]
#print grouplist

# groupList is our list of groups with their full DN -> memberOf: CN=GROUP1,OU=Distribution Lists,OU=Exchange,OU=US,DC=MY,DC=DOMAIN'
# need to clean up the names
groups = []
for name in grouplist:
	groups.append((name.split(',')[0])[13:])

for group, path in ad_groups.iteritems():
    # groups is a list of just the names i.e. groups = ['GROUP1', '', 'GROUP2', 'GROUP3']
    if group in groups:
        log('Group Found: ' + group + ' ==> ' + con_type + path)
        log(mount_share(con_type + path))

log('Script Complete')
sys.exit(0)