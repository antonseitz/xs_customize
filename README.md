# xs_customize

 You can download and install this scripts per git fetch.

yum --enablerepo=base -y install git

git clone --recursive  https://github.com/antonseitz/xs_customize.git
 
cd xs_customize


 oder wget:  (Raw needs sometimes some minutes to offer the newest commit..=)

rm -f xs_customize.sh && wget --no-cache https://raw.githubusercontent.com/antonseitz/xs_customize/master/xs_customize.sh && chmod u+x xs_customize.sh
 

# xs_customize.py
This script 
- installs mc (Midnight COmmandar) on a XenServer Installation > 7.0
- installs check_mk agent and 
- ipmi -modules for monitoring the server hardware 


# push_check_mk_agent 

Pushes check_mk agent from OMD host zu client


# check_mk_local_plugin_get_linux_version

Gets Linux Distro and Verison via local check_mk plugin
Location:

/usr/lib/check_mk_agent/local/


## RAID Tools

for newer RAID-COntrollers MegaCli is installed, even if Storcli is available
Reason: check_mk detects Controller via MegaCli, not Storcli yet
