#!/bin/bash
export INITENV=$(echo $0|gawk -F"_" '{print $2}')
export MW_HOME=/wls/products/weblogic/forms/10.3.6.0/
export WL_HOME=${MW_HOME}/wlserver_10.3
export WLSTCMD=${WL_HOME}/common/bin/wlst.sh
export EXECUSER=wls
export SCRIPTHOME=/export/scripts/weblogic/controleWlsDomain
export DOMAINNAME=DOM_${INITENV}_FORMS
export PROPS_FILE=${SCRIPTHOME}/properties/${DOMAINNAME}_$(hostname -s).properties
export PYSCRIPT=${SCRIPTHOME}/python/controleWLS.py
export SERV=$(hostname -s)
export SERVTYPE=$(echo $SERV|gawk -F"-" '{print $2}')
export ORACLE_HOME=${MW_HOME}/Oracle_FRHome1/
export ORACLE_INSTANCE=/wls/instances/forms_$(echo $SERV | sed s/-/_/g)_${INITENV}/
case x$SERVTYPE in
        x) export SERVER_LIST="WLS_FORMS WLS_REPORTS";;
        x1) export SERVER_LIST="WLS_FORMS WLS_REPORTS";;
        x2) export SERVER_LIST="WLS_FORMS1 WLS_REPORTS1";;
        x3) export SERVER_LIST="WLS_FORMS2 WLS_REPORTS2";;
        x4) export SERVER_LIST="WLS_FORMS3 WLS_REPORTS3";;
        *) echo "too much servers please adapt the case in "$0;;
esac
export SERVER_LIST="WLS_FORMS WLS_REPORTS"
export CLUSTER_LIST=""
export LOG=${SCRIPTHOME}/logs/control_${DOMAINNAME}_${SERV}.log

