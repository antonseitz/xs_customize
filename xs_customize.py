#!/bin/python

import subprocess , os, stat, socket


execfile( "py_helper/helper.py")

root=os.getcwd()

banner("YUM")

yum = ask("Install mc, xinetd and git ? ")

if yum =="":
		
	os.system("/usr/bin/yum --enablerepo=base -y install mc xinetd git")
		



banner("TEST: is IPMI availible ?")

ipmi=ask("Install IPMI ? ")
if ipmi=="":


	subprocess.call("dmidecode --type 38 | grep -A 30 IPMI || echo NO IPMI detected !", shell=True)

	ipmi=ask("Check output above  ^^^  Has this Host IPMI ? ")

	if ipmi=="":
			
		print ( "Loading IPMI Modules..")
		
		subprocess.call("modprobe ipmi_si", shell=True)
		subprocess.call("modprobe ipmi_devintf", shell=True)

		
		subprocess.call("ipmitool sensor", shell=True)
		
		
		if  ask("Check output above. Any sensors visible ?") != "":
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
		
		
	

	
banner("INSTALL Check_mk AGENT")

check_mk=ask("Should we install check_mk agent ?")
if check_mk=="" :
	
	
	ssh=ask("Is the OMD Host reachable per ssh ? ")
	
	

	if ssh== "" :

		banner( "CHECK_MK: installing per scp" )
	
		ip=ask_text("Enter IP of Check_mk host [my default 192.168.1.12 ] : ")
		if ip!="":
			os.system("scp root@" + ip + ":/omd/versions/default/share/check_mk/agents/check_mk_agent.linux /usr/bin/check_mk_agent")
			os.system("scp root@" + ip + ":/omd/versions/default/share/check_mk/agents/cfg_examples/xinetd.conf /etc/xinetd.d/check_mk")
		else:
			print("NO IP GIVEN")
	else:
		banner ("CHECK_MK: installing per push")
	
	
		print ("IPs of this host: ")
		os.system("ifconfig | grep inet")
		done= ask ("STOP : You should use NOW the script push_check_mk_agent on OMD Host to push to this machine!")
	
		if done!="":
			print("Aborted!")
			exit()
	
	


	banner("Starting XINETD")
	xinetd=ask("Should we start XINETD for check_mk ?")
	if xinetd=="":
		os.system("systemctl enable xinetd.service")
		os.system("systemctl restart xinetd.service")
		print "XINETD started!"




	banner( "CHECK: is xinetd listening on port 6556 (ipv4) ?")


	port=os.system("netstat -lnp | grep 6556")
	if port>0:
		print("Nothing listeing on 6556")
		print("Aborting!")
		exit()
	else: 
		print("Success: check_mk is listening on 6556")
		
		
		
		
		
	banner("CHECK is check_mk responding on LOCALHOST:6556 (ipv4)?")




	print ( "last 20 lines of output: ")

	os.system("telnet localhost 6556 | tail -n 20 ")


	if ask("Output OK ?")!="":
		print("Aborting!")
		exit()





	banner( "FIREWALL: Open now port 6556 for check_mk" )


	

	iptables_new=open("/etc/sysconfig/iptables_new", "w")
	iptables=open("/etc/sysconfig/iptables", "r")
	for x in iptables:
		iptables_new.write(x)
		if "dport 80" in x:
			iptables_new.write("-A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 6556 -j ACCEPT \n")
	iptables.close()
	iptables_new.close()

	print("..iptables modified!")

	banner( "XINETD and IPTABLES: Now restarting...")

	os.system("systemctl enable xinetd.service")
	os.system("systemctl restart xinetd.service")


	os.system("systemctl restart iptables ")
	os.system("systemctl reload iptables  ")

	print("..done!")


	os.system("ifconfig | grep -B 1 inet")
		
	ip=ask_text("Gimme local IP address: ")
	banner("CHECK is check_mk responding on " + ip + ":6556 (ipv4)?")

	print ( "last 20 lines of output: ")

	os.system("telnet " + ip + " 6556 | tail -n 20 ")


	if ask("Output OK ?")!="":
		print("Aborting!")
		exit()
	
plugins=ask("Install my check_mk plugins ?")
if plugins=="":
	banner(" INSTALL MY CHECK_MK PLUGINS ")
	execfile( root  + "/check_mk_install_my_plugins.py")
	


banner("Install MegaCli, StorCli, tw_cli")







raid=ask("Should we install RAID-Tools ")


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


