#!/bin/bash
#
#       /etc/rc.d/init.d/weblogic-init.sh
#
# Starts the domain weblogic-init.sh
#
# chkconfig: 235 85 15
# description:demarrage des produits WLS
# processname: weblogic-init.sh
trap "exit 255" 1 2 3           # ignore signals

ENVI=UAT
TYPE=WEBAPPS
SERV=$(hostname -s|tr [A-Z] [a-z])
export SCRIPTHOME=/export/scripts/weblogic/controleWlsDomain
. ${SCRIPTHOME}/environment/setEnv_${TYPE}.sh
case $1 in
'start')
	echo "Starting weblogic Node Manager ..."
	su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} startNode >> ${LOG} 2>&1"
	case ${SERVTYPE} in 
	  "2"|"3"|"4") 
	    echo "No admin server to start" ;;
	*)   echo "Starting weblogic Admin Server ..."
	      su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} startAdmin >> ${LOG} 2>&1" ;;
	esac
	if [ "x"${SERVER_LIST} != "x" ]; 
	then 
		for curServer in `echo ${SERVER_LIST}`
		do
		  echo "Starting weblogic Managed Server ${curServer}..."
		  su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} startServer ${curServer} >> ${LOG} 2>&1"
		done
	else
		echo "No Weblogic Server to start ..."
	fi
	if [ "x"${CLUSTER_LIST} != "x" ]; 
	then 
		for curCluster in `echo ${CLUSTER_LIST}`
		do
		  echo "Starting weblogic Cluster ${curCluster}..."
		  su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} startCluster ${curCluster} >> ${LOG} 2>&1"
		done
	else
		echo "No Weblogic Cluster to start ..."
	fi
  ;;
'stop')
	if [ "x"${CLUSTER_LIST} != "x" ]; 
	then 
		for curCluster in `echo ${CLUSTER_LIST}`
		do
		  echo "Stoping weblogic Cluster ${curCluster}..."
		  su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} stopCluster ${curCluster} >> ${LOG} 2>&1"
		done
	else
		echo "No Weblogic Cluster to stop ..."
	fi
	if [ "x"${SERVER_LIST} != "x" ]; 
	then 
		for curServer in `echo ${SERVER_LIST}`
		do
		  echo "Stoping weblogic Managed Server ${curServer}..."
		  su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} stopServer ${curServer} >> ${LOG} 2>&1"
		done
	else
		echo "No Weblogic Server to stop ..."
	fi
	case ${SERVTYPE} in 
	  "2"|"3"|"4") 
	    echo "No admin server to stop" ;;
	*)   echo "Stoping weblogic Admin Server ..."
	    su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} stopAdmin >> ${LOG} 2>&1" ;;
	esac
	echo "Stoping weblogic Node Manager ..."
	su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} ${PROPS_FILE} stopNode >> ${LOG} 2>&1"
    ;;
'status')
  echo "Etat des serveurs Weblogic "
  su ${EXECUSER} -c "${WLSTCMD} ${PYSCRIPT} status|grep \"Le serveur \" "
  ;;
*)
        echo "Usage: $0 {start|stop|status}"
    ;;
esac
