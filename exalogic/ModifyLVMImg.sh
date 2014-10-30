#!/bin/bash

################################################################################
#
# 	Exalogic Virtual (Linux x86-64) Simplified CLI
#  HEADER START
# 
#  THIS SCRIPT IS PROVIDED ON AN AS IS BASIS, WITHOUT WARRANTY OF ANY KIND, 
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
# 
#       Copyright 2013 Andrew Hopkinson, Oracle Corporation UK Ltd.
#
################################################################################

export VERSION=1.3
export BUILD_DATE="20th March 2014"

function disclaimer() {
	echo ""
	echo ""
	echo ""
	echo "##########################################################################################"
	echo "##                                                                                      ##"
	echo "##                                     DISCLAIMER                                       ##"
	echo "##                                                                                      ##"
	echo "##  THIS SCRIPT IS PROVIDED ON AN AS IS BASIS, WITHOUT WARRANTY OF ANY KIND,            ##"
	echo "##  EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, WARRANTIES THAT         ##"
	echo "##  THE COVERED SCRIPT IS FREE OF DEFECTS, MERCHANTABLE, FIT FOR A PARTICULAR           ##"
	echo "##  PURPOSE OR NON-INFRINGING. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE        ##"
	echo "##  OF THE COVERED SOFTWARE IS WITH YOU. SHOULD ANY COVERED SOFTWARE PROVE              ##"
	echo "##  DEFECTIVE IN ANY RESPECT, YOU (NOT THE INITIAL DEVELOPER OR ANY OTHER               ##"
	echo "##  CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY SERVICING, REPAIR OR CORRECTION.      ##"
	echo "##                                                                                      ##"
	echo "##  THIS SCRIPT IS NOT PART OF THE BASE PRODUCT SET AND AS SUCH, ALTHOUGH FUNCTIONAL,   ##"
	echo "##  IS PROVIDED ONLY AS AN EXAMPLE OF WHAT CAN BE DONE.                                 ##"
	echo "##                                                                                      ##"
	echo "##########################################################################################"
	echo ""
	echo ""
	echo ""
}

function displayVersion() {
	echo ""
	echo ""
	echo ""
	echo "##########################################################################################"
	echo "##                                                                                      ##"
	echo "##      Version    : $VERSION"
	echo "##      Build Date : $BUILD_DATE"
	echo "##                                                                                      ##"
	echo "##########################################################################################"
	echo ""
	echo ""
	echo ""
}

function showVersionHistory() {

	echo ""
	echo ""
	echo ""
	echo "####################################################################################"
	echo "## Version    Date         Change"
	echo "## =======    ==========   ========================================================="
	echo "##"
	echo "## 1.1        04/02/2014   Added version information"
	echo "##"
	echo "## 1.2       	19/03/2014   Test the extend value of for root and swap before "
	echo "##                         attempting to extend."
	echo "##"
	echo "## 1.3       	20/03/2014   Add check to see if we can add Primary Partition to the "
	echo "##                         Image before attempting to extend. The Image can only "
	echo "##                         4 Primary Partitions."
	echo "##"
	echo "##################################################################################"
	echo ""
	echo ""
	echo ""

}

