#!/bin/python


import os, shutil, stat
from os.path import join, getsize
for path, dirs, files in os.walk('check_plugins'):
	for file in files:
		# print "Install " + file + " ? "
		# print "y / n "		
		install=raw_input("Install " + file + " ? [ ENTER / n ]")
		
		if install == "" :
			print "installing "  + file + " ...\n"
			if os.path.isdir("/usr/lib/check_mk_agent/local/") is False :
				print "no dir .. creating"
				os.makedirs ("/usr/lib/check_mk_agent/local/")
			shutil.copy( os.path.join (path , file) , "/usr/lib/check_mk_agent/local/" ) 
			
			
			os.chmod ( os.path.join("/usr/lib/check_mk_agent/local/" , file ) , 0o700)
		else:
			print "skipping"
	
	
	
	
	