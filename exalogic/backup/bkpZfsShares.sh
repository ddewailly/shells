#!/bin/bash
#################################################
# Script to backup zfs storage node
# Oracle / DDY : 2014/09/15 : Creation
# Not supported in production
#################################################
# Variables
bkpFile=/tmp/backup.lst
ipStorage=172.17.0.5
mountType=nfs4
userStorage=nbackup
mountOpts="rw,bg,hard,nointr,rsize=131072,wsize=131072,proto=tcp,addr=${ipStorage}"
STDOUTFILE=/tmp/bkpdir.lst
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
# List project and mount point in a file
CURRENTSTEP="Cleanup Temporary files"
if [ -f ${bkpFile} ]; then
  rm -f ${bkpFile}
  check_return_code
fi
if [ -f ${STDOUTFILE} ]; then
  rm -f ${STDOUTFILE}
  check_return_code
fi
# Add /export/backup in backup list
echo "/backup" > ${STDOUTFILE}
#
CURRENTSTEP="List Project, shares and mount point on storage servers"
ssh ${userStorage}@${ipStorage} < /export/scripts/storage/listzfs.aksh > ${bkpFile}
check_return_code
# Parse file to mount directories
for currentShare in $(cat ${bkpFile}|grep export|egrep -v "NODE_|Exadata|ACSService|tmp_forms|wllogs|jmsta|backup|\/export\/common\/|logs|\/export\/Exalogic"| gawk '{print $2}')
do
  # Create mount point
  CURRENTSTEP="Create mount Point ${currentShare}"
  if [ ! -d ${currentShare} ]; then
    mkdir -p ${currentShare}
    check_return_code
  fi
  
  # Check if not already mounted
  CURRENTSTEP="Mount Directory ${currentShare}"
  if [ $(mount| grep "${ipStorage}\:${currentShare}"|wc -l) -eq 0 ];then
    # Mount directory
    sudo -u root mount -t ${mountType} -o ${mountOpts} ${ipStorage}:${currentShare} ${currentShare}
    check_return_code
  else
    echo "Directory ${currentShare} already mounted; Nothing to do"
  fi  
  echo "${currentShare}" >> ${STDOUTFILE}

  # Mount directory
  check_return_code
  
  # Make a backup of remote directory mounted
  CURRENTSTEP="Backup directory ${currentShare}"
  echo "backup ${currentShare}"
  check_return_code
  
  # umount directory
  #CURRENTSTEP="Umount directory ${currentShare}"
  #sudo -u root umount -f ${currentShare}
  #check_return_code
done