function addRpms() {
	echo "***********************************************"
	echo "*** Adding RPMs to $SYSTEMIMG"
	echo "***********************************************"
	export LOOP=`losetup -f`
	echo "***********************************************"
	echo "*** Using loop $LOOP"
	echo "***********************************************"
	
	losetup $LOOP $SYSTEMIMG
	
	echo "***********************************************"
	echo "*** Mounting $LOOP"
	echo "***********************************************"
	kpartx -av $LOOP
	
  mkdir -p $SYSTEMIMGDIR
	
	vgchange -ay $MAPVGNAME
	ls -l /dev/mapper
	mount /dev/mapper/$MAPVGNAME-$MAPROOTLVNAME $SYSTEMIMGDIR
	if [[ "$?" != "1" ]]
	then
		echo "==============================================="
		mkdir -p $SYSTEMIMGDIR/addrpm
		while read RPM;
		do
			echo "Adding: $RPM"
			if [[ "$RPMSDIR" == "" ]]
			then
				cp $RPM $SYSTEMIMGDIR/addrpm
			else
				cp $RPMSDIR/$RPM $SYSTEMIMGDIR/addrpm
			fi
			chroot $SYSTEMIMGDIR /bin/bash -c "rpm -i /addrpm/$RPM"
			rm -rf $SYSTEMIMGDIR/addrpm/$RPM
		done < $ADDRPMSFILE
		echo "==============================================="
		if [[ "$VERBOSE" == "true" ]]
		then
			chroot $SYSTEMIMGDIR /bin/bash -c 'rpm -qa'
			echo "==============================================="
		fi
		
    umount $SYSTEMIMGDIR
	else
	    echo "Failed to mount image file - exiting"
	fi
	
	echo "***********************************************"
	echo "*** Unmounting $LOOP"
	echo "***********************************************"
	kpartx -dv $LOOP
	losetup -d $LOOP
}


function delRpms() {
	echo "***********************************************"
	echo "*** Deleting RPMs to $SYSTEMIMG"
	echo "***********************************************"
	export LOOP=`losetup -f`
	echo "***********************************************"
	echo "*** Using loop $LOOP"
	echo "***********************************************"
	
	losetup $LOOP $SYSTEMIMG
	
  mkdir -p $SYSTEMIMGDIR
	
	vgchange -ay $MAPVGNAME
	ls -l /dev/mapper
	mount /dev/mapper/$MAPVGNAME-$MAPROOTLVNAME $SYSTEMIMGDIR
	if [[ "$?" != "1" ]]
	then
		echo "==============================================="
		while read RPM;
		do
			echo "Deleting: $RPM"
			chroot $SYSTEMIMGDIR /bin/bash -c "rpm -e $RPM"
		done < $DELRPMSFILE
		echo "==============================================="
		if [[ "$VERBOSE" == "true" ]]
		then
			chroot $SYSTEMIMGDIR /bin/bash -c 'rpm -qa'
			echo "==============================================="
		fi
		
    umount $SYSTEMIMGDIR
	else
	    echo "Failed to mount image file - exiting"
	fi
	
	losetup -d $LOOP
}


