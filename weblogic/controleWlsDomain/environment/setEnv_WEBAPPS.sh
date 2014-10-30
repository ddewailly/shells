#!/bin/bash

export INITENV=$(echo $0 |gawk -F"_" '{print $2}')
export MW_HOME=/wls/products/weblogic/jee/10.3.6.0/
export WL_HOME=${MW_HOME}/wlserver_10.3
export WLSTCMD=${WL_HOME}/common/bin/wlst.sh
export EXECUSER=wls
export SCRIPTHOME=/export/scripts/weblogic/controleWlsDomain
export DOMAINNAME=DOM_${INITENV}_WEBAPPS
export PROPS_FILE=${SCRIPTHOME}/properties/${DOMAINNAME}_$(hostname -s).properties
export PYSCRIPT=${SCRIPTHOME}/python/controleWLS.py
export SERV=$(hostname -s)
export SERVTYPE=$(echo $SERV|cut -d"-" -f2)
export SERVER_LIST="APP_"+${INITENV}+"_"+${SERV}
export CLUSTER_LIST=""
export LOG=${SCRIPTHOME}/logs/control_${DOMAINNAME}_${SERV}.log
