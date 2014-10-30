#!/bin/bash

VERSION="201403111430"
################################################################################
#
#       CreateTemplateFromVServerUniversal.sh
# 	Modified from 
#       Exalogic EL X2-2 2.0.0.4 (Linux x86-64) Configuration Script.
#
#  HEADER START
# 
#  THIS SCRIPT IS PROVIDED ON AN “AS IS” BASIS, WITHOUT WARRANTY OF ANY KIND, 
#  EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, WARRANTIES THAT 
#  THE COVERED SCRIPT IS FREE OF DEFECTS, MERCHANTABLE, FIT FOR A PARTICULAR 
#  PURPOSE OR NON-INFRINGING. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE 
#  OF THE COVERED SOFTWARE IS WITH YOU. SHOULD ANY COVERED SOFTWARE PROVE 
#  DEFECTIVE IN ANY RESPECT, YOU (NOT THE INITIAL DEVELOPER OR ANY OTHER 
#  CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY SERVICING, REPAIR OR CORRECTION.
#  NO USE OF ANY COVERED SOFTWARE IS AUTHORIZED HEREUNDER EXCEPT UNDER THIS 
#  DISCLAIMER.
#
#  When distributing this Code, include this HEADER in each file.
#  If applicable, add the following below this this HEADER, with the fields
#  enclosed by brackets "[]" replaced with your own identifying information:
#       Portions Copyright [yyyy] [name of copyright owner]
# 
#  HEADER END
# 
#       Copyright 2013-2014 Eddie Lau, Oracle Corporation US.
#       Copyright 2011 Andrew Hopkinson, Oracle Corporation UK Ltd.
#
################################################################################

export RUN_DATE=`date +"%Y/%m/%d-%T"`

#############################################################
##
## copyServerFiles
## ===============
##
## Copy the vServer img files to working location.
##
#############################################################

