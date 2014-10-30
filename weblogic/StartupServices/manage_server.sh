#!/bin/sh
. ${10}/server/bin/setWLSEnv.sh >/dev/null 2>&1
java -Xms256m -Xmx1024m -Dweblogic.security.SSL.ignoreHostnameVerification=true -Dweblogic.security.SSL.enforceConstraints=off -Djava.security.egd=file:///dev/urandom weblogic.WLST -i /export/scripts/weblogic/StartupServices/manage_server.py $1 $2 $3 $4 $5 $6 $7 $8 $9
exit $?

