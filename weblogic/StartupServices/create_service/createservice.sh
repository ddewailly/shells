#!/bin/sh

[ `id -u` -ne 0 ] && echo "Script must be run as root" && exit 1

usage="createservice.sh myServerRole(admin or apps) myNmPort myDomainName myAppServerName myDomainType(forms or webapp)"

SERVICE_FILE=/etc/init.d/wls-$3-$4

[ -f $SERVICE_FILE ] && echo "Script already exists. Remove $SERVICE_FILE before running" && exit 1

cp  `dirname $0`/wls_model $SERVICE_FILE
case "$1" in
    admin)
        sed -i 's/<STARTORDER>/96 04/' $SERVICE_FILE
        ;;
    apps)
        sed -i 's/<STARTORDER>/97 03/' $SERVICE_FILE
		;;
    *)
	echo $usage
	rm $SERVICE_FILE -f
	exit 1
	;;
esac
sed -i 's/<NMPORT>/'$2'/' $SERVICE_FILE
sed -i 's/<DOMAINNAME>/'$3'/' $SERVICE_FILE
sed -i 's/<APPSERVERNAME>/'$4'/' $SERVICE_FILE
case "$5" in
    forms)
        sed -i 's!<ROOTWEBLOGIC>!/wls/products/weblogic/forms/10.3.6.0/wlserver_10.3!' $SERVICE_FILE
        ;;
    webapp)
        sed -i 's!<ROOTWEBLOGIC>!/wls/products/weblogic/jee/10.3.6.0/wlserver_10.3!' $SERVICE_FILE
		;;
    *)
	echo $usage
	rm $SERVICE_FILE -f
	exit 1
	;;
esac
chmod +x $SERVICE_FILE
chkconfig --add wls-$3-$4 