function extendImg() {

	echo "***********************************************"
	echo "*** Extending $SYSTEMIMG"
	echo "***********************************************"
	dd if=/dev/zero of=$SYSTEMIMG bs=$BLOCKSIZE count=0 seek=$ADDBLOCKS
	
	export LOOP=`losetup -f`
	echo "***********************************************"
	echo "*** Using loop $LOOP"
	echo "***********************************************"
	
	losetup $LOOP $SYSTEMIMG
	
	export P=0
	
	fdisk -l $LOOP
	#partitionArray=( $(fdisk -l $LOOP | sed 's/ /|/g') )
	partitionArray=( $(fdisk -l $LOOP) )
	for partition in "${partitionArray[@]}"
	do
		if [[ "$partition" == *"/dev/loop0p"* ]]
		then
			P=$((P + 1))
			echo "$P. Found $partition"
		fi
	done
	P=$((P + 1))
	
	if [[ ("$P" < 5) ]]
	then
		echo "Creating new Primary partition $P"
	
		echo ""
		echo "***********************************************"
		echo "(echo n; echo p; echo $P; echo ; echo ; echo t; echo $P; echo 8e; echo w) | fdisk $LOOP"
		echo "***********************************************"
		echo ""
		
		(echo n; echo p; echo $P; echo ; echo ; echo t; echo $P; echo 8e; echo w) | fdisk $LOOP
		
		echo ""
		fdisk -l $LOOP
		echo ""
		
		#echo "***********************************************"
		#echo "*** Pausing $SLEEP seconds for previous command"
		#echo "***********************************************"
		#sleep $SLEEP
		
		echo "***********************************************"
		echo "*** Mounting $LOOP"
		echo "***********************************************"
		msgArray=( $(kpartx -av $LOOP | sed 's/ /|/g') )
		echo "==============================================="
		for msg in "${msgArray[@]}"
		do
			echo "$msg"
			loopId=${msg%%|*}
			msg=${msg#*|}
			loopId=${msg%%|*}
			msg=${msg#*|}
			loopId=${msg%%|*}
			msg=${msg#*|}
		done
		echo "Using loopId: $loopId"
		echo "==============================================="
		
		echo "***********************************************"
		echo "*** Scanning Volume Groups"
		echo "***********************************************"
		vgscan
		
		if [[ "$VERBOSE" == "true" ]]
		then
			pvdisplay
			vgdisplay
			lvdisplay
		fi
		
		#echo "***********************************************"
		#echo "*** Pausing $SLEEP seconds for previous command"
		#echo "***********************************************"
		#sleep $SLEEP
		
		echo "***********************************************"
		echo "*** Extending $VGNAME"
		echo "***********************************************"
		#msg=$(vgextend VolGroup00 /dev/mapper/`basename $LOOP`p3)
		msg=$(vgextend $VGNAME /dev/mapper/$loopId 2>&1)
		echo "==============================================="
		echo "$msg"
		echo "==============================================="
		if [[ "$msg" == *"$VGNAME"* && "$msg" == *"successfully extended"* ]]
		then
		
			if [[ "$VERBOSE" == "true" ]]
			then
				vgdisplay
			fi
			
			if [[ $EXTROOT > 0 ]]
			then
				echo "***********************************************"
				echo "***** Extending Root $ROOTLVNAME"
				echo "***********************************************"
				lvextend -L+`echo $EXTROOT`G /dev/$VGNAME/$ROOTLVNAME
			fi
			
			if [[ $EXTSWAP > 0 ]]
			then
				echo "***********************************************"
				echo "***** Extending Swap $SWAPLVNAME"
				echo "***********************************************"
				lvextend -L+`echo $EXTSWAP`G /dev/$VGNAME/$SWAPLVNAME
			fi
			
			echo "***********************************************"
			echo "*** Changing $VGNAME"
			echo "***********************************************"
			vgchange -ay $VGNAME
			
			echo "***********************************************"
			echo "***** Checking Root $ROOTLVNAME"
			echo "***********************************************"
			e2fsck -fp /dev/mapper/$VGNAME-$ROOTLVNAME
			
			echo "***********************************************"
			echo "***** Resizing Root $ROOTLVNAME"
			echo "***********************************************"
			resize2fs /dev/mapper/$VGNAME-$ROOTLVNAME
			
			echo "***********************************************"
			echo "***** Setting Swap $SWAPLVNAME"
			echo "***********************************************"
			mkswap /dev/mapper/$VGNAME-$SWAPLVNAME 
			
			vgchange -an $VGNAME
		
			echo "***********************************************"
			echo "***** Changing UUID of $VGNAME"
			echo "***********************************************"
			vgchange -u $VGNAME
			
			if [[ "$VERBOSE" == "true" ]]
			then
				vgdisplay
				lvdisplay
			fi
			
		else
			echo ""
			echo ""
			echo "***********************************************"
			echo "**************    ERROR    ********************"
			echo "***********************************************"
			echo ""
			echo " Validate that the filter entry for OVS has been "
			echo " changed from :"
			echo "              filter = [ "r/.*/" ]"
			echo "           to :"
			echo "              filter = [ "a/.*/" ]"
			echo ""
			echo " /etc/lvm/lvm.conf"
			echo ""
			echo "***********************************************"
			echo ""
			echo ""
		fi
		
		
		echo "***********************************************"
		echo "*** Unmounting $LOOP"
		echo "***********************************************"
		sync
		kpartx -dv $LOOP
		sync
		losetup -d $LOOP
		sync
	else
		echo ""
		echo "================================================"
		echo "==                                            =="
		echo "==                   ERROR                    =="
		echo "==                                            =="
		echo "== Unable to create additional Primary        =="
		echo "== Partition for this Image file Aborting.    =="
		echo "==                                            =="
		echo "================================================"
		echo ""
		echo ""
		echo ""
		echo ""
		echo "***********************************************"
		echo "*** Unmounting $LOOP"
		echo "***********************************************"
		losetup -d $LOOP
	fi
}

function renameLVM() {
	export LOOP=`losetup -f`
	echo "***********************************************"
	echo "*** Using loop $LOOP"
	echo "***********************************************"
	
	losetup $LOOP $SYSTEMIMG
	
	echo "***********************************************"
	echo "*** Mounting $LOOP"
	echo "***********************************************"
	kpartx -av $LOOP

	if [[ "$VERBOSE" == "true" ]]
	then
		vgdisplay
		lvdisplay
	fi

	if [[ "$NEWROOTLVNAME" != "" ]]
	then
		echo "***********************************************"
		echo "*** Renaming LogVol $ROOTLVNAME"
		echo "***********************************************"
		lvrename /dev/$VGNAME/$ROOTLVNAME /dev/$VGNAME/$NEWROOTLVNAME
		echo ""
		MAPROOTLVNAME=$NEWROOTLVNAME
	fi
	if [[ "$NEWSWAPLVNAME" != "" ]]
	then
		echo "***********************************************"
		echo "*** Renaming LogVol $SWAPLVNAME"
		echo "***********************************************"
		lvrename /dev/$VGNAME/$SWAPLVNAME /dev/$VGNAME/$NEWSWAPLVNAME
		echo ""
		MAPSWAPLVNAME=$NEWSWAPLVNAME
	fi
	if [[ "$NEWVGNAME" != "" ]]
	then
		echo "***********************************************"
		echo "*** Renaming VolGroup $VGNAME"
		echo "***********************************************"
		vgrename /dev/$VGNAME /dev/$NEWVGNAME
		echo ""
		MAPVGNAME=$NEWVGNAME
	fi
	
	if [[ "$NEWVGNAME" != "" || "$NEWSWAPLVNAME" != "" || "$NEWROOTLVNAME" != "" ]]
	then
	  mkdir -p $SYSTEMIMGDIR
		
		vgchange -ay $MAPVGNAME
		ls -l /dev/mapper
		echo "==============================================="
		echo "Modifying fstab entry"
		echo "==============================================="
		mount /dev/mapper/$MAPVGNAME-$MAPROOTLVNAME $SYSTEMIMGDIR
		if [[ "$?" != "1" ]]
		then
			sed -i "s/$VGNAME/$MAPVGNAME/g" $SYSTEMIMGDIR/etc/fstab
			sed -i "s/$ROOTLVNAME/$MAPROOTLVNAME/g" $SYSTEMIMGDIR/etc/fstab
			sed -i "s/$SWAPLVNAME/$MAPSWAPLVNAME/g" $SYSTEMIMGDIR/etc/fstab
			
			if [[ "$VERBOSE" == "true" ]]
			then
				echo "============================================"
				echo " Modified fstab file"
				echo ""
				cat $SYSTEMIMGDIR/etc/fstab
				echo "============================================"
			fi
			
	    umount $SYSTEMIMGDIR
		else
		    echo "Failed to mount image file - exiting"
		fi
		
		echo "==============================================="
		echo "Modifying grub entry"
		echo "==============================================="
		mount /dev/mapper/`basename $LOOP`p1 $SYSTEMIMGDIR
		if [[ "$?" != "1" ]]
		then
			ls -lh $SYSTEMIMGDIR
			sed -i "s/$VGNAME/$MAPVGNAME/g" $SYSTEMIMGDIR/grub/grub.conf
			sed -i "s/$ROOTLVNAME/$MAPROOTLVNAME/g" $SYSTEMIMGDIR/grub/grub.conf
			sed -i "s/$SWAPLVNAME/$MAPSWAPLVNAME/g" $SYSTEMIMGDIR/grub/grub.conf
			
			if [[ "$VERBOSE" == "true" ]]
			then
				echo "============================================"
				echo " Modified fstab file"
				echo ""
				cat $SYSTEMIMGDIR/grub/grub.conf
				echo "============================================"
			fi
			
			initrdArray=( $(grep initrd $SYSTEMIMGDIR/grub/grub.conf | grep -v '#' | sed 's/ /|/g') )
			for initrd in "${initrdArray[@]}"
			do
#				echo "initrd: $initrd"
				filename=${initrd%%|*}
				initrd=${initrd#*|}
				filename=${initrd%%|*}
				extfilename=${initrd%%.img*}
#				echo "filename: $filename"
#				echo "exfilename: $extfilename"
				cp $SYSTEMIMGDIR$filename initrd.gz
				gunzip -f initrd.gz
				ls -lh
				mkdir -p initrdExp
				cd initrdExp
				cpio -id < ../initrd
				sed -i "s/$VGNAME/$MAPVGNAME/g" init
				sed -i "s/$ROOTLVNAME/$MAPROOTLVNAME/g" init
				sed -i "s/$SWAPLVNAME/$MAPSWAPLVNAME/g" init
				
				if [[ "$VERBOSE" == "true" ]]
				then
					echo "============================================"
					echo " Modified init file"
					echo ""
					cat init
					echo ""
					echo "============================================"
				fi
				
				find . | cpio --create --format='newc' > ../newinitrd
				cd ..
				gzip -f newinitrd
				mv -f newinitrd.gz $SYSTEMIMGDIR$filename
				rm -f initrd
				rm -rf initrdExp
#				break				
			done
	    umount $SYSTEMIMGDIR
		else
		    echo "Failed to mount image file - exiting"
		fi
#		vgchange -u $MAPVGNAME
		vgchange -an $MAPVGNAME
	fi
	
	#vgscan
	if [[ "$VERBOSE" == "true" ]]
	then
		vgdisplay
		lvdisplay
	fi
	
	echo "***********************************************"
	echo "*** Unmounting $LOOP"
	echo "***********************************************"
	kpartx -dv $LOOP
	losetup -d $LOOP
}

function usage() {
	echo ""
	echo >&2 "usage: $0 [-if <System Image File>] [-er <Root Extend Size in Gb>] [-es <Swap Extend Size in Gb>] [ -bs <Block Size bytes>] [-vg <Volume Group Name>] [-rlv <Root Logical Volume Name>] [-slv <Swap Logical Volume Name>] [-nvg <New Volume Group Name>] [-nrlv <New Root Logical Volume Name>] [-nslv <New Swap Logical Volume Name>]"
	echo >&2 " "
	echo >&2 "          -if <Image File> : This specificies the image file to be processed and will default to System.img"
	echo >&2 "          -er <Root Extend Size> : This is the additional amount of space that will be added to the root Logical Volume (in GB). Defaults to 0"
	echo >&2 "          -es <Swap Extend Size> : This is the additional amount of space that will be added to the swap Logical Volume (in GB). Defaults to 0"
	echo >&2 "          -bs <Block Size> : Block size (in bytes) to be used whilst extending. Defaults to 1024 bytes"
	echo >&2 "          -vg <Volume Group Name> : Name of the current Volume Group. Default VolGroup00"
	echo >&2 "          -rlv <Root Logical Volume Name> : Name of the current Root Logical Volume. Default LogVol00"
	echo >&2 "          -slv <Swap Logical Volume Name> : Name of the current Swap Logical Volume. Default LogVol01"
	echo >&2 "          -nvg <New Volume Group Name> : Name of the new Volume Group. If not specified then the name will not be changed"
	echo >&2 "          -nrlv <New Root Logical Volume Name> : Name of the new Root Logical Volume. If not specified then the name will not be changed"
	echo >&2 "          -nslv <New Swap Logical Volume Name> : Name of the new Swap Logical Volume. If not specified then the name will not be changed"
	echo >&2 " "
	
	exit 1
}


export SYSTEMIMGDIR=/mnt/elsystem
export BASEIMAGESIZE=6
export SYSTEMIMG=System.img
export EXTROOT=0
export EXTSWAP=0
export BLOCKSIZE=1024
export GIGABYTE=`expr 1024 \* 1024 \* 1024`
export SLEEP=10

export VGNAME=VolGroup00
export ROOTLVNAME=LogVol00
export SWAPLVNAME=LogVol01

export MAPVGNAME=$VGNAME
export MAPROOTLVNAME=$ROOTLVNAME
export MAPSWAPLVNAME=$SWAPLVNAME

export VERBOSE=false
#export ADDRPMSFILE=""
#export DELRPMSFILE=""
#export RPMSDIR=""


# Disclaimer
disclaimer


while [ $# -gt 0 ]
do
	case "$1" in	
		-if) SYSTEMIMG="$2"; shift;;
		-er) EXTROOT="$2"; shift;;
		-es) EXTSWAP="$2"; shift;;
		-bs) BLOCKSIZE="$2"; shift;;
		-vg) VGNAME="$2"; shift;;
		-rlv) ROOTLVNAME="$2"; shift;;
		-slv) SWAPLVNAME="$2"; shift;;
		-nvg) NEWVGNAME="$2"; shift;;
		-nrlv) NEWROOTLVNAME="$2"; shift;;
		-nslv) NEWSWAPLVNAME="$2"; shift;;
		-addrpms) ADDRPMSFILE="$2"; shift;;
		-delrpms) DELRPMSFILE="$2"; shift;;
		-rpmsdir) RPMSDIR="$2"; shift;;
		-v) VERBOSE=true;;
		*) usage;;
		*) break;;
	esac
	shift
