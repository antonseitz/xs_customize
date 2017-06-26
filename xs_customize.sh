#!/bin/bash


# isntall mc and xinted 

yum --enablerepo=base -y install mc xinetd lokkit


CONT="Press any key to continue OR CTRL-C to cancel..."

read -rsp "$CONT" -n1

# load modules for ipmi

modprobe ipmi_si
modprobe ipmi_devintf

# activate ipmi-modules permanently on host boot

chmod +x /etc/sysconfig/modules/ipmi_si.modules
chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules

read -rsp "$CONT" -n1

# test ipmi sensors

ipmitool sensor


read -rsp "$CONT" -n1
# install check_mk


scp root@192.168.1.207:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
scp root@192.168.1.207:/omd/versions/default/share/check_mk/agents/xinetd.conf /etc/xinetd.d/check_mk

read -rsp "$CONT" -n1

# start xinetd 

systemctl enable xinetd.service
systemctl start xinetd.service

read -rsp "$CONT" -n1


# make firewall exceptions
lokkit -p 6556:tcp
read -rsp "$CONT" -n1


# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "UUID=9750ef5c-807d-406c-bc20-9f7012b24ea1 /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

mount /snapshots

read -rsp "$CONT" -n1




