#!/bin/sh

# The script assumes it's being run from the directory containing the System.img

# Export for later i.e. during unmount
export LOOP=`losetup -f`
export SYSTEMIMGDIR=/mnt/elsystem.$$
export SYSTEMIMG=System.img
export TEMPLATEDIR=`pwd`

# Read Parameters
while [ $# -gt 0 ]
do
	case "$1" in
		-i) SYSTEMIMG="$2"; shift;;
		*) echo ""; echo >&2 \
		    "usage: $0 [-i <System Image Name (Default System.img)> "
		    echo""; exit 1;;
		*) break;;
	esac
	shift
done

# Make Temp Mount Directory
mkdir -p $SYSTEMIMGDIR
# Create Loop for the System Image
losetup $LOOP $SYSTEMIMG
kpartx -a $LOOP
mount /dev/mapper/`basename $LOOP`p2 $SYSTEMIMGDIR
#Change Dir into mounted Image
cd $SYSTEMIMGDIR
echo "######################################################################"
echo "###                                                                ###"
echo "### Starting Bash shell for editing. When completed log out to     ###"
echo "### Unmount the System.img file.                                   ###"
echo "###                                                                ###"
echo "######################################################################"
echo
bash
cd ~
cd $TEMPLATEDIR
umount $SYSTEMIMGDIR
kpartx -d $LOOP
losetup -d $LOOP
rm -rf $SYSTEMIMGDIR
