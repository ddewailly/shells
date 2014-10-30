#!/bin/bash
#chkconfig: 345 20 80
#description: NFSv4 Automount
case "$1" in
"start")
  mount -a -t nfs4
  ;;
"stop")
  for fileSystem in $(cat /etc/fstab|grep -v "^#"|grep nfs4|gawk '{print $2}')
  do
    fuser -mk ${fileSystem}
    umount -f ${fileSystem}
  done
  ;;
*)
  echo "Do Nothing"
  ;;
esac