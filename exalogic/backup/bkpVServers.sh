#!/bin/bash
#################################################
# Script to backup Exalogic vServers
# Oracle / DDY : 2014/09/15 : Creation
# Not supported in production
#################################################
# Variables
bkpFile=/tmp/backup.lst
ipStorage=172.17.0.5
mountType=nfs4
mountOpts="rw,bg,hard,nointr,rsize=131072,wsize=131072,proto=tcp,addr=${ipStorage}"
# Functions
check_return_code()
{
	local RETURN_CODE=${1:-0}

	if [ $RETURN_CODE -ne 0 ]; then 
		echo "  + STEP - ${CURRENTSTEP} KO" 
	else
		echo "  + STEP - ${CURRENTSTEP} OK" 
	fi

	return $RETURN_CODE
}

##### MAIN ######
# Check if not already mounted
CURRENTSTEP="Mount backup directory"
if [ $(mount| grep "${ipStorage}\:\/export\/backup"|wc -l) -eq 0 ];then 
  # Mount directory
  mount -t ${mountType} -o ${mountOpts} ${ipStorage}:/export/backup /backup
  check_return_code
#else
# Directory already mounted; Nothing to do
fi 

#Create mount point if not exist
CURRENTSTEP="Create mountPoint"
if [ ! -d /backup ]; then
  mkdir -p /backup
  check_return_code
fi

# Make a backup of remote directory mounted
CURRENTSTEP="Backup directory"
 
check_return_code

# umount directory
#CURRENTSTEP="Umount directory backup"
#umount -f /backup
#check_return_code

