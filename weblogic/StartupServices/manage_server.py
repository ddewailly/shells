#######################################################################################################
## Arval Service Lease
## Author:   W Jouanne
## Modified: January 07, 2013
## Description:
## This script attempts to connect to a given node manager, and to start a admin server.
##
## Usage: java weblogic.WLST stopstart_server.py mycommand myhost mynmport myuserconfigfile myuserkeyfile mydomainname mydomaindir mynmtype myserver
##						 1         2      3        4                5            6             7      8        9
##
## Ref. doc. :http://docs.oracle.com/cd/E14571_01/web.1111/e13813/reference.htm
##
## Error List : 0=OK ; 1=Node Manager problem ; 2= Other Error
##
#######################################################################################################

import sys
import time

host = sys.argv[1]
nmport = sys.argv[2]
userconfigfile = sys.argv[3]
userkeyfile = sys.argv[4]
domainname = sys.argv[5]
domaindir = sys.argv[6]
nmtype = sys.argv[7]
command = sys.argv[8]
servername = sys.argv[9]

usage="java weblogic.WLST manage_server.py mycommand myhost mynmport myuserconfigfile myuserkeyfile mydomainname mydomaindir mynmtype myserver"

if command == "start":
	try:
		nmConnect(userConfigFile=userconfigfile, userKeyFile=userkeyfile , host=host, port=nmport, domainName=domainname, domainDir=domaindir, mType=nmtype)
	except:
		sys.exit(1)
	try:
		nmStart(servername)
	except:
		sys.exit(2)
	try:
		nmDisconnect()
	except:
		sys.exit(1)
elif command == "stop":
	try:
		nmConnect(userConfigFile=userconfigfile, userKeyFile=userkeyfile , host=host, port=nmport, domainName=domainname, domainDir=domaindir, mType=nmtype)
	except:
		sys.exit(1)
	try: 
		nmKill(servername)
	except:
		sys.exit(2)
	try:
		nmDisconnect()
	except:
		sys.exit(1)
elif command == "status":
	try:
		nmConnect(userConfigFile=userconfigfile, userKeyFile=userkeyfile , host=host, port=nmport, domainName=domainname, domainDir=domaindir, mType=nmtype)
	except:
		sys.exit(1)
	serverStatus=nmServerStatus(servername)
	if serverStatus == "SHUTDOWN":
		sys.exit(10)
	elif serverStatus == "STARTING":
		sys.exit(11)
	elif serverStatus == "STANDBY":
		sys.exit(12)
	elif serverStatus == "ADMIN":
		sys.exit(13)
	elif serverStatus == "RESUMING":
		sys.exit(14)
	elif serverStatus == "RUNNING":
		sys.exit(15)
	elif serverStatus == "SUSPENDING":
		sys.exit(16)
	elif serverStatus == "FORCE_SUSPENDING":
		sys.exit(17)
	elif serverStatus == "SHUTTING_DOWN":
		sys.exit(18)
	elif serverStatus == "FAILED":
		sys.exit(19)
	else:
		sys.exit(20)
	try:
		nmDisconnect()
	except:
		sys.exit(1)
else:
	print(usage)
exit()
