#!/bin/bash


# isntall mc and xinted 

yum --enablerepo=base -y install mc xinetd


# load modules for ipmi

modprobe ipmi_si
modprobe ipmi_devintf

# activate ipmi-modules permanently on host boot

chmod +x /etc/sysconfig/modules/ipmi_si.modules
chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules



# test ipmi sensors

ipmitool sensor

# install check_mk


scp root@192.168.1.207:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
scp root@192.168.1.207:/omd/versions/default/share/check_mk/agents/xinetd.conf /etc/xinetd.d/check_mk

#mv check_mk_agent.linux /usr/bin/check_mk_agent
#mv xinetd.conf /etc/xinetd.d/check_mk  

# start xinetd 

systemctl enable xinetd.service
systemctl start xinetd.service


# make firewall exceptions


# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "UUID=9750ef5c-807d-406c-bc20-9f7012b24ea1 /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

mount /snapshots



