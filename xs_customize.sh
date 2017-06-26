#!/bin/bash


# activate Base Repo


# install mc

# activate ipmi-modules on boot

chmod +x /etc/sysconfig/modules/ipmi_si.modules
chmod +x /etc/sysconfig/modules/ipmi_devintf.modules

echo "modprobe ipmi_si" > /etc/sysconfig/modules/ipmi_si.modules
echo "modprobe ipmi_devintf" > /etc/sysconfig/modules/ipmi_devintf.modules

modprobe ipmi_si
modprobe ipmi_devintf

# install xinetd ?!

/etc/init.d/xinetd start

# test ipmi sensors

# make firewall exceptions

