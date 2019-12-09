#!/bin/bash


echo "Installing mc and xinted per yum\n"

yum --enablerepo=base -y install mc xinetd git

echo
echo Testing, if IPMI isavailible:
dmidecode --type 38 | grep -A 30 IPMI || echo NO IPMI detected !

echo
echo
read -rsp $'Has this Host IPMI [y/n] ?\n' -n1 IPMI

if [ $IPMI == "y" ]; then

# load modules for ipmi
modprobe ipmi_si
modprobe ipmi_devintf

# activate ipmi-modules permanently on host boot


echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules
chmod +x /etc/sysconfig/modules/ipmi_si.modules
chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

# test ipmi sensors

ipmitool sensor
echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

fi

read -rsp $'Is the OMD Host reachable per ssh ? [y/n] ?\n' -n1 OMDIP


if [ $OMDIP == "y" ]; then

# install check_mk
echo
read -rsp $'Enter IP of Check_mk host : ' IP
scp root@$IP:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
scp root@$IP:/omd/versions/default/share/check_mk/agents/xinetd.conf /etc/xinetd.d/check_mk
echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

else

echo. 
echo Host IPs:
ifconfig 
echo
echo "So, you should use NOW script push_check_mk_agent on OMD HOst to push on this machine!"
echo
fi

# start xinetd 

systemctl enable xinetd.service
systemctl restart xinetd.service

netstat -lnp | grep 6556

echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
telnet localhost 6556
echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1


# make firewall exceptions
echo "Add into /etc/sysconfig/iptables : \n"
echo " -A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 6556 -j ACCEPT "
echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

nano /etc/sysconfig/iptables


# start xinetd 

systemctl enable xinetd.service
systemctl restart xinetd.service


service iptables restart
service iptables reload 
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

telnet localhost 6556
echo
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

ifconfig 
read -rsp $'Enter IP of this host : ' IP

telnet $IP 6556

echo 
echo



./check_mk_get_linux_version_install




read -rsp $'Should we make mount point for /snapshots  [y /n ]\n' -n1 SNAP

if [ $SNAP == "y" ]; then

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
read -rsp $'Copy UUID from above for Pasting in /etc/fstab ...\n' -n1
# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "## ENTRY for /snapshots -Partition"  >> /etc/fstab
echo "UUID=COPY-HERE_UUID /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

nano /etc/fstab

mount /snapshots

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

fi