function copyServerFiles() {
	echo "[`date +\"%Y/%m/%d-%T\"`] Copying vServer Files"
	
	TEMPLATE_DIR=$WORKING_DIR/$VSERVER_NAME/template/BASE
	VIRTUAL_MACHINES_DIR=$REPOSITORY_DIR/VirtualMachines
	VIRTUAL_DISKS_DIR=$REPOSITORY_DIR/VirtualDisks
	ROOT_IMG_FILE=""
	
	GREP_VM_CFG=`grep "'$VSERVER_NAME'" $VIRTUAL_MACHINES_DIR/*/vm.cfg`
	VM_CFG=${GREP_VM_CFG%%:*}  # grep whatever before :, which shows the relative location of the vm.cfg
        
        # use the given VM template vm.cfg
        NEW_VM_CFG=$VMCFG_LOC  
        mkdir -p $TEMPLATE_DIR  
	cp $NEW_VM_CFG $TEMPLATE_DIR/vm.cfg 
        
	#DISKS=`grep disk $VM_CFG`
        DISKS=`grep '^[ ]*disk[ ]*=' $VM_CFG`
        
        # replace the disk line with the one in the stopped VM's vm.cfg
        LINENUM=$(sed -n '/[ \t]*disk[ \t]*=/=' $TEMPLATE_DIR/vm.cfg)
        sed -i "${LINENUM}s@.*@$DISKS@" $TEMPLATE_DIR/vm.cfg 
        
	FILES=${DISKS#*:}
        DEVICES=${FILES#*,} # new
        
	while [[ "$DISKS" != "$FILES" ]]
	do
		IMG_FILE=${FILES%%,*}
                DEVICE=${DEVICES%%,*}
                
                SYSTEM_IMG=${IMG_FILE#*VirtualDisks/} 
		echo "[`date +\"%Y/%m/%d-%T\"`] Copying $VIRTUAL_DISKS_DIR/$SYSTEM_IMG"
                cp $VIRTUAL_DISKS_DIR/$SYSTEM_IMG $TEMPLATE_DIR
                
                # use hda device name to determine whether it is the root disk 
                if [[ "$DEVICE" == "hda" ]]
		then
			ROOT_IMG_FILE=$TEMPLATE_DIR/$SYSTEM_IMG  
			echo "[`date +\"%Y/%m/%d-%T\"`] Found Root Image $ROOT_IMG_FILE"
		fi
		# Shuffle line for next disk
		DISKS=${DISKS#*:}
		FILES=${DISKS#*:}
                DEVICES=${FILES#*,} 
	done
        
        if [[ "$ROOT_IMG_FILE" == "" ]]
        then
                echo "[`date +\"%Y/%m/%d-%T\"`] Cannot find a disk with device name hda. Exiting..."
                exit 1
        fi
}
 
#############################################################
##
## compactAllDisks
## ===============
##
## compacting all disks in $TEMPLATE_DIR folder
##
#############################################################

function compactAllVDisks() {
	echo "[`date +\"%Y/%m/%d-%T\"`] Compacting all disks. Please ignore those \" I don't know how to handle files with mode...\", \"Disk ... doesn't contain a valid partition table\", \"dd: writing 'zero.file': No space left on device\", \"... looks like swapspace - not mounted\" and \"mount: you must specify the filesystem type\" messages."
	
	TEMPLATE_DIR=$WORKING_DIR/$VSERVER_NAME/template/BASE
        
        # loop through all .img files in $TEMPLATE_DIR
        find $TEMPLATE_DIR -iname "*.img" | while read f
	
	do
                SYSTEM_IMG=`basename ${f#./}`
                echo "[`date +\"%Y/%m/%d-%T\"`] Working on image: $SYSTEM_IMG"
                
                # determine disk type
                # Use fdisk -ul output
                # If the disk is a LVM disk, in one of the line it should say "Linux LVM". e.g.
                #[root@slc05fdc BASE]# fdisk -ul System.img
                #
                #     Device Boot      Start         End      Blocks   Id  System
                #System.img1   *          63      208844      104391   83  Linux
                #System.img2          208845    12289724     6040440   8e  Linux LVM
                FDISKLVM=$(fdisk -ul $TEMPLATE_DIR/$SYSTEM_IMG | grep "Linux LVM$" | wc -l)
                
                if [ "$FDISKLVM" -ge 1 ]
                then
                        IMGFS="lvm"
                        echo "$SYSTEM_IMG is of type LVM"
                else
                        IMGFS="ext3"
                        echo "$SYSTEM_IMG is of type ext3"
                fi

                # $TEMPLATE_DIR/$SYSTEM_IMG is the location of the disk image
                # Use fstype flag to know whether it is a LVM disk or not
                if [ $IMGFS = "lvm" ] 
                then
                        # mount the disk
                        cd $WORKING_DIR
                        # Mount the Image file
                        export LOOP=`losetup -f`
                        # Make Temp Mount Directory
                        mkdir -p $SYSTEMIMGDIR
                        
                        # Create Loop for the System Image
                        losetup $LOOP $TEMPLATE_DIR/$SYSTEM_IMG
                        kpartx -a $LOOP
                        
                        lvm pvscan
                        lvm vgchange -ay
                        
                        PARTS=$(lvm lvs | awk '{if ($1 ~/^LogVol.*/) print $2"-"$1}')
                        
                        PARTLIST=$(IFS=, ; echo "${PARTS[*]}")
                        echo "[`date +\"%Y/%m/%d-%T\"`] Containing parts: $PARTLIST"
                        
                        for PART in $PARTS
                        do
                                mount /dev/mapper/$PART $SYSTEMIMGDIR # new for LVM
                                if grep -qs "/dev/mapper/$PART" /proc/mounts
                                then
                                        echo "[`date +\"%Y/%m/%d-%T\"`] Mounting /dev/mapper/$PART successfully"
                                else
                                        echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount partition /dev/mapper/$PART. Skip..."
                                        continue
                                fi
                                
                                #Change Dir into mounted Image
                                cd $SYSTEMIMGDIR
        
                                # compact this vDisk
                                compactVDisk
                                echo "[`date +\"%Y/%m/%d-%T\"`] Compacting /dev/mapper/$PART successfully"
        
                                # Unmount the image file
                                cd $WORKING_DIR
                                umount $SYSTEMIMGDIR
                        done
                        
                        lvm vgchange -an
                        kpartx -d $LOOP
                        losetup -d $LOOP
                        
                        rm -rf $SYSTEMIMGDIR
                                
                        
                else # ext3
                
                        # Preview the partitions                
                        export LOOP=`losetup -f`
                        PARTS=$(kpartx -l $TEMPLATE_DIR/$SYSTEM_IMG | awk '{if ($3 ~/^[0-9]*$/ && $4 ~/^[0-9]*$/ && $6 ~/^[0-9]*$/) print $1}' & wait)
                        
                        PARTLIST=$(IFS=, ; echo "${PARTS[*]}")
                        echo "[`date +\"%Y/%m/%d-%T\"`] Containing parts: $PARTLIST"
                        
                        # If PARTS is empty, then release the loop device
                        if [[ X"$PARTLIST" = X"" ]]
                        then
                                losetup -d $LOOP
                        fi
                        
                        # mount the disk
                        cd $WORKING_DIR
                        
                        # Make Temp Mount Directory
                        mkdir -p $SYSTEMIMGDIR
                                
                        if [[ X"$PARTLIST" = X"" ]]
                        then
                                # mount using -r -o loop file.img mntpt
                                export LOOP=`losetup -f`
                                mount -o loop,rw,sync $TEMPLATE_DIR/$SYSTEM_IMG $SYSTEMIMGDIR
                                if !(mountpoint -q $SYSTEMIMGDIR)
                                then
                                        echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount $SYSTEM_IMG. Skip..."
                                        losetup -d $LOOP
                                        continue
                                else
                                        echo "[`date +\"%Y/%m/%d-%T\"`] Mounting $SYSTEM_IMG successfully"
                                fi
                                cd $SYSTEMIMGDIR
                                compactVDisk
                                echo "[`date +\"%Y/%m/%d-%T\"`] Compacting $SYSTEM_IMG successfully"
                                # Unmount the image file
                                cd $WORKING_DIR
                                umount -d $SYSTEMIMGDIR
                        else
                                # Mount the Image file
                                export LOOP=`losetup -f`
                                
                                # Create Loop for the System Image
                                losetup $LOOP $TEMPLATE_DIR/$SYSTEM_IMG
                                kpartx -a $LOOP
                                
                                for PART in $PARTS
                                do
                                        mount /dev/mapper/$PART $SYSTEMIMGDIR
                                        if grep -qs "/dev/mapper/$PART" /proc/mounts
                                        then
                                                echo "[`date +\"%Y/%m/%d-%T\"`] Mounting /dev/mapper/$PART successfully"
                                        else
                                                echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount partition /dev/mapper/$PART. Skip..."
                                                continue
                                        fi
                               
        
                                        #Change Dir into mounted Image
                                        cd $SYSTEMIMGDIR
        
                                        # compact this vDisk
                                        compactVDisk
                                        echo "[`date +\"%Y/%m/%d-%T\"`] Compacting /dev/mapper/$PART successfully"
        
                                        # Unmount the image file
                                        cd $WORKING_DIR
                                        umount $SYSTEMIMGDIR
                                done
                        
                                kpartx -d $LOOP
                                losetup -d $LOOP
                        fi
                        
                        rm -rf $SYSTEMIMGDIR                        
                
                fi

		# Shuffle line for next disk
		DISKS=${DISKS#*:}
		FILES=${DISKS#*:}
                DEVICES=${FILES#*,} 
	done
}

#### end of new


#############################################################
##
## unconfigureVM
## =================
##
## Remove / edit the files that a created / modified when the
## template has been used to created a vServer.
##
#############################################################

function unconfigureVM() {
	echo "[`date +\"%Y/%m/%d-%T\"`] Unconfiguring Root Image $ROOT_IMG_FILE. \"No such file or directory\" will be shown for those non-existing files to be removed."
	cd $WORKING_DIR
	# Mount the Image file
	export LOOP=`losetup -f`
        # Make Temp Mount Directory
	mkdir -p $SYSTEMIMGDIR
	# Create Loop for the System Image
	losetup $LOOP $ROOT_IMG_FILE
	kpartx -a $LOOP
        if [ $FSTYPE = "lvm" ]
        then
                lvm pvscan
                lvm vgchange -ay
                lvm lvs
                mount /dev/mapper/${VOLGROUP}-${LOGVOL} $SYSTEMIMGDIR
                if grep -qs "/dev/mapper/${VOLGROUP}-${LOGVOL}" /proc/mounts
                then
                        echo "[`date +\"%Y/%m/%d-%T\"`] Mounting /dev/mapper/${VOLGROUP}-${LOGVOL} successfully"
                else
                        echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount root partition ${VOLGROUP}-${LOGVOL}. Exiting..."
                        lvm vgchange -an
                        kpartx -d $LOOP
                        losetup -d $LOOP
                        rm -rf $SYSTEMIMGDIR
                        exit 1
                fi
                # 01/06: mount additional root lvm partitions
                if [[ X"$ADDROOTLVS" != X"" ]]
                then
                        while IFS=, read VG LV DIR
                        do
                                if [[ X"$VG" != X"" && X"$LV" != X"" && X"$DIR" != X"" ]]
                                then
                                        mount /dev/mapper/$VG-$LV $SYSTEMIMGDIR/$DIR
                                        if grep -qs "/dev/mapper/$VG-$LV" /proc/mounts
                                        then
                                                echo "[`date +\"%Y/%m/%d-%T\"`] Mounting /dev/mapper/$VG-$LV successfully"
                                        else
                                                echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount $VG-$LV. Skipping..."
                                        fi
                                fi
                        done < $ADDROOTLVS
                fi
                
        else # ext3
                mount /dev/mapper/`basename ${LOOP}${PARTITIONTOMOUNT}` $SYSTEMIMGDIR
                if grep -qs "/dev/mapper/`basename ${LOOP}${PARTITIONTOMOUNT}`" /proc/mounts
                then
                        echo "[`date +\"%Y/%m/%d-%T\"`] Mounting /dev/mapper/`basename ${LOOP}${PARTITIONTOMOUNT}` successfully"
                else
                        echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount root partition ${PARTITIONTOMOUNT}. Exiting..."
                        kpartx -d $LOOP
                        losetup -d $LOOP
                        rm -rf $SYSTEMIMGDIR
                        exit 1
                fi
                # 01:06: mount addition root partitions
                if [[ X"$ADDROOTPS" != X"" ]]
                then
                        while IFS=, read P DIR
                        do
                             if [[ X"$P" != X"" && X"$DIR" != X"" ]]
                             then
                                     mount /dev/mapper/`basename ${LOOP}${P}` $SYSTEMIMGDIR/$DIR
                                     if grep -qs "/dev/mapper/`basename ${LOOP}${P}`" /proc/mounts
                                     then
                                             echo "[`date +\"%Y/%m/%d-%T\"`] Mounting /dev/mapper/`basename ${LOOP}${P}` successfully"
                                     else
                                             echo "[`date +\"%Y/%m/%d-%T\"`] Fail to mount partition $P. Skipping..."
                                     fi
                             fi
                        done < $ADDROOTPS
                fi
        fi
        
	#Change Dir into mounted Image
	cd $SYSTEMIMGDIR
	
	# Unconfigure
	cp etc/sysconfig/ovmd etc/sysconfig/ovmd.orig
	sed 's/INITIAL_CONFIG=no/INITIAL_CONFIG=yes/' etc/sysconfig/ovmd.orig > etc/sysconfig/ovmd
	rm -v etc/sysconfig/ovmd.orig
	
	sed -i '/.*/d' etc/resolv.conf
	
	# Remove existing ssh information
	rm -v root/.ssh/*
	rm -v etc/ssh/ssh_host*
	
	# Clean up networking
	sed -i '/^GATEWAY/d' etc/sysconfig/network
	
	# Clean up hosts
	sed -i '/localhost/!d' etc/hosts
	sed -i '/localhost/!d' etc/sysconfig/networking/profiles/default/hosts
	
	# Remove Network scripts
	rm -v etc/sysconfig/network-scripts/ifcfg-*eth*
	rm -v etc/sysconfig/network-scripts/ifcfg-ib*
	rm -v etc/sysconfig/network-scripts/ifcfg-bond*
	
	# Remove log files
	rm -v var/log/messages*
	rm -v var/log/ovm-template-config.log
	rm -v var/log/ovm-network.log
	rm -v var/log/boot.log*
	rm -v var/log/cron*
	rm -v var/log/maillog*
	rm -v var/log/rpmpkgs*
	rm -v var/log/secure*
	rm -v var/log/spooler*
	rm -v var/log/yum.log*
        
        # clear last log
        echo "Clear last log"
        >var/log/lastlog
	
	# Remove Kernel Messages
	
	rm -v var/log/dmesg
	
	# Edit modprobe file
	sed -i '/bond/d' etc/modprobe.conf
	
	# Edit hwconf file
	cp etc/sysconfig/hwconf etc/sysconfig/hwconf.orig
	sed 's/mlx4_en/mlx4_core/' etc/sysconfig/hwconf.orig > etc/sysconfig/hwconf
	rm -v etc/sysconfig/hwconf.orig
	
	# Remove Exalogic Config file
	rm -v etc/exalogic.conf
	
	#Remove bash history
	rm -v root/.bash_history
        
        # compact this vDisk
        if [[ "$ZEROING" -eq 1 ]]
        then 
                compactVDisk
        fi
        
        # 01/06
        # Unmount other root partitions
        if [ $FSTYPE = "lvm" ]
        then
                if [[ X"$ADDROOTLVS" != X"" ]]
                then
                        tac $ADDROOTLVS | while IFS=, read VG LV DIR
                        do
                                if [[ X"$VG" != X"" && X"$LV" != X"" && X"$DIR" != X"" ]]
                                then
                                        umount $SYSTEMIMGDIR/$DIR
                                        echo "[`date +\"%Y/%m/%d-%T\"`] Unmounting $SYSTEMIMGDIR/$DIR successfully"
                                fi
                        done
                fi
        else
                # ext3
                if [[ X"$ADDROOTPS" != X"" ]]
                then
                        tac $ADDROOTPS | while IFS=, read P DIR
                        do
                             if [[ X"$P" != X"" && X"$DIR" != X"" ]]
                             then
                                     umount $SYSTEMIMGDIR/$DIR
                                     echo "[`date +\"%Y/%m/%d-%T\"`] Unmounting $SYSTEMIMGDIR/$DIR successfully"
                             fi
                        done
                fi
        fi
        
	# Unmount the image file
	cd $WORKING_DIR
	umount $SYSTEMIMGDIR
        echo "[`date +\"%Y/%m/%d-%T\"`] Unmounting $SYSTEMIMGDIR successfully"
        if [ $FSTYPE = "lvm" ] 
        then
                lvm vgchange -an
        fi
	kpartx -d $LOOP
	losetup -d $LOOP
        rm -rf $SYSTEMIMGDIR
}

function compactVDisk() {
        echo "[`date +\"%Y/%m/%d-%T\"`] Writing the zeroes"
        dd if=/dev/zero of=zero.small.file bs=1024 count=102400
        time dd if=/dev/zero of=zero.file bs=1024
        echo "[`date +\"%Y/%m/%d-%T\"`] Sync"
        sync ; sleep 60 ; sync
        echo "[`date +\"%Y/%m/%d-%T\"`] Remove Files"
        rm -f zero.small.file
        time rm -f zero.file
}

function buildTemplateTgz() {
	echo "[`date +\"%Y/%m/%d-%T\"`] Creating the Template tgz file"
	mkdir -p $DESTINATION_DIR
	cd $TEMPLATE_DIR
        # get one level up from BASE
        cd ..
        TEMPLATE_TGZ=$DESTINATION_DIR/el_template_$VSERVER_NAME.tgz
	tar -zcvf $TEMPLATE_TGZ *
	echo "[`date +\"%Y/%m/%d-%T\"`] Template $TEMPLATE_TGZ file created"
}

function cleanWorkingDir() {
	echo "[`date +\"%Y/%m/%d-%T\"`] Cleaning Working Directory"
	cd $WORKING_DIR
	rm -rfv $VSERVER_NAME
}

#############################################################
##
## createTemplate
## ==============
##
## High level template creation function that will call the 
## required processing function in the necessary sequence.
##
#############################################################

function createTemplate() {
	copyServerFiles
	unconfigureVM
        if [[ "$ZEROINGALL" -eq 1 ]] 
        then
                compactAllVDisks
        fi
	buildTemplateTgz
	cleanWorkingDir
	echo "[`date +\"%Y/%m/%d-%T\"`] $TEMPLATE_TGZ has been created from vServer $VSERVER_NAME "
}


function usage() {
	echo ""
	echo >&2 "usage: $0 -n <vServer Name> [-r <Repository Directory>] [-w <Working Directory>] [-d <Destination Directory>] [-c <vm.cfg Location>] [-t <Root File System Type>] [-v <Volume Group>] [-l <Logical Volume>] [-p <Partition To Mount>] [-log <Log File Location>] [-z | -Z]"
	echo >&2 ""
	echo >&2 "          -n <vServer Name> vServer to be templatised or cloned."
	echo >&2 "          -r <Repository Directory> Location (absolute or relative) of the repository. Default: $REPOSITORY_DIR"
	echo >&2 "          -w <Working Directory> Working directory (absolute or relative) where intermediate files will be copied. Default: $WORKING_DIR."
	echo >&2 "          -d <Destination Directory> Directory (absolute or relative) where the template tgz will be created. Default: $DESTINATION_DIR"
        echo >&2 "          -c <vm.cfg Location> Location (absolute or relative) of the vm.cfg that you want to put to the resulting tgz. Default: $VMCFG_LOC"
        echo >&2 "          -t <Root File System Type> Root File System Type (lvm/ext3). Default: $FSTYPE"
        echo >&2 "          -v <Volume Group> (for lvm root file system type) The LVM volume group of the root disk. Default: $VOLGROUP"
        echo >&2 "          -l <Logical Volume> (for lvm root file system type) The LVM logical group of the root disk. Default: $LOGVOL"
        echo >&2 "          -addrootlvs <Additional Root Logical Volumes File> (for lvm root file system type) Location (absolute or relative) of the file specifying VolumeGroup,LogicalVolume,MountDir of additional root logical volumes"
        echo >&2 "          -p <Partition To Mount> (for ext3 root file system type). The ext3 partition of the root disk. Default: $PARTITIONTOMOUNT"
        echo >&2 "          -addrootps <Additional Root Partitions File> (for ext3 root file system type) Location (absolute or relative) of the file specifying Partition,MountDir of additional root partitions"
        echo >&2 "          -log <Log File Location> Location (absolute/relative) of the log file. Default: $LOG_FILE"
        echo >&2 "          -z Compacting the root disk"
        echo >&2 "          -Z Compacting all disks"
	echo ""
	exit 1
}

###############################################################
##
## Simple start for the script that will extract the parameters
## and call the appriate start function.
##
###############################################################

export VMCFG_LOC="`pwd`/vm.cfg"
export WORKING_DIR="/u01/common/images/vServerTemplateWIP"
export DESTINATION_DIR="/u01/common/images/vServerTemplates"
export REPOSITORY_DIR="/OVS/Repositories/*"
export VOLGROUP="VolGroup00"
export LOGVOL="LogVol00"
export PARTITIONTOMOUNT="p2"
export SYSTEMIMGDIR=/mnt/elsystem
export FSTYPE="lvm"
export ZEROING=0
export ZEROINGALL=0
export LOG_FILE="`pwd`/CreateTemplateFromVServer.log"
export ADDROOTLVS=""
export ADDROOTPS=""

ARGS=$@

while [ $# -gt 0 ]
do
	case "$1" in	
                -c) VMCFG_LOC="$2"; shift;;
		-n) VSERVER_NAME="$2"; shift;;
		-r) REPOSITORY_DIR="$2"; shift;;
		-d) DESTINATION_DIR="$2"; shift;;
		-w) WORKING_DIR="$2"; shift;;
                -v) VOLGROUP="$2"; shift;;
                -p) PARTITIONTOMOUNT="$2"; shift;;
                -t) FSTYPE="$2"; shift;;
                -l) LOGVOL="$2"; shift;;
                -z) ZEROING=1; ;;
                -Z) ZEROINGALL=1; ;;
                -log) LOG_FILE="$2"; shift;;
                -addrootlvs) ADDROOTLVS="$2"; shift;;
                -addrootps) ADDROOTPS="$2"; shift;;
		*) usage; exit 1; ;;
		*) break;;
	esac
	shift
done

# Turn relative paths into absolute paths
# return empty string if file not found
VMCFG_LOC=$(readlink -f $VMCFG_LOC) 
WORKING_DIR=$(readlink -f $WORKING_DIR)
DESTINATION_DIR=$(readlink -f $DESTINATION_DIR)
REPOSITORY_DIR=$(readlink -f $REPOSITORY_DIR)
LOG_FILE=$(readlink -f $LOG_FILE)

# Log and show messages on console and log file
exec > >(tee -a $LOG_FILE)
exec 2>&1

# log the command
echo "=== $0 (version: $VERSION) ==="
echo "[`date +\"%Y/%m/%d-%T\"`] Executing command: $0 $ARGS"

# Processing function call
if [[ X"$VMCFG_LOC" = X"" ]]
then
        echo "[`date +\"%Y/%m/%d-%T\"`] Missing vm.cfg. Exiting..."
        usage
        exit 1
fi

if [[ X"$WORKING_DIR" = X"" ]]
then
        echo "[`date +\"%Y/%m/%d-%T\"`] The given working directory is not valid. Exiting..."
        usage
        exit 1
fi

if [[ X"$DESTINATION_DIR" = X"" ]]
then
        echo "[`date +\"%Y/%m/%d-%T\"`] The given destination directory is not valid. Exiting..."
        usage
        exit 1
fi

if [[ X"$REPOSITORY_DIR" = X"" ]]
then
        echo "[`date +\"%Y/%m/%d-%T\"`] The given repository directory is not valid. Exiting..."
        usage
        exit 1
fi

if [ ! -f $VMCFG_LOC ]
then
        echo "[`date +\"%Y/%m/%d-%T\"`] $VMCFG_LOC is not a file. Exiting..."
        usage
        exit 1
fi

# validate $ADDROOTLVS if specified
if [[ X"$ADDROOTLVS" != X"" ]]
then
        # make sure the file is there
        if [[ ! -f $(readlink -f $ADDROOTLVS) ]]
        then
                echo "[`date +\"%Y/%m/%d-%T\"`] $ADDROOTLVS is not a file. Exiting..."
                usage
                exit 1
        else
                # replace the variable with absolute path
                ADDROOTLVS=$(readlink -f $ADDROOTLVS)
        fi
fi

# validate $ADDROOTPS if specified
if [[ X"$ADDROOTPS" != X"" ]]
then
        # make sure the file is there
        if [[ ! -f $(readlink -f $ADDROOTPS) ]]
        then
                echo "[`date +\"%Y/%m/%d-%T\"`] $ADDROOTPS is not a file. Exiting..."
                usage
                exit 1
        else
                # replace the variable with absolute path
                ADDROOTPS=$(readlink -f $ADDROOTPS)
        fi
fi

if [[ "$VSERVER_NAME" == "" || "$REPOSITORY_DIR" == "" ]]
then
	usage
        exit 1
else
        createTemplate
fi
