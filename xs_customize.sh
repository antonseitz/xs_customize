#!/bin/bash
function banner { echo -e "\n#########################################################\n"; }
function red { echo -e "\e[31m"; }
function nor { echo -e "\e[0m"; }
function continue { read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1 ; }



red 
banner
echo "YUM: Installing mc and xinted "
banner
nor

yum --enablerepo=base -y install mc xinetd git








red
banner
echo "TEST: is IPMI availible ?"
banner
nor

dmidecode --type 38 | grep -A 30 IPMI || echo NO IPMI detected !

red
banner
read -rsp $'Check output above. \n Has this Host IPMI [y/n] ?\n' -n1 IPMI
banner
nor

if [ $IPMI == "y" ]; then
	
	echo "Loading IPMI Modules.."
	# load modules for ipmi
	modprobe ipmi_si
	modprobe ipmi_devintf

	# activate ipmi-modules permanently on host boot

	echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
	echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules
	chmod +x /etc/sysconfig/modules/ipmi_si.modules
	chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

	echo "... done!"
	red
	banner 
	continue
	banner 
	nor
	
	
	# test ipmi sensors

	ipmitool sensor
	red
	echo "Check output above. Any sensors visible ?"
	continue
	nor
else
	echo "NO IPMI install"
fi



red
banner
echo "INSTALL AGENT: "
read -rsp $'Is the OMD Host reachable per ssh ? [y/n] ?\n' -n1 OMDIP
banner
nor


if [ $OMDIP == "y" ]; then

	echo "CHECK_MK: installing per scp"
	red
	read -rsp $'Enter IP of Check_mk host : ' IP
	nor
	echo "..copying.."
	scp root@$IP:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
	scp root@$IP:/omd/versions/default/share/check_mk/agents/cfg_examples/xinetd.conf /etc/xinetd.d/check_mk
	red
	continue
	nor


else

	echo "CHECK_MK: installing per push"
	red 
	banner
	echo "STOP , you should use NOW the script push_check_mk_agent on OMD Host to push to this machine!"
	nor 
	banner
	echo IPs of this host:
	ifconfig | grep inet
	banner
	red
	continue
	
	nor
	
fi


red
banner
echo "XINETD: Starting ?"
continue
banner
nor
# start xinetd 

echo "XINETD: Starting ..."

systemctl enable xinetd.service
systemctl restart xinetd.service
echo "...done"

red 
banner
echo "NETSTAT: Is check_mk listening on Port 6556 (ipv4) ?"
banner
nor
netstat -lnp | grep 6556

red
banner
echo "TEST: is check_mk responding on localhost:6556 (ipv4)?"
continue

banner
echo "last 10 lines of output: "
nor
telnet localhost 6556 | tail


red
banner
echo "FIREWALL: Open now Port 6556 for check_mk:"
nor

# make firewall exceptions
echo "Add into /etc/sysconfig/iptables : \n"
nor
echo " -A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 6556 -j ACCEPT "
echo
echo " Use this line above for COPY PASTE"
red
continue
nor

nano /etc/sysconfig/iptables

echo "XINETD: Now starting..."

systemctl enable xinetd.service
systemctl restart xinetd.service

echo "XINETD: started!"
banner
echo "IPTABLES: restarting"

service iptables restart
service iptables reload 

echo "IPTABLES: done"
red
continue
nor


ifconfig | grep inet
red

echo "TEST: is check_mk responding on localhost:6556 (ipv4)?"
echo "See IP above!"
read -rsp $'Enter IP of this host : ' IP

nor

echo "TELNET  $IP 6556"
echo "last 10 lines of output: "



telnet $IP 6556 | tail 

echo 



red
read -rsp $'Should we make mount point for /snapshots  [y /n ]\n' -n1 SNAP
nor
if [ "$SNAP" == "y" ]; then

echo " /dev/disk/by-path/ : "
echo
 ls -la /dev/disk/by-path/

echo " /dev/disk/by-uuid :"
echo
ls -la /dev/disk/by-uuid

echo 
echo " blkid  :"
blkid

echo 
echo " by-id  :"
ls -la /dev/disk/by-id


echo


echo
echo
red
read -rsp $'Copy UUID from above for Pasting in /etc/fstab ...\n' -n1
nor
# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "## ENTRY for /snapshots -Partition"  >> /etc/fstab
echo "UUID=COPY-HERE_UUID /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

nano /etc/fstab

mount /snapshots

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
nor
fi


# TODO INstall MegaCli, StorCli


red
read -rsp $'Should we install RAID-Tools ?  [y /n ]\n' -n1 RAID
nor
if [ $RAID == "y" ]; then

#if [ $('hostname') == "icoms" ]; then

echo "HOSTNAME: $HOSTNAME"
fi

installcmd="raidtools/$HOSTNAME/installcmd"

if [ -f "$installcmd" ]; then

echo "JA"

$installcmd  $('pwd')"/raidtools/"$HOSTNAME
else
echo "ERROR: install not found"

#fi

#fi
fi

