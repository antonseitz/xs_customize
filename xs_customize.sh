#!/bin/bash


# isntall mc and xinted 

yum --enablerepo=base -y install mc xinetd 


read -rsp $'Has this Host IPMI ?\n' -n1 IPMI


if["$IPMI"=="y"];then 


# load modules for ipmi

modprobe ipmi_si
modprobe ipmi_devintf

# activate ipmi-modules permanently on host boot

chmod +x /etc/sysconfig/modules/ipmi_si.modules
chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1


# test ipmi sensors

ipmitool sensor


read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

fi


# install check_mk

read -rsp $'Enter IP of Check_mk host : ' IP
scp root@$IP:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
scp root@$IP:/omd/versions/default/share/check_mk/agents/xinetd.conf /etc/xinetd.d/check_mk

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1


# start xinetd 

systemctl enable xinetd.service
systemctl start xinetd.service

netstat -lnp | grep 6556

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

# make firewall exceptions
echo "Add into /etc/sysconfig/iptables : \n"
echo " -A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 6556 -j ACCEPT "

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

nano /etc/sysconfig/iptables

service iptables restart
service iptables reload 
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

telnet localhost 6556
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1

ifconfig 
read -rsp $'Enter IP of this host : ' IP

telnet $IP 6556

read -rsp $'Should we make mount point for /snapshots or   to cancel ? (CTRL-C)...\n' -n1


# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "UUID=9750ef5c-807d-406c-bc20-9f7012b24ea1 /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

mount /snapshots

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1





