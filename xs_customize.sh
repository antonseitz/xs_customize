#!/bin/bash

#ROT
echo -e "\e[31mInstalling mc and xinted per yum\e[0m"
# ROT AN     echo -e "\e[31m
# ROT AUS    \e[0m"
#ROT AUS      echo -e "\e[0m"
yum --enablerepo=base -y install mc xinetd git

echo -e "\e[31mTesting, if IPMI isavailible:\e[0m"
dmidecode --type 38 | grep -A 30 IPMI || echo NO IPMI detected !

echo -e "\e[31m"
read -rsp $'Has this Host IPMI [y/n] ?\n' -n1 IPMI
 echo -e "\e[0m"
if [ $IPMI == "y" ]; then

# load modules for ipmi
modprobe ipmi_si
modprobe ipmi_devintf

# activate ipmi-modules permanently on host boot



echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules
chmod +x /etc/sysconfig/modules/ipmi_si.modules
chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
# test ipmi sensors

ipmitool sensor
echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
fi

read -rsp $'Is the OMD Host reachable per ssh ? [y/n] ?\n' -n1 OMDIP


if [ $OMDIP == "y" ]; then

# install check_mk
echo -e "\e[31m"
read -rsp $'Enter IP of Check_mk host : ' IP
echo -e "\e[0m"
scp root@$IP:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
scp root@$IP:/omd/versions/default/share/check_mk/agents/cfg_examples/xinetd.conf /etc/xinetd.d/check_mk
echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
else

echo. 
echo Host IPs:
ifconfig 
echo -e "\e[31m"
echo "So, you should use NOW script push_check_mk_agent on OMD HOst to push on this machine!"
echo -e "\e[0m"
fi

# start xinetd 

systemctl enable xinetd.service
systemctl restart xinetd.service

netstat -lnp | grep 6556

echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
telnet localhost 6556
echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"

# make firewall exceptions
echo "Add into /etc/sysconfig/iptables : \n"
echo -e "\e[0m"
echo " -A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 6556 -j ACCEPT "
echo
echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
nano /etc/sysconfig/iptables


# start xinetd 

systemctl enable xinetd.service
systemctl restart xinetd.service


service iptables restart
service iptables reload 
echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
telnet localhost 6556
echo
echo -e "\e[31m"
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
ifconfig 
echo -e "\e[31m"
read -rsp $'Enter IP of this host : ' IP
echo -e "\e[0m"
telnet $IP 6556

echo 
echo



./check_mk_get_linux_version_install



echo -e "\e[31m"
read -rsp $'Should we make mount point for /snapshots  [y /n ]\n' -n1 SNAP
echo -e "\e[0m"
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
echo -e "\e[31m"
read -rsp $'Copy UUID from above for Pasting in /etc/fstab ...\n' -n1
echo -e "\e[0m"
# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "## ENTRY for /snapshots -Partition"  >> /etc/fstab
echo "UUID=COPY-HERE_UUID /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

nano /etc/fstab

mount /snapshots

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1
echo -e "\e[0m"
fi