done

#rpm -qid lvm2

echo "***********************************************"
echo "*** Modifying $SYSTEMIMG"
echo "***********************************************"

ls -lh
	
# Extend Root or Swap
if [[ "$EXTROOT" != "0" || "$EXTSWAP" != "0" ]]
then
	# Calculate sizing
	# Spare blocks to get around extent issue, i.e. missing 1 extent
	SPAREBLOCKS=$((($GIGABYTE / $BLOCKSIZE) / 2))
	BASEIMAGESIZE=$(stat -c%s "$SYSTEMIMG")
	BASEIMGBLOCKS=$(($BASEIMAGESIZE / $BLOCKSIZE))
	ROOTADD=$(($EXTROOT * $GIGABYTE / $BLOCKSIZE))
	SWAPADD=$(($EXTSWAP * $GIGABYTE / $BLOCKSIZE))
	ADDBLOCKS=$(($ROOTADD + $SWAPADD + $BASEIMGBLOCKS + $SPAREBLOCKS))
	
	echo "Block size: $BLOCKSIZE"
	echo "Base Image Size $BASEIMAGESIZE"
	echo "Base Image $BASEIMGBLOCKS blocks"
	echo "Adding $ROOTADD blocks to root file system"
	echo "Adding $SWAPADD blocks to swap file system"
	echo "Adding $SPAREBLOCKS spare blocks"
	echo "Resizing image file to $ADDBLOCKS"
	
	extendImg
	
fi
# Check if we are adding RPMs
if [[ "$ADDRPMSFILE" != "" ]]
then
	addRpms
fi
# Check if we are deleting RPMs
if [[ "$DELRPMSFILE" != "" ]]
then
	delRpms
fi
# Rename VolGroup of Volumes
if [[ "$NEWVGNAME" != "" || "$NEWROOTLVNAME" != "" || "$NEWSWAPLVNAME" != "" ]]
then
	renameLVM
fi

ls -lh

echo "***********************************************"
echo "*** $SYSTEMIMG Modified"
echo "***********************************************"

