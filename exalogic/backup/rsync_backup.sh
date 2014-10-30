#!/bin/bash
#
# Script that will create a backup copy of the filesystem using the simple
# rsync facility
#
# Author : Donald Forbes
# Date   : Nov 2012
# Modification : 20140804 : David Dewailly
#
#  ** Usage not supported, provided just as is. **
#
# *************************** Functions *************************
setup_default_values()
{
#
# ********************* Variables Initial values ****************
#
	BACKUP_MOUNT_POINT=/backup
	DIR=`hostname -s|tr -s [A-Z] [a-z]`
	BACKUP_DIR=${BACKUP_MOUNT_POINT}/${DIR}
	AUTOMOUNT=true
	ACTION="backup"
	#NFS_SERVER=storage.exa-internal.intra.corp
	NFS_SERVER=172.17.0.5
	NFS_SHARE_DIR=/export/backup
	SCRIPT=false
	DIRECTORY_TO_BACKUP=/
	BACKUP_EXCLUSION_LIST=/tmp/backup_exclusions.txt
}	
create_directory() {
        mkdir -p ${BACKUP_DIR}
}
tidyup()
{
	if [ "${AUTOMOUNT}" = "true" ]
	then
		umount ${BACKUP_MOUNT_POINT}
	fi
        rm -f ${BACKUP_EXCLUSION_LIST}
}
setup_command_line_variables()
{
#	Routing will accept as input all the command line parameters, parse them to setup the 
# 	variables used within the script.
	for PARAM in "$@"
	do
		L_VARIABLE=`echo ${PARAM} | cut -d "-" -d "=" -f 1 | sed -e 's/-//g' | tr '[A-Z]' '[a-z]'` 
		L_VALUE=`echo ${PARAM} | sed 's/^.*=//g' | tr '[A-Z]' '[a-z]'`
		
		case "${L_VARIABLE}" in
			"nfs_server") NFS_SERVER=${L_VALUE}
			;;
			"nfs_share_dir") NFS_SHARE_DIR=${L_VALUE}
			;;
			"automount") AUTOMOUNT=true
			;;
			"script") SCRIPT=true
			;;
			"mount_point") BACKUP_MOUNT_POINT=${L_VALUE}
			;;
			"backup_dir") DIR=${L_VALUE}
					BACKUP_DIR=${BACKUP_MOUNT_POINT}/${DIR}
			;;
			"action") ACTION=${L_VALUE}
			;;
			"directory_to_backup") DIRECTORY_TO_BACKUP=${L_VALUE}
			;;
			*) usage
			;;
		esac
	done	
} 
usage()
{
        echo "rsync_backup.sh -action=(backup|restore) : [${ACTION}]"
	echo "                    -nfs_server=<IP of NFS storage device> : [${NFS_SERVER}]"
	echo "                    -nfs_share_dir=<Directory of NFS share> : [${NFS_SHARE_DIR}]"
	echo "                    -mount_point=<Directory of mount point on local machine> : [${BACKUP_MOUNT_POINT}]"
	echo "                    -backup_dir=<root directory for backups under the mount point> : [${DIR}]"
	echo "                    -directory_to_backup=<Source directory for backing up.> : [${DIRECTORY_TO_BACKUP}]"
	echo "                    -automount"
	echo "                    -script"
	echo ""
	echo "If automount is not specified the system will assume that the mount point defined already exists"
	echo "-script is used to indicate that the script is run automatically and should not prompt the user"
	echo " for any input."
	echo ""
	tidyup
        exit 1
}
remove_white_space()
{
	RESP=`echo $RESP | tr -d " "`
}
validate()
{
        if [ "$1" = "" ]
        then
                ACTION=backup
                echo "No action defined, defaulting to backup files."
        else

                ACTION=`echo $1 | tr '[A-Z]' '[a-z]'`
                if [ "${ACTION}" = "backup" ] || [ "${ACTION}" = "restore" ]
                then
                        echo "Action that will be performed is [${ACTION}]"
                else
                        echo "Invalid Action specified [$1]"
                        usage
                fi
        fi
	AUTOMOUNT_TEST=`echo ${AUTOMOUNT} | tr '[A-Z]' '[a-z]'`
	if [[ "${AUTOMOUNT_TEST}" = "no" || "${AUTOMOUNT_TEST}" = "false" ]]
	then
		AUTOMOUNT=false
	else
		AUTOMOUNT=true
	fi

        echo "Auto mount backup share is [${AUTOMOUNT}]"
        echo "Mount point is [${BACKUP_MOUNT_POINT}] using NFS server [${NFS_SERVER}:${NFS_SHARE_DIR}]"
	echo "Backup Directory is [${BACKUP_DIR}]"
	if [ "${SCRIPT}" = "true" ]
	then
		echo "Running from a script, no user interaction"
	else
		read -p "Are the values above correct? (\"Y\" or \"N\") : " CONFIG_VALID
		CONFIG=`echo ${CONFIG_VALID} | tr '[A-Z]' '[a-z]'`
		if [ "${CONFIG}" = "y" ]
		then
			echo "${ACTION}....."
		else 
			read -p "Please specify an Action. (Backup|Restore) [${ACTION}] : " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				ACTION=${RESP}
			fi
			read -p "Please enter the mount point [${BACKUP_MOUNT_POINT}]: " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				BACKUP_MOUNT_POINT=${RESP}
			fi
			read -p "NFS Server address [${NFS_SERVER}] : " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				NFS_SERVER=${RESP}
			fi
			read -p "NFS Server share directory [${NFS_SHARE_DIR}] : " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				NFS_SHARE_DIR=${RESP}
			fi
			read -p "Is the mount point (on [${NFS_SERVER}) to be automatically mounted by script? [${AUTOMOUNT}] : " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				AUTOMOUNT=${RESP}
			fi
			read -p "Please enter the backup directory (Mount point pre-pended) [${DIR}]: " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				DIR=${RESP}
			fi
			read -p "Please enter the source directory to be backed up [${DIRECTORY_TO_BACKUP}]: " RESP
			remove_white_space
		        if [ "${RESP}" != "" ]
			then 
				DIRECTORY_TO_BACKUP=${RESP}
			fi
			BACKUP_DIR=${BACKUP_MOUNT_POINT}/${DIR}
			validate ${ACTION}
		fi
	fi	
}
mount_share()
{
	mkdir -p ${BACKUP_DIR}
	mount -t nfs -o fg,rw,nointr,rsize=131072,wsize=131072,tcp,vers=3 ${NFS_SERVER}:${NFS_SHARE_DIR} ${BACKUP_MOUNT_POINT}
}
umount_share()
{
	umount ${BACKUP_MOUNT_POINT}
}
create_exclusion_list()
{
# Create a list of directories that we will not backup.  It makes the assumption
# that the nfs mounts in fstab are being backed up by other means.  We also
# specify other directories to avoid here.  For example /tmp
mount | grep nfs | grep ":" | awk '{ print($3) }' > ${BACKUP_EXCLUSION_LIST}
echo /tmp >> ${BACKUP_EXCLUSION_LIST}
echo /proc >> ${BACKUP_EXCLUSION_LIST}
echo /sys >> ${BACKUP_EXCLUSION_LIST}
echo /dev >> ${BACKUP_EXCLUSION_LIST}
echo /var/lock >> ${BACKUP_EXCLUSION_LIST}
echo /var/run >> ${BACKUP_EXCLUSION_LIST}
echo /var/cache >> ${BACKUP_EXCLUSION_LIST}
echo /var/lib/nfs/rpc_pipefs/nfs >> ${BACKUP_EXCLUSION_LIST}
echo /var/lib/nfs/rpc_pipefs/cache >> ${BACKUP_EXCLUSION_LIST}
echo /etc/mttab >> ${BACKUP_EXCLUSION_LIST}
echo /export >> ${BACKUP_EXCLUSION_LIST}
echo /u01 >> ${BACKUP_EXCLUSION_LIST}
echo /backup >> ${BACKUP_EXCLUSION_LIST}
echo /wls >> ${BACKUP_EXCLUSION_LIST}
# Not copying the /mnt or /media directories as these are likely to be 
# USB drives or something similar.
echo /mnt >> ${BACKUP_EXCLUSION_LIST}
echo /media >> ${BACKUP_EXCLUSION_LIST}
#
}
# *************************** End Functions *************************
#
# *******************************************************************
# ********* Main program - Validate parameters and run sync. ********
# *******************************************************************
#
setup_default_values
setup_command_line_variables $@
validate ${ACTION}
if [ "${AUTOMOUNT}" = "true" ]
then
	mount_share
fi
create_directory
create_exclusion_list
# ******************************************************************
# Issue the command to perform a backup.
# ******************************************************************
START_TIME=`date`
if [ "${ACTION}" = "backup" ]
then
        rsync -avr --delete --delete-excluded --exclude-from=${BACKUP_EXCLUSION_LIST} ${DIRECTORY_TO_BACKUP} ${BACKUP_DIR}
else
        rsync -e ssh -av  --exclude-from=${BACKUP_EXCLUSION_LIST} ${BACKUP_DIR}/ ${DIRECTORY_TO_BACKUP}
fi
END_TIME=`date`
echo ""
echo "Start Time : ${START_TIME}
echo "End Time   : ${END_TIME}
tidyup
