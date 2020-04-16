Prerequisite for MegaCli installation

==========================
The MegaRAID ®  MegaCli application depends on few standard libraries. 
Please ensure that these libraries are present in the system before installing MegaCli rpm. 
MegaCli will not function without these libraries.

For your convenience, above libraries are available in the rpm <Lib_Utils-1.xx-xx.noarch.rpm>.
<Lib_Utils-1.xx-xx.noarch.rpm> is packaged in the MegaCli zip file.
To install the <Lib_Utils-1.xx-xx.noarch.rpm>, please follow below steps.

1) unzip the MegaCli package .
2) To install the Lib_Utils RPM, run the command "rpm -ivh <Lib_Utils-1.xx-xx.noarch.rpm>"
3) To install the MegaCli RPM, run the comand "rpm -ivh <MegaCli-x.xx-x.noarch.rpm>"
4) To upgrade the MegaCli RPM, run the comand "rpm -Uvh <MegaCli-x.xx-x.noarch.rpm>"

Installation of MegaCLI on Ubuntu (conversion of RPM to debian package)
========================================================================
1) alien -k MegaCli-x.xx-x.noarch.rpm
   This command generates debian package <megacli_x.xx.xx-x_all.deb>

2) dpkg -i megacli_x.xx.xx-x_all.deb
   This command installs MegaCLI Debian package at /opt/MegaRAID/MegaCli directory.


Notes:
1. If older version of the libutil or libutil2 rpm (i.e. <Lib_Utils-1.xx-xx.noarch.rpm>) is installed on the system, 
    please uninstall the older version of the RPM using the command "rpm -e <Lib_Utils-1.xx-xx>"
    and then install the latest libutil rpm <Lib_Utils-1.xx-xx.noarch.rpm> packaged in this zip file.

2. If older version of the libutil rpm <Lib_Utils-1.xx-xx.noarch.rpm> is installed on the system, 
    To perform upgrade from previous version to latest version run the command 
    "rpm -Uvh --nopostun <Lib_Utils-1.xx-xx.rpm> ". 
Example: 
   If "Lib_Utils-1.00-06.noarch.rpm" is installed on the target system to to perform upgrade to latest RPM
   "Lib_Utils-1.00-07.noarch.rpm" run the command  "rpm -Uvh --nopostun Lib_Utils-1.00-07.noarch.rpm".

3. On RHEL-3 (X64) and SLES-9 (X64), MegaCli requires libstdc++.so.6. It is assumed that these standard libraries are present in the system.

4. This build supports NytroXd feature. The SLIR2 library that is required for NytroXd feature is also included in the packaged

5. LSI NytroXd package is required for executing XD commands

6. Run MegaCli with Administrator Privileges.
