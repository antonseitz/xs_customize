#!/bin/python

import subprocess , os, stat, socket, platform,sys


#execfile( "./py_helper/helper.py")
#sys.path.insert(0, './py_helper/')

sys.path.append("./py_helper")
import helper
root=os.getcwd()

helper.banner("YUM or APT")

yum = helper.ask("Install mc, xinetd and git ? ")
distro=platform.dist()[0]
if yum =="":
	if distro=="Ubuntu":
		os.system("/usr/bin/apt install mc xinetd git ipmitool iotop")
	else:
		os.system("/usr/bin/yum --enablerepo=base -y install mc xinetd git iotop ")
		



helper.banner("TEST: is IPMI availible ?")

ipmi=helper.ask("Install IPMI ? ")
if ipmi=="":


	subprocess.call("dmidecode --type 38 | grep -A 30 IPMI || echo NO IPMI detected !", shell=True)

	ipmi=helper.ask("Check output above  ^^^  Has this Host IPMI ? ")

	if ipmi=="":
			
		print ( "Loading IPMI Modules..")
		
		subprocess.call("modprobe ipmi_si", shell=True)
		subprocess.call("modprobe ipmi_devintf", shell=True)

		
		subprocess.call("ipmitool sensor", shell=True)
		
		
		if  helper.ask("Check output above. Any sensors visible ?") != "":
			print("Aborted!")
			exit()
			
		
		print( "activating ipmi-modules permanently on host boot")
		modules=open("/etc/sysconfig/modules/ipmi_si.modules","w")
		modules.write("modprobe ipmi_si")
		modules.close()
		
		
		modules=open("/etc/sysconfig/modules/ipmi_devintf.modules","w")
		modules.write("modprobe ipmi_devintf")
		modules.close()
		
		os.chmod( "/etc/sysconfig/modules/ipmi_si.modules", stat.S_IEXEC )
		os.chmod( "/etc/sysconfig/modules/ipmi_devintf.modules", stat.S_IEXEC )

		print( "... done!")
		
		
	

	
helper.banner("get Check_mk AGENT running")

check_mk=helper.ask("Should we config iptables for check_mk agent ?")
if check_mk=="" :
	
	
#	ssh=helper.ask("Is the OMD Host reachable per ssh ? ")
	
	

#	if ssh== "" :

#		helper.banner( "CHECK_MK: installing per scp" )
	
#		ip=helper.ask_text("Enter IP of Check_mk host [my default chk.puckit.de ] : ")
#		port=helper.ask_text("Enter  ssh port of Check_mk host [default 22 ] : ")
#		if ip!="":
#			os.system("scp -P " + port +  " root@" + ip + ":/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent")
#			os.system("scp -P " + port +  " root@" + ip + ":/omd/versions/default/share/check_mk/agents/cfg_examples/xinetd.conf /etc/xinetd.d/check_mk")
#		else:
#			print("NO IP GIVEN")
#	else:
#		helper.banner ("CHECK_MK: installing per push")
	
	
#		print ("IPs of this host: ")
#		os.system("ifconfig | grep inet")
#		done= helper.ask ("STOP : You should use NOW the script push_check_mk_agent on OMD Host to push to this machine!")
	
#		if done!="":
#			print("Aborted!")
#			exit()
	
	


	helper.banner("Starting XINETD")
	xinetd=helper.ask("Should we start XINETD for check_mk ?")
	if xinetd=="":
		os.system("systemctl enable xinetd.service")
		os.system("systemctl restart xinetd.service")
		print "XINETD started!"




	helper.banner( "CHECK: is xinetd listening on port 6556 (ipv4) ?")


	port=os.system("netstat -lnp | grep 6556")
	if port>0:
		print("Nothing listeing on 6556")
		print("Aborting!")
		exit()
	else: 
		print("Success: check_mk is listening on 6556")
		
		
		
		
		
	helper.banner("CHECK is check_mk responding on LOCALHOST:6556 (ipv4)?")




	print ( "last 20 lines of output: ")

	os.system("telnet localhost 6556 | tail -n 20 ")


	if helper.ask("Output OK ?")!="":
		print("Aborting!")
		exit()





	helper.banner( "FIREWALL: Open now port 6556 for check_mk" )


	

	iptables_new=open("/etc/sysconfig/iptables_new", "w")
	iptables=open("/etc/sysconfig/iptables", "r")
	for x in iptables:
		iptables_new.write(x)
		if "dport 443" in x:
			iptables_new.write("-A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 6556 -j ACCEPT \n")
	iptables.close()
	iptables_new.close()
	if(os.path.exists("/etc/sysconfig/iptables_old")):
		os.remove("/etc/sysconfig/iptables_old")
	os.rename("/etc/sysconfig/iptables", "/etc/sysconfig/iptables_old")
	os.rename("/etc/sysconfig/iptables_new", "/etc/sysconfig/iptables")
	print("..iptables modified!")

	helper.banner( "XINETD and IPTABLES: Now restarting...")

	os.system("systemctl enable xinetd.service")
	os.system("systemctl restart xinetd.service")


	os.system("systemctl restart iptables ")
	os.system("systemctl reload iptables  ")

	print("..done!")


	os.system("ifconfig | grep -B 1 inet")
		
	ip=helper.ask_text("Gimme local IP address: ")
	helper.banner("CHECK is check_mk responding on " + ip + ":6556 (ipv4)?")

	print ( "last 20 lines of output: ")

	os.system("telnet " + ip + " 6556 | tail -n 20 ")


	if helper.ask("Output OK ?")!="":
		print("Aborting!")
		exit()
	
plugins=helper.ask("Install my check_mk plugins ?")
if plugins=="":
	helper.banner(" INSTALL MY CHECK_MK PLUGINS ")
	execfile( root  + "/check_mk_install_my_plugins.py")
	


helper.banner("Install MegaCli, StorCli, tw_cli")







raid=helper.ask("Should we install RAID-Tools ")


if raid=="" :

	hostname=socket.gethostname()
	installs=root + "/raidtools/" + hostname
	if not os.path.exists(installs):
		print("Path " + installs + " not existing! \n Aborting!")
		exit(1)

	tools=open(installs , "r")
	for tool in tools:
		print("Installing " + tool +" ... \n")
		
		os.system( root + "/raidtools/" + tool.strip("\n") + "/installcmd "  + root + "/raidtools/" + tool )
		
		print("Done: Installing " + tool +" \n")


helper.banner("NFS Mount")

nfs=helper.ask("Make NFS Mount ? ")
if nfs=="":
    if os.path.isdir("/backup") is False :
        print "no dir .. creating"
        os.makedirs ("/backup")
    fstab=open("/etc/fstab", "r")
    #fstab_new=open("/etc/fstab_new", "w")
    for line in fstab:
        print line
        if not line =="192.168.0.67:/backup /backup nfs rw 0 0":
            print  "NEIN"
        
    fstab.close
    #        fstab=open("/etc/fstab", "w")
    #        fstab.append("192.168.0.67:/backup /backup nfs rw 0 0")
    
