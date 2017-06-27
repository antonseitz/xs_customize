#!/bin/bash


# isntall mc and xinted 

yum --enablerepo=base -y install mc xinetd lokkit


read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1


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

# install check_mk


scp root@192.168.1.207:/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent
scp root@192.168.1.207:/omd/versions/default/share/check_mk/agents/xinetd.conf /etc/xinetd.d/check_mk

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1


# start xinetd 

ls
systemctl start xinetd.service
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1



# make firewall exceptions
#lokkit -p 6556:tcp  --update
EDIT /etc/sysconfig/iptables

service iptables restart
read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1



# mkdir Backup mount
mkdir /snapshots

#UUID findet man unter /dev/disk/by-uuid 
echo "UUID=9750ef5c-807d-406c-bc20-9f7012b24ea1 /snapshots ext4 defaults,noauto 0 2" >> /etc/fstab

mount /snapshots

read -rsp $'Press key to continue OR CTRL-C to cancel...\n' -n1





