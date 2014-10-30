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
#               ##############################
export VERSION="1.5.3.5                       "
export BUILD_DATE="16th June 2014                "
#                  ##############################

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
	echo "## 1.1.1      26/02/2014   Added check to see if Account specified is found and"
	echo "##                         if not display message."
	echo "##"
	echo "## 1.2        05/03/2014   Fixed the deletion of the Loop file system when using "
	echo "##                         Logical Volumes."
	echo "##"
	echo "## 1.3        06/03/2014   Add the --capture-vservers command to create just an "
	echo "##                         Asset file for all vServers in an Account"
	echo "##"
	echo "## 1.3.1      10/03/2014   Update the message to the user is the script fails to"
	echo "##                         remove the sshd config information to match the Echo"
	echo "##                         requirements"
	echo "##"
	echo "## 1.4        11/03/2014   1. vm.cfg generation modified to use standard EGBT "
	echo "##                            values during the --create-template execution."
	echo "##                         2. Enable Console respawn for templates generated from"
	echo "##                            upgraded vServers"
	echo "##                         3. -tgz parameter added to the --create-template"
	echo "##                            command. This allows the user to specify a tgz"
	echo "##                            that will be extracted to the root of the System.img"
	echo "##                            in the template. It assumes the tgz has the correct"
	echo "##                            directory structure."
	echo "##"
	echo "## 1.5        26/03/2014   Added img type check to the Create Template "
	echo "##                         functionality. Prior to attempting to unconfigure the"
	echo "##                         copied image it will validate it is the ecpected type"
	echo "##                         i.e. ext3 or lvm. If we find a lvm image and the -lvm"
	echo "##                         parameter has not been passed it will report an error"
	echo "##                         similarly if -lvm is specified and ext3 is found an"
	echo "##                         error is reported."
	echo "##                         Identification of the root disk has been changed to use"
	echo "##                         the hda device whilst the copy from a none standard "
	echo "##                         repository has been improved."
	echo "##"
	echo "## 1.5.1      27/03/2014   Added Zero Fill function to fill all spare space in the"
	echo "##                         System.img file with 0. This allows for a smaller .tgz"
	echo "##"
	echo "## 1.5.1.1    28/03/2014   Allow password to be specified using an input file (-pf)"
	echo "##"
	echo "## 1.5.1.2    01/04/2014   Fix vServer name output issue for capture vServers"
	echo "##                         command and resolve the deleting of the password file"
	echo "##                         specified by -pf"
	echo "##"
	echo "## 1.5.2.0    06/04/2014   1. Add validation to create template functionality to "
	echo "##                            check if more than 1 vm.cfg exists with the vServer"
	echo "##                            name specified. If so stop because we don't know"
	echo "##                            which to use"
	echo "##                         2. Identify the version of the IaaS that is being used"
	echo "##                            and then use the appropriate version of the IaaS cli"
	echo "##                            commands."
	echo "##                         3. Add -snapshot flag for creating templates. This"
	echo "##                            allows the user to specify a snapshot that will be"
	echo "##                            used as the source for the img files."
	echo "##"
	echo "## 1.5.3.0     08/05/2014  Modify the create vServer functionality so that it "
	echo "##                         defaults to creating without a ssh key for Echo IaaS"
	echo "##"
	echo "## 1.5.3.1     30/05/2014  Fix the network display issue when using --list-vservers "
	echo "##                         with the -to-hrf flag."
	echo "##"
	echo "## 1.5.3.2     03/06/2014  Fix issue with --capture-vserver where the remote file "
	echo "##                         location was wrong. In addition is the -cip is not"
	echo "##                         specified we run the createTemplate locally assuming the"
	echo "##                         ExalogicRepository is mounted locally."
	echo "##"
	echo "## 1.5.3.3     04/06/2014  Fix the bug with the call to getDistributionGroupId in the "
	echo "##                         createVServer function where it had accidentally been"
	echo "##                         commented out. Also added filler string to the createAsset"
	echo "##                         to allow it to work with old asset files that do not"
	echo "##                         the additional information."
	echo "##"
	echo "## 1.5.3.4     07/06/2014  Fix issue identifying disk type when image mounted on "
	echo "##                         a loop other then loop0"
	echo "##"
	echo "## 1.5.3.5     16/06/2014  Fix issue looping through Network IDs in capture vserver "
	echo "##                         which was accidentially introduced in a previous update."
	echo "##"
	echo "####################################################################################"
	echo ""
	echo ""
	echo ""

}

IFS=$' \t\n'

if [[ "$OCCLI" == "" ]]
then
	export OCCLI=/opt/sun/occli/bin
fi
if [[ "$IAAS_HOME" == "" ]]
then
	export IAAS_HOME=/opt/oracle/iaas/cli
fi
if [[ "$IAAS_BASE_URL" == "" ]]
then
	export IAAS_BASE_URL=https://localhost
fi
export BASE_IAAS_ACCESS_KEY_FILE=iaas_access.key
export BASE_KEY_NAME=cli.asset.create
export BASE_KEY_FILE=iaas_access.pub
export RUN_DATE=`date +"%Y%m%d-%H%M"`"."$$
#export RUN_DATE=$$
#CloudUser used to create vServers & Volumes
if [[ "$IAAS_USER" == "" ]]
then
	export IAAS_USER=CloudUser
fi
export IAAS_PASSWORD_FILE=.iaas.pwd.$$
#export ASSET_FILE=CreateAssets.$$.in

WAIT_INTERVAL=45
ERROR_PREFIX="ERROR:"
WARNING_PREFIX="WARNING:"
INFO_PREFIX="INFO:"
CMD_MSG="About to Execute :"
LOG_FILE="SimpleExaCli.$RUN_DATE.log"

trap 'cleanAndExit' 2


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
	echo "##      Version    : $VERSION                                     ##"
	echo "##      Build Date : $BUILD_DATE                                     ##"
#	echo "##      History    : Use SimpleExaCli.sh --show-version                                 ##"
	echo "##      History    : Use SimpleExaCli.sh --show-history                                 ##"
	echo "##                                                                                      ##"
	echo "##########################################################################################"
	echo ""
	echo ""
	echo ""
}

export NAVSTAR_IAAS_RPM="orcl-sysman-iaas-cli-12.1.0-1629"
export ECHO_IAAS_RPM="orcl-sysman-iaas-cli-12.1.4-2326"
export NAVSTAR_IAAS_VERSION=12.1.0
export ECHO_IAAS_VERSION=12.1.4

function identifyInstalledIaaS() {
	# Check for version of IaaS cli installed
	ECHO_IAAS=false
	INSTALLED_IAAS=( $(rpm -qa | grep orcl-sysman-iaas-cli-) )
	if [[ "$INSTALLED_IAAS" != "" ]]
	then
#		if [[ "$INSTALLED_IAAS" == "$ECHO_IAAS_RPM" ]]
#		then
#			echo "Found Echo IaaS rpms. We will use Echo version of the commands"
#			ECHO_IAAS=true
#		elif [[ "$INSTALLED_IAAS" == "$NAVSTAR_IAAS_RPM" ]]
#		then
#			echo "Found Navstar IaaS rpms. We will use Navstar version of the commands"
#		else
#			echo "Unknown IaaS rpm version. We will use Navstar version of the commands"
#			echo "$INSTALLED_IAAS"
#		fi
		INSTALLED_IAAS_VERSION=( $(rpm -q --qf "%{VERSION}\n" $INSTALLED_IAAS) )
		if (( $(echo "$INSTALLED_IAAS_VERSION $ECHO_IAAS_VERSION" | awk '{print ($1 >= $2)}') == 1 ))
		then
			echo "Found Echo IaaS rpms. We will use Echo version of the commands"
			ECHO_IAAS=true
		elif (( $(echo "$INSTALLED_IAAS_VERSION $NAVSTAR_IAAS_VERSION" | awk '{print ($1 >= $2)}') == 1 ))
		then
			echo "Found Navstar IaaS rpms. We will use Navstar version of the commands"
		else
			echo "Unknown IaaS rpm version. We will use Navstar version of the commands"
			echo "$INSTALLED_IAAS"
		fi
	else
		echo "IaaS rpms are not installed"
	fi
	echo ""
	echo ""
}


function testCli() {
    echo "Testing CLI Connection"
    $IAAS_HOME/bin/akm-describe-accounts --sep "|"
#    if [[ "$DEBUG" == "true" ]]; then $IAAS_HOME/bin/akm-describe-accounts -H --sep "|"; fi
    [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/akm-describe-accounts -H --sep "|" && echo ""
}

function getAccounts() {
	IFS=$'\n' accountsArray=( $($IAAS_HOME/bin/akm-describe-accounts --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/akm-describe-accounts -H --sep "|" && echo ""
}

function getVServers() {
	IFS=$'\n' vserversArray=( $($IAAS_HOME/bin/iaas-describe-vservers --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-vservers -H --sep "|" && echo ""
}

function getNetworks() {
	IFS=$'\n' vnetsArray=( $($IAAS_HOME/bin/iaas-describe-vnets --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-vnets -H --sep "|" && echo ""
}

function getDistributionGroups() {
	IFS=$'\n' distGrpsArray=( $($IAAS_HOME/bin/iaas-describe-distribution-groups --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-distribution-groups -H --sep "|" && echo ""
}

function getTemplates() {
	IFS=$'\n' templatesArray=( $($IAAS_HOME/bin/iaas-describe-server-templates --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-server-templates -H --sep "|" && echo ""
}

function getVolumes() {
	IFS=$'\n' volumesArray=( $($IAAS_HOME/bin/iaas-describe-volumes --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-volumes -H --sep "|" && echo ""
}

function getVSTypes() {
	IFS=$'\n' vsTypesArray=( $($IAAS_HOME/bin/iaas-describe-vserver-types --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-vserver-types -H --sep "|" && echo ""
}

function getNetworkStaticIPs() {
	IFS=$'\n' staticIPsArray=( $($IAAS_HOME/bin/iaas-describe-ip-addresses --filters vnet=$NETWORK_ID --sep "|" | sed 's/ /_/g') )
  [ "$DEBUG" == "true" ] && $IAAS_HOME/bin/iaas-describe-ip-addresses --filters vnet=$NETWORK_ID -H --sep "|" && echo ""
  [ "$DEBUG" == "true" ] && echo "${staticIPsArray[@]}"
}

function connectToAccount() {
	# Set run specific key information
	export IAAS_ACCESS_KEY_FILE="$(pwd)/$ACCOUNT_NAME.$RUN_DATE.$BASE_IAAS_ACCESS_KEY_FILE"
	export KEY_NAME="$(pwd)/$ACCOUNT_NAME.$RUN_DATE.$BASE_KEY_NAME"
	export KEY_FILE="$(pwd)/$ACCOUNT_NAME.$RUN_DATE.$BASE_KEY_FILE"
	#echo "IAAS_ACCESS_KEY_FILE=$IAAS_ACCESS_KEY_FILE"
	#echo "KEY_NAME=$KEY_NAME"
	#echo "KEY_FILE=$KEY_FILE"
	#echo "Found Account $line"
	AK=`$IAAS_HOME/bin/akm-create-access-key --account $ACCOUNT_ID --access-key-file $IAAS_ACCESS_KEY_FILE`
	KEYPAIR=`$IAAS_HOME/bin/iaas-create-key-pair --key-name $KEY_NAME --key-file $KEY_FILE`
	#echo "Connected to $ACCOUNT_NAME"
}

function disconnectFromAccount() {
        $IAAS_HOME/bin/iaas-delete-key-pair --key-name $KEY_NAME --access-key-file $IAAS_ACCESS_KEY_FILE
        $IAAS_HOME/bin/akm-delete-access-key $AK
        if [[ "$KEEP_PUB_KEY" == "" ]]
        then
            rm -f $KEY_FILE
        fi
        rm -f $IAAS_ACCESS_KEY_FILE
}

function cleanAndExit() {
  KEEP_PUB_KEY=""
  disconnectFromAccount
  if [[ "$PASSWORD_FILE" == "" ]]
	then
    rm -f $IAAS_PASSWORD_FILE
  fi
  echo "*************************************************************"
  echo "** $0 Exiting."
  echo "*************************************************************"
  
  exit 1
}

#############################################################
##
## stopVServer
## ===========
##
## Find and stop a vServer.
##
#############################################################

function stopVServer() {
#	echo "Stopping vServer $VSERVER_NAME"
	getVServers
	getVServerId
	echo "Stopping vServer $VSERVER_NAME $VSERVER_ID"
	$IAAS_HOME/bin/iaas-stop-vservers --vserver-ids $VSERVER_ID --force
	pauseUntilVServerShutdown
}

#############################################################
##
## startVServer
## ============
##
## Find and stop a vServer.
##
#############################################################

function startVServer() {
#	echo "Starting vServer $VSERVER_NAME"
	getVServers
	getVServerId
	echo "Starting vServer $VSERVER_NAME ($VSERVER_ID)"
	$IAAS_HOME/bin/iaas-start-vservers --vserver-ids $VSERVER_ID
	pauseUntilVServerRunning
}

#############################################################
##
## deleteVServer
## =============
##
## Find and delete a vServer.
##
#############################################################

function deleteVServer() {
#	echo "Deleting vServer $VSERVER_NAME"
	getVServers
	getVServerId
	echo "Deleting vServer $VSERVER_NAME $VSERVER_ID"
	$IAAS_HOME/bin/iaas-terminate-vservers --force --vserver-ids $VSERVER_ID
}

#############################################################
##
## stopVServers
## ============
##
## Stop one or more vServers running within the currently
## connected Account. If a specific vServer Name is passed in
## $VSERVER as specified on the command line using -v then 
## this will be the one stopped. If no VSERVER is specified
## then all vServers in the Account will be stopped.
##
#############################################################

function stopVServers() {
	getVServers
	VSERVER_IDS=""
	VSERVER_NAMES=""
	for vserver in "${vserversArray[@]}"
	do
		VSERVER_ID=${vserver%%|*}
		vserver=${vserver#*|}
		VSERVER_NAME=${vserver%%|*}
		if [[ "$VSERVER" == "" || "$VSERVER" == "$VSERVER_NAME" ]]
		then
			if [[ "$VSERVER_IDS" == "" ]]
			then
				VSERVER_IDS=$VSERVER_ID
				VSERVER_NAMES=$VSERVER_NAME
			else
				VSERVER_IDS=$VSERVER_IDS","$VSERVER_ID
				VSERVER_NAMES=$VSERVER_NAMES","$VSERVER_NAME
			fi
		fi
	done
	if [[ "$VSERVER_IDS" != "" ]]
	then
		echo "Stopping vServer(s) [$VSERVER_NAMES] [$VSERVER_IDS]"
		$IAAS_HOME/bin/iaas-stop-vservers --vserver-ids $VSERVER_IDS --force
	else
		echo "No vServers to stop"
	fi
}

#############################################################
##
## startVServers
## =============
##
## Start one or more vServers stopped within the currently
## connected Account. If a specific vServer Name is passed in
## $VSERVER as specified on the command line using -v then 
## this will be the one started. If no VSERVER is specified
## then all vServers in the Account will be started.
##
#############################################################

function startVServers() {
	getVServers
	VSERVER_IDS=""
	VSERVER_NAMES=""
	for vserver in "${vserversArray[@]}"
	do
		VSERVER_ID=${vserver%%|*}
		vserver=${vserver#*|}
		VSERVER_NAME=${vserver%%|*}
		if [[ "$VSERVER" == "" || "$VSERVER" == "$VSERVER_NAME" ]]
		then
			if [[ "$VSERVER_IDS" == "" ]]
			then
				VSERVER_IDS=$VSERVER_ID
				VSERVER_NAMES=$VSERVER_NAME
			else
				VSERVER_IDS=$VSERVER_IDS","$VSERVER_ID
				VSERVER_NAMES=$VSERVER_NAMES","$VSERVER_NAME
			fi
		fi
	done
	if [[ "$VSERVER_IDS" != "" ]]
	then
		echo "Starting vServer(s) [$VSERVER_NAMES] [$VSERVER_IDS]"
		$IAAS_HOME/bin/iaas-start-vservers --vserver-ids $VSERVER_IDS
	else
		echo "No vServers to start"
	fi
}

#############################################################
##
## rebootVServers
## ==============
##
## Reboot one or more vServers stopped within the currently
## connected Account. If a specific vServer Name is passed in
## $VSERVER as specified on the command line using -v then 
## this will be the one started. If no VSERVER is specified
## then all vServers in the Account will be started.
##
#############################################################

function rebootVServers() {
	getVServers
	VSERVER_IDS=""
	VSERVER_NAMES=""
	for vserver in "${vserversArray[@]}"
	do
		VSERVER_ID=${vserver%%|*}
		vserver=${vserver#*|}
		VSERVER_NAME=${vserver%%|*}
		if [[ "$VSERVER" == "" || "$VSERVER" == "$VSERVER_NAME" ]]
		then
			if [[ "$VSERVER_IDS" == "" ]]
			then
				VSERVER_IDS=$VSERVER_ID
				VSERVER_NAMES=$VSERVER_NAME
			else
				VSERVER_IDS=$VSERVER_IDS","$VSERVER_ID
				VSERVER_NAMES=$VSERVER_NAMES","$VSERVER_NAME
			fi
		fi
	done
	if [[ "$VSERVER_IDS" != "" ]]
	then
		echo "Rebooting vServer(s) [$VSERVER_NAMES] [$VSERVER_IDS]"
		$IAAS_HOME/bin/iaas-reboot-vservers --vserver-ids $VSERVER_IDS
	else
		echo "No vServers to reboot"
	fi
}

#############################################################
##
## listVServers
## ============
##
## List the vServers running on the specified Account is 
## the verbose flag is set then all vServer details will be 
## displayed otherwise simple the Acc and Name.
##
#############################################################

function listVServers() {
    getVServers
    for vserver in "${vserversArray[@]}"
    do
        VSERVER_ID=${vserver%%|*}
        vserver=${vserver#*|}
        VSERVER_NAME=${vserver%%|*}
        vserver=${vserver#*|}
        if [[ "$VSERVER" == "" || "$VSERVER" == "$VSERVER_NAME" ]]
        then
            if [[ "$VERBOSE" == "true" ]]
            then
                if [[ "$HRF" == "true" ]]
                then
                    DESCRIPTION=${vserver%%|*}
                    vserver=${vserver#*|}
                    STATE=${vserver%%|*}
                    vserver=${vserver#*|}
                    NETWORK_IDS=${vserver%%|*}
                    vserver=${vserver#*|}
                    NETWORK_IPS=${vserver%%|*}
                    vserver=${vserver#*|}
                    TEMPLATE_ID=${vserver%%|*}
                    vserver=${vserver#*|}
                    SSH_KEY=${vserver%%|*}
                    vserver=${vserver#*|}
                    VSTYPE_ID=${vserver%%|*}
                    vserver=${vserver#*|}
                    getNetworks
                    getTemplates
                    getVSTypes
                    # Get VServer Type Name
                    getVSTypeName
                    # Get Template Type Name
                    getTemplateName
                    echo "$ACCOUNT_NAME|$VSERVER_NAME|$VSERVER_ID"
                    echo "     Name        : $VSERVER_NAME"
                    echo "     Description : "$(echo $DESCRIPTION | sed 's/_/ /g')
                    echo "     State       : $STATE"
                    IFS=',' networkIdArray=( $(echo "$NETWORK_IDS" | sed 's/ //g') )
                    #for NETWORK_ID in ${NETWORK_IDS//,/ }
                    for NETWORK_ID in "${networkIdArray[@]}"
                    do
                        NETWORK_IP=${NETWORK_IPS%%,*}
                        NETWORK_IPS=${NETWORK_IPS#*,}
                        getNetworkName
                        echo "     Network     : $NETWORK_NAME ($NETWORK_IP) [$NETWORK_ID]"
                    done
                    echo "     Template    : $TEMPLATE_NAME [$TEMPLATE_ID]"
                    echo "     Server Type : $VSTYPE_NAME [$VSTYPE_ID]"
                else
                    echo "$ACCOUNT_NAME|$VSERVER_NAME|$VSERVER_ID|"$(echo $vserver | sed 's/_/ /g')
                fi
            else
                echo "$ACCOUNT_NAME|$VSERVER_NAME"
            fi
        fi
    done
}

#############################################################
##
## listVServerStatus
## =================
##
## List the Status of the vServers within an Account.
##
#############################################################

function listVServerStatus() {
	getVServers
	for vserver in "${vserversArray[@]}"
	do
		VSERVER_ID=${vserver%%|*}
		vserver=${vserver#*|}
		VSERVER_NAME=${vserver%%|*}
		vserver=${vserver#*|}
		VSERVER_DESC=${vserver%%|*}
		vserver=${vserver#*|}
		VSERVER_STATUS=${vserver%%|*}
		if [[ "$VSERVER" == "" || "$VSERVER" == "$VSERVER_NAME" ]]
		then
			echo "$ACCOUNT_NAME|$VSERVER_NAME|$VSERVER_STATUS"
		fi
	done
}

#############################################################
##
## listVNets
## =========
##
## List the Networks within an Account.
##
#############################################################

function listVNets() {
	getNetworks
	for vnet in "${vnetsArray[@]}"
	do
		VNET_ID=${vnet%%|*}
		vnet=${vnet#*|}
		VNET_NAME=${vnet%%|*}
		vnet=${vnet#*|}
		if [[ "$VERBOSE" == "true" ]]
		then
			echo "$ACCOUNT_NAME|$VNET_NAME|$VNET_ID|"$(echo $vnet | sed 's/_/ /g')
		else
			VNET_DESC=${vnet%%|*}
			vnet=${vnet#*|}
			VNET_STATUS=${vnet%%|*}
			vnet=${vnet#*|}
			VNET_IP=${vnet%%|*}
			echo "$ACCOUNT_NAME|$VNET_NAME|$VNET_IP"
		fi
	done
}

#############################################################
##
## listDistributionGroups
## ======================
##
## List the Distribution Groups within an Account.
##
#############################################################

function listDistributionGroups() {
	getDistributionGroups
	for distGrp in "${distGrpsArray[@]}"
	do
		DG_ID=${distGrp%%|*}
		distGrp=${distGrp#*|}
		DG_NAME=${distGrp%%|*}
		distGrp=${distGrp#*|}
		if [[ "$VERBOSE" == "true" ]]
		then
			echo "$ACCOUNT_NAME|$DG_NAME|$DG_ID|"$(echo $distGrp | sed 's/_/ /g')
		else
			DG_DESC=${distGrp%%|*}
			distGrp=${distGrp#*|}
			DG_STATUS=${distGrp%%|*}
			echo "$ACCOUNT_NAME|$DG_NAME|$VNET_IP"
		fi
	done
}

#############################################################
##
## listTemplates
## =============
##
## List the Templates within an Account.
##
#############################################################

function listTemplates() {
	getTemplates
	for template in "${templatesArray[@]}"
	do
		TEMPLATE_ID=${template%%|*}
		template=${template#*|}
		TEMPLATE_NAME=${template%%|*}
		template=${template#*|}
		if [[ "$VERBOSE" == "true" ]]
		then
			echo "$ACCOUNT_NAME|$TEMPLATE_NAME|$TEMPLATE_ID|"$(echo $template | sed 's/_/ /g')
		else
			TEMPLATE_DESC=${template%%|*}
			template=${template#*|}
			TEMPLATE_STATUS=${template%%|*}
			echo "$ACCOUNT_NAME|$TEMPLATE_NAME"
		fi
	done
}

#############################################################
##
## listVolumes
## ===========
##
## List the Volumes within an Account.
##
#############################################################

function listVolumes() {
	getVolumes
	for volume in "${volumesArray[@]}"
	do
		VOLUME_ID=${volume%%|*}
		volume=${volume#*|}
		VOLUME_NAME=${volume%%|*}
		volume=${volume#*|}
		if [[ "$VERBOSE" == "true" ]]
		then
			echo "$ACCOUNT_NAME|$VOLUME_NAME|$VOLUME_ID|"$(echo $volume | sed 's/_/ /g')
		else
			VOLUME_DESC=${volume%%|*}
			volume=${volume#*|}
			VOLUME_STATUS=${volume%%|*}
			volume=${volume#*|}
			VOLUME_SIZE=${volume%%|*}
			echo "$ACCOUNT_NAME|$VOLUME_NAME|$VOLUME_SIZE"
		fi
	done
}

#############################################################
##
## getAccountId
## ============
##
## Get the Account id based on the supplied name.
##
#############################################################

function getAccountId() {
echo $accountArray
    for account in "${accountsArray[@]}"
    do
        ACCOUNT_ID=${account%%|*}
        account=${account#*|}
        ACCOUNT_NAME=${account%%|*}
        if [[ "$ACCOUNT" == "$ACCOUNT_NAME" && "$ACCOUNT_ID" == ACC-* ]]
        then
            break
        fi
        ACCOUNT_ID=""
    done
}

#############################################################
##
## getDistributionGroupId
## ======================
##
## Get the Distribution Group id based on the supplied name.
##
#############################################################

function getDistributionGroupId() {
    for line in "${distGrpsArray[@]}"
    do
            DISTGROUP_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            if [[ "$NAME" == "$DISTGROUP_NAME" ]]
            then
                    break
            fi
            DISTGROUP_ID=""
    done
}

#############################################################
##
## getDistributionGroupName
## ========================
##
## Gets the name of a Distribution Group based on the Id.
##
#############################################################

function getDistributionGroupName() {
    DISTGROUP_NAME=""
    for line in "${distGrpsArray[@]}"
    do
        ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        if [[ "$ID" == "$DISTGROUP_ID" ]]
        then
            DISTGROUP_NAME=$NAME
            break
        fi
    done 
}

#############################################################
##
## getIPAddress
## ============
##
## Get a static IP Address for a given network if a * or + is 
## supplied. If an IP Address is supplied it simple returns
## specified IP.
##
#############################################################

function getIPAddress() {
    echo "Checking IP Address $IP_ADDRESS"
    IP_AVAILABLE=""
    if [[ "$IP_ADDRESS" == "*" || "$IP_ADDRESS" == "+" ]]
    then
            allocateIPAddress
    fi
    getNetworkStaticIPs
    for line in "${staticIPsArray[@]}"
    do
    	[ "$DEBUG" == "true" ] && echo "(line = $line)"
        IP=${line%%|*}
        if [[ "$IP" == "$IP_ADDRESS" ]]
        then
            IP_AVAILABLE="true"
        fi
    done
    [ "$DEBUG" == "true" ] && echo "IP_AVAILABLE = $IP_AVAILABLE"
    if [[ "$IP_AVAILABLE" == "" ]]
    then
        echo "$WARNING_PREFIX IP Address $IP_ADDRESS is not available for static allocation"
        IP_ADDRESS=""
        FAILED="true"
    fi
    #echo "Returning IP Address $IP_ADDRESS"
}

#############################################################
##
## allocateIPAddress
## =================
##
## Allocate a single IP Address from a specified Network.
##
#############################################################

function allocateIPAddress() {
	echo "Allocating IP Address"
    if [[ "$NETWORK_ID" == VNET-* ]]
    then
#        IP_ADDRESS=`$IAAS_HOME/bin/iaas-allocate-ip-addresses --vnet $NETWORK_ID --num 1`
        IP_ADDRESS=$($IAAS_HOME/bin/iaas-allocate-ip-addresses --vnet $NETWORK_ID --num 1)
    else
        echo "$WARNING_PREFIX Network Id \"$NETWORK_ID\" is not valid."
    fi
  echo "Allocated IP Address ($IP_ADDRESS)"  
}
#############################################################
##
## getNetworkId
## ============
##
## Get the Network id based on the supplied name.
##
#############################################################

function getNetworkId() {
    NETWORK_ID=""
    for line in "${vnetsArray[@]}"
    do
            NETWORK_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            if [[ "$NAME" == "$NETWORK_NAME" ]]
            then
                    break
            fi
            NETWORK_ID=""
    done
    if [[ "$NETWORK_ID" == "" ]]
    then
        echo "$WARNING_PREFIX Network with name $NETWORK_NAME has not been found"
        FAILED="true"
    fi
}

#############################################################
##
## getNetworkName
## ==============
##
## Gets the name of a network based on the Id.
##
#############################################################

function getNetworkName() {
    NETWORK_NAME=""
    for line in "${vnetsArray[@]}"
    do
        ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        if [[ "$ID" == "$NETWORK_ID" ]]
        then
            NETWORK_NAME=$NAME
            break
        fi
    done
}

#############################################################
##
## getVNetworkState
## ================
##
## Loop through the Networks associated with the Account 
## checking to see if the creation has completed and the 
## network has a status of OK. At this point return.
##
#############################################################

function getVNetworkState() {
    getNetworks
    for line in "${vnetsArray[@]}"
    do
            NETWORK_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            line=${line#*|}
            line=${line#*|}
            NETWORK_STATE=${line%%|*}
            if [[ "$NETWORK_NAME" == "$NAME" ]]
            then
                    break;
            fi
    done
}

#############################################################
##
## getTemplateId
## =============
##
## Get the Template id based on the supplied name.
##
#############################################################

function getTemplateId() {
    TEMPLATE_ID=""
    for line in "${templatesArray[@]}"
    do
            TEMPLATE_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            if [[ "$TEMPLATE_NAME" == "$NAME" ]]
            then
                    break
            fi
            TEMPLATE_ID=""
    done
    if [[ "$TEMPLATE_ID" == "" ]]
    then
        echo "$WARNING_PREFIX Template with name $TEMPLATE_NAME has not been found"
        FAILED="true"
    fi
}

#############################################################
##
## getTemplateState
## ================
##
## Loop through the Template associated with the Account 
## checking to see if the upload has completed and the 
## template has a status of OK. At this point return.
##
#############################################################

function getTemplateState() {
    getTemplates
    for line in "${templatesArray[@]}"
    do
        TEMPLATE_ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        line=${line#*|}
        line=${line#*|}
        TEMPLATE_STATE=${line%%|*}
        if [[ "$TEMPLATE_NAME" == "$NAME" ]]
        then
                break;
        fi
    done
}

#############################################################
##
## getTemplateName
## ===============
##
## Gets the name of a Template based on the Id.
##
#############################################################

function getTemplateName() {
    TEMPLATE_NAME=""
    for line in "${templatesArray[@]}"
    do
        ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        if [[ "$ID" == "$TEMPLATE_ID" ]]
        then
            TEMPLATE_NAME=$NAME
            break
        fi
    done 
}

#############################################################
##
## getVolumeId
## ===========
##
## Get the Volume id based on the supplied name.
##
#############################################################

function getVolumeId() {
    VOLUME_ID=""
    for line in "${volumesArray[@]}"
    do
            VOLUME_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            if [[ "$NAME" == "$VOLUME_NAME" ]]
            then
                    break;
            fi
            VOLUME_ID=""
    done 
    if [[ "$VOLUME_ID" == "" ]]
    then
        echo "$WARNING_PREFIX Volume with name $VOLUME_NAME has not been found"
        FAILED="true"
    fi
}

#############################################################
##
## getVServerId
## ============
##
## Get the VServer id based on the supplied name.
##
#############################################################

function getVServerId() {
    VSERVER_ID=""
    for line in "${vserversArray[@]}"
    do
            VSERVER_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            if [[ "$VSERVER_NAME" == "$NAME" ]]
            then
                    break;
            fi
            VSERVER_ID=""
    done 
    if [[ "$VSERVER_ID" == "" ]]
    then
        echo "$WARNING_PREFIX VServer with name $VSERVER_NAME has not been found"
        FAILED="true"
    fi
}

#############################################################
##
## getVServerState
## ===============
##
## Get the VServer running state based on the supplied name.
##
#############################################################

function getVServerState() {
    getVServers
    for line in "${vserversArray[@]}"
    do
            VSERVER_ID=${line%%|*}
            line=${line#*|}
            NAME=${line%%|*}
            line=${line#*|}
            DESCRIPTION=${line%%|*}
            line=${line#*|}
            VSERVER_STATE=${line%%|*}
            if [[ "$VSERVER_NAME" == "$NAME" ]]
            then
                    break;
            fi
    done 
}

#############################################################
##
## getVSTypeId
## ===========
##
## Get the VServer Type id based on the supplied name.
##
#############################################################

function getVSTypeId() {
    VSTYPE_ID=""
    for line in "${vsTypesArray[@]}"
    do
        VSTYPE_ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        if [[ "$VSTYPE_NAME" == "$NAME" ]]
        then
            break
        fi
        VSTYPE_ID=""
    done
    if [[ "$VSTYPE_ID" == "" ]]
    then
        echo "$WARNING_PREFIX VServer Type with name $VSTYPE_NAME has not been found"
        FAILED="true"
    fi
}

#############################################################
##
## getVSTypeName
## =============
##
## Gets the name of a vServer Type based on the Id.
##
#############################################################

function getVSTypeName() {
    VSTYPE_NAME=""
    for line in "${vsTypesArray[@]}"
    do
        ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        if [[ "$ID" == "$VSTYPE_ID" ]]
        then
            VSTYPE_NAME=$NAME
            break
        fi
    done 
}

#############################################################
##
## createDistributionGroup
## =======================
##
## Create a Distribution Group based on the supplied details.
##
#############################################################

function createDistributionGroup() {
    # Create Distribution Group
#    echo "About to execute : $IAAS_HOME/bin/iaas-create-distribution-group --name $DISTGROUP_NAME"
#    $IAAS_HOME/bin/iaas-create-distribution-group --name $DISTGROUP_NAME
    CMD="$IAAS_HOME/bin/iaas-create-distribution-group --name $DISTGROUP_NAME"
    
    if [[ "$ECHO_IAAS" == "true" ]]
    then
    	if [[ "$DISTGROUP_SIZE" != "" ]]
    	then
    		CMD+=" --size $DISTGROUP_SIZE"
    	fi
    fi

    #*******************************************
    echo "$CMD_MSG $CMD"
    echo "$CMD_MSG $CMD" >> $LOG_FILE
    IFS=$'\n' RESULT=( $(eval $CMD) )
    unset IFS
    echo "Command Result : $RESULT" >> $LOG_FILE
    #*******************************************

    # Lets pause
    pauseUntilDistributionGroupCreated
}

#############################################################
##
## pauseUntilDistributionGroupCreated
## ==================================
##
## Pause the script until the Distribution Group has been created.
##
#############################################################

function pauseUntilDistributionGroupCreated() {
    getDistributionGroups
    getDistributionGroupId
    while [[ "$DISTGROUP_ID" == "" ]]
    do
        # Lets pause
        echo "Just Waiting $WAIT_INTERVAL Seconds......"
        sleep $WAIT_INTERVAL
        getDistributionGroups
        getDistributionGroupId
    done
}

#############################################################
##
## createVirtualNetwork
## ====================
##
## Create a Virtual Private Network based on the name 
## supplied.
##
#############################################################

function createVirtualNetwork() {
    # 
#    echo "About to execute : $IAAS_HOME/bin/iaas-create-vnet --name $NETWORK_NAME --size $NETWORK_IPS "
#    $IAAS_HOME/bin/iaas-create-vnet --name $NETWORK_NAME --size $NETWORK_IPS
    CMD="$IAAS_HOME/bin/iaas-create-vnet --name $NETWORK_NAME --size $NETWORK_IPS"

    #*******************************************
    echo "$CMD_MSG $CMD"
    echo "$CMD_MSG $CMD" >> $LOG_FILE
    IFS=$'\n' RESULT=( $(eval $CMD) )
    unset IFS
    echo "Command Result : $RESULT" >> $LOG_FILE
    #*******************************************

  # Lets pause
    pauseUntilVirtualNetworkCreated
}

#############################################################
##
## pauseUntilVirtualNetworkCreated
## ===============================
##
## Pause the script until the Virtual Private Network has
## been created.
##
#############################################################

function pauseUntilVirtualNetworkCreated() {
    echo "Pausing until Virtual Network creation has completed"
    getVNetworkState
    while [[ "$NETWORK_STATE" != "OK" ]]
    do
        echo "$NAME $NETWORK_STATE"
        if [[ "$NETWORK_STATE" != "SCHEDULED" ]]
        then
                echo "Sleeping......."
                sleep $WAIT_INTERVAL
        elif [[ "$NETWORK_STATE" != "RUNNING" ]]
        then
                echo "Sleeping......."
                sleep $WAIT_INTERVAL
        fi
        getVNetworkState
    done
}

#############################################################
##
## createVolume
## ============
##
## Create a Volume based on the supplied details.
##
#############################################################

function createVolume() {
    # Create Volume
#    echo "About to execute : $IAAS_HOME/bin/iaas-create-volume --name $VOLUME_NAME --size $VOLUME_SIZE"
#    $IAAS_HOME/bin/iaas-create-volume --name $VOLUME_NAME --size $VOLUME_SIZE
    CMD="$IAAS_HOME/bin/iaas-create-volume --name $VOLUME_NAME --size $VOLUME_SIZE"

    #*******************************************
    echo "$CMD_MSG $CMD"
    echo "$CMD_MSG $CMD" >> $LOG_FILE
    IFS=$'\n' RESULT=( $(eval $CMD) )
    unset IFS
    echo "Command Result : $RESULT" >> $LOG_FILE
    #*******************************************

  # Lets pause
  pauseUntilVolumeCreated
}

#############################################################
##
## pauseUntilVolumeCreated
## =======================
##
## Pause the script until the Volume has been created.
##
#############################################################

function pauseUntilVolumeCreated() {
    getVolumes
    getVolumeId
    while [[ "$VOLUME_ID" == "" ]]
    do
        # Lets pause
        echo "Just Waiting $WAIT_INTERVAL Seconds......"
        sleep $WAIT_INTERVAL
        getVolumes
        getVolumeId
    done
}

#############################################################
##
## createVServer
## =============
##
## Create a vServer based on the supplied details.
##
#############################################################

function createVServer() {
    echo "Creating vServer $VSERVER_NAME"

    # Get Ids associated with names
    getVSTypeId
    getTemplateId
    # Convert Network Names to Ids
    NETWORK_IDS=""
    # Validated IPs
    NETWORK_IPS=""
    # Reset FAILED
    FAILED=""
    IFS=',' networkNamesArray=( $(echo "$NETWORK_NAMES" | sed 's/ //g') )
    IFS=',' IPAddressesArray=( $(echo "$IP_ADDRESSES" | sed 's/ //g' | sed 's/*/+/g') )
    [ "$DEBUG" == "true" ] && echo "IP_ADDRESSES = $IP_ADDRESSES"
		[ "$DEBUG" == "true" ] && echo "IPAddressesArray = ${IPAddressesArray[@]}"
#    for NETWORK_NAME in "${networkNamesArray[@]}"
    for arrayIndex in "${!networkNamesArray[@]}"
    do
            # Get ID and add to list
            NETWORK_NAME=${networkNamesArray[arrayIndex]}
						[ "$DEBUG" == "true" ] && echo "[$arrayIndex] NETWORK_NAME = $NETWORK_NAME"
            getNetworkId
            if [[ "$NETWORK_IDS" != "" ]]
            then
                    NETWORK_IDS="$NETWORK_IDS,$NETWORK_ID"
            else
                    NETWORK_IDS=$NETWORK_ID
            fi
            # Check IPs
            IP_ADDRESS=${IPAddressesArray[arrayIndex]}
						[ "$DEBUG" == "true" ] && echo "[$arrayIndex] IP_ADDRESS = $IP_ADDRESS"
            getIPAddress
            if [[ "$NETWORK_IPS" != "" ]]
            then
                    NETWORK_IPS="$NETWORK_IPS,$IP_ADDRESS"
            else
                    NETWORK_IPS=$IP_ADDRESS
            fi
    done
		
		getDistributionGroupId

    if [[ "$DESCRIPTION" == "" ]]
    then
        DESCRIPTION="Created by $0"
    fi

    if [[ "$FAILED" == "true" || "$VSTYPE_ID" == "" || "$TEMPLATE_ID" == "" || "$NETWORK_IDS" == "" ]]
    then
        echo ""
        echo "$ERROR_PREFIX Unable to create vServer due to missing information. Please check \"$WARNING_PREFIX\" messages for missing information."
        echo ""
        cleanAndExit
    fi

#    CMD="$IAAS_HOME/bin/iaas-run-vserver --name $VSERVER_NAME --key-name $KEY_NAME --vserver-type $VSTYPE_ID --server-template-id $TEMPLATE_ID --vnets $NETWORK_IDS --ip-addresses $NETWORK_IPS --desc \"$DESCRIPTION\""
    CMD="$IAAS_HOME/bin/iaas-run-vserver --name $VSERVER_NAME --vserver-type $VSTYPE_ID --server-template-id $TEMPLATE_ID --vnets $NETWORK_IDS --ip-addresses $NETWORK_IPS --desc \"$DESCRIPTION\""
    if [[ "$ECHO_IAAS" == "false" ]]
    then
    	CMD+=" --key-name $KEY_NAME"
    fi
    if [[ "$VSERVER_HA" != "" ]]
    then
    	CMD+=" --ha $VSERVER_HA"
    fi
    if [[ "$DISTGROUP_ID" != "" ]]
    then
    	CMD+=" --dist-group $DISTGROUP_ID"
    fi
    if [[ "$ECHO_IAAS" == "true" ]]
    then
    	if [[ "$VSERVER_HOSTNAME" != "" ]]
    	then
    		CMD+=" --hostname $VSERVER_HOSTNAME"
    	fi
    	if [[ "$VSERVER_NETWORK_HOSTNAMES" != "" ]]
    	then
    		#whitespaceStripped=$(echo "$VSERVER_NETWORK_HOSTNAMES" | sed 's/[[:space]]//g')
    		IFS=',' hostnamesArray=( $(echo "$VSERVER_NETWORK_HOSTNAMES" | sed 's/ //g') )
    		hostnamePos=0
    		MESSAGES=""
    		for hostname in "${hostnamesArray[@]}"
    		do
    			if [[ "$hostnamePos" != "0" ]]
    			then
    				MESSAGES+=","
    			fi
    			echo "Hostname = $hostname"
    			MESSAGES+="com.oracle.linux.etchosts.hostname.0.$hostnamePos=\"$hostname\""
    			hostnamePos=$((hostnamePos + 1))
    		done
    		if [[ "$MESSAGES" != "" ]]
    		then
    			CMD+=" --messages $MESSAGES"
    		fi
    	fi
    fi
    
		[ "$DEBUG" == "true" ] && echo "VSERVER_HOSTNAME = $VSERVER_HOSTNAME"
		[ "$DEBUG" == "true" ] && echo "VSERVER_NETWORK_HOSTNAMES = $VSERVER_NETWORK_HOSTNAMES"
		[ "$DEBUG" == "true" ] && echo "MESSAGES = $MESSAGES"

    # Create vServer
    #*******************************************
    echo "$CMD_MSG $CMD"
    echo "$CMD_MSG $CMD" >> $LOG_FILE
    IFS=$'\n' RESULT=( $(eval $CMD) )
    unset IFS
    echo "Command Result : $RESULT" >> $LOG_FILE
    #*******************************************

    if [[ "$RESULT" == VSRV-* ]]
    then
        pauseUntilVServerRunning
		    if [[ "$ECHO_IAAS" == "false" ]]
		    then
		        if [[ "$REMOVE_SSH_KEYS" == "true" ]]
		        then
		                removeSshKeyRequirement
		        elif [[ "$POST_CREATE_SCRIPT" != "" ]]
		        then
		            injectScriptWithSshKey
		        fi
		    fi
        echo "vServer $VSERVER_NAME has been created"
    else
        echo "$WARNING_PREFIX Failed to create VServer with name $VSERVER_NAME"
        FAILED="true"        
    fi
}

#############################################################
##
## findAccessibleSshIP
## =======================
##
## Attempts to find a route to the new vServer using the ssh
## key.
##
#############################################################

function findAccessibleSshIP() {
    SSH_FLAGS="-i $KEY_FILE -o StrictHostKeyChecking=no -o UserKnownHostsFile=known.hosts"
    SSH_FLAGS="-i $KEY_FILE -o StrictHostKeyChecking=no"

    SSH_IP_ADDRESS=""
    for IP in ${NETWORK_IPS//,/ }
    do
        # Test first with expect because IP is probably not in the list of known hosts
        SSH_CMD="ssh $SSH_FLAGS -l root $IP \"hostname\""

SSH_RESULT=$((expect - << EOF
spawn ssh $SSH_FLAGS root@$IP  "hostname"
expect -re "assword" 
send "Password\r"
expect -re "~]#" 
send "hostname\r\n"
set timeout 15
EOF
) | while read line; do if [[ "$line" == *"$VSERVER_NAME"* ]]; then echo $VSERVER_NAME; fi; done)

        if [[ "$SSH_RESULT" == "$VSERVER_NAME" ]]
        then
            echo "$IP Address works for ssh to $VSERVER_NAME"
        else

SSH_RESULT=$((expect - << EOF
spawn ssh $SSH_FLAGS root@$IP  "hostname"
expect -re "assword" 
send "Password\r"
expect -re "~]#" 
send "hostname\r\n"
set timeout 15
EOF
) | while read line; do if [[ "$line" == *"$VSERVER_NAME"* ]]; then echo $VSERVER_NAME; fi; done)

        fi

        if [[ "$SSH_RESULT" == "$VSERVER_NAME" ]]
        then
                echo "$IP Address works for ssh to $VSERVER_NAME"
                SSH_IP_ADDRESS=$IP
                break;
        else
                echo "$IP Address does not work for ssh to $VSERVER_NAME"
                echo "Result : $SSH_RESULT"
        fi
    done

}

#############################################################
##
## removeSshKeyRequirement
## =======================
##
## When a vServer is created using the cli the it is set up
## with a ssh key this function will remove that requirement.
##
#############################################################

function removeSshKeyRequirement() {
    findAccessibleSshIP
    if [[ "$SSH_IP_ADDRESS" != "" ]]
    then
        if [[ "$POST_CREATE_SCRIPT" != "" ]]
        then
            injectScriptIntoVServer
        fi

        echo ""
        echo "Removing ssh key requirement for $VSERVER_NAME on $SSH_IP_ADDRESS"

        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig"
        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "sed 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config.orig > /etc/ssh/sshd_config.1"
        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "sed 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config.1 > /etc/ssh/sshd_config"
#        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "sed 's/PasswordAuthentication no/PasswordAuthentication yes/g;s/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config.orig > /etc/ssh/sshd_config"
        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "service sshd restart"

        echo "Removed ssh key requirement for $VSERVER_NAME"
    else
        echo ""
        echo "Unable to find a route to $VSERVER_NAME to remove the ssh key requirement you will need to do the following"
        echo ""
        echo "1. ssh into the vServer using: ssh -i $KEY_FILE -l root <IP Address>"
        echo "2. Edit /etc/ssh/sshd_config and replace \"PasswordAuthentication no\" with \"PasswordAuthentication yes\""
        echo "3. Edit /etc/ssh/sshd_config and replace \"PermitRootLogin without-password\" with \"PermitRootLogin yes\""
        echo "4. Restart sshd service: service sshd restart"
        echo ""
        echo "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig"
        echo "sed 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.orig > /etc/ssh/sshd_config.1"
        echo "sed 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config.1 > /etc/ssh/sshd_config"
        echo "service sshd restart"
        echo ""
        KEEP_PUB_KEY=true
        if [[ "$POST_CREATE_SCRIPT" != "" ]]
        then
            echo ""
            echo "You will need to manually run $POST_CREATE_SCRIPT on the $VSERVER_NAME"
            echo ""
        fi
    fi
}

#############################################################
##
## injectScriptWithSshKey
## =======================
##
## Inject a post creation script that will be executed once 
## the vServer is running. This will be done only if the 
## script can access the new vServer.
##
#############################################################

function injectScriptWithSshKey() {
    findAccessibleSshIP
    if [[ "$SSH_IP_ADDRESS" != "" ]]
    then
        injectScriptIntoVServer
    else
        echo ""
        echo "Unable to find a route to $VSERVER_NAME to rto execute $POST_CREATE_SCRIPT"
        echo ""
        echo "1. ssh into the vServer using: ssh -i $KEY_FILE -l root <IP Address>"
        echo ""
        echo "You will need to manually run $POST_CREATE_SCRIPT on the $VSERVER_NAME"
        echo ""
        KEEP_PUB_KEY=true
    fi
}

#############################################################
##
## injectScriptIntoVServer
## =======================
##
## Inject a post creation script that will be executed once 
## the vServer is running. This will be done only if the 
## script can access the new vServer.
##
#############################################################

function injectScriptIntoVServer() {
        echo ""
        echo "Executing $POST_CREATE_SCRIPT on $VSERVER_NAME on $SSH_IP_ADDRESS"

        scp $SSH_FLAGS $POST_CREATE_SCRIPT root@$SSH_IP_ADDRESS:/tmp
        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "chmod +x /tmp/$POST_CREATE_SCRIPT"
        ssh $SSH_FLAGS root@$SSH_IP_ADDRESS "/tmp/$POST_CREATE_SCRIPT"
}
#############################################################
##
## pauseUntilVServerRunning
## ========================
##
## Pause the script until the vServer is running.
##
#############################################################

function pauseUntilVServerRunning() {
	# Wait until the Server is running before creating the next
	echo "Pausing until vServer is Running"
  getVServerState
  while [[ "$VSERVER_STATE" != "RUNNING" ]]
  do
  	echo "$NAME $VSERVER_STATE"
  	if [[ "$VSERVER_STATE" != "RUNNING" ]]
  	then
  		echo "Sleeping......."
  		sleep $WAIT_INTERVAL
  	fi
  	if [[ "$VSERVER_STATE" == "FAILED" ]]
  	then
  		echo "$NAME Will Delete Automatically after remaining Failed for a period....."
   		break
  	fi
  	getVServerState
  done
  echo "$NAME $VSERVER_STATE"
  # Lets pause for a minute or two
  echo "Just Waiting $WAIT_INTERVAL Seconds......"
  sleep $WAIT_INTERVAL
}

#############################################################
##
## pauseUntilVServerShutdown
## ========================
##
## Pause the script until the vServer is shutdown.
##
#############################################################

function pauseUntilVServerShutdown() {
    # Wait until the Server is shutdown before creating the next
  echo "Pausing until vServer has Shutdown"
  getVServerState
  while [[ "$VSERVER_STATE" != "SHUTDOWNDETACHED" && "$VSERVER_STATE" != "SHUTDOWN" ]]
  do
  	echo "$NAME $VSERVER_STATE"
  	if [[ "$VSERVER_STATE" != "SHUTDOWNDETACHED" && "$VSERVER_STATE" != "SHUTDOWN" ]]
  	then
  		echo "Sleeping......."
  		sleep $WAIT_INTERVAL
  	fi
  	getVServerState
  done
  echo "$NAME $VSERVER_STATE"
  # Lets pause for a minute or two
  echo "Just Waiting $WAIT_INTERVAL Seconds......"
  sleep $WAIT_INTERVAL
}

#############################################################
##
## attachVolume
## =======================
##
## Attach a Volume to a vServer.
##
#############################################################

function attachVolume() {
    # Get vServer Id
    getVServerId
    # Convert Volume Names to Ids
    VOLUME_IDS=""
    while true
    do
        VOLUME_NAME=${VOLUME_NAMES%%,*}
        VOLUME_NAMES=${VOLUME_NAMES#*,}
        getVolumeId
        if [[ "$VOLUME_IDS" != "" ]]
        then
                VOLUME_IDS="$VOLUME_IDS,$VOLUME_ID"
        else
                VOLUME_IDS=$VOLUME_ID
        fi
        if [[ "$VOLUME_NAME" == "$VOLUME_NAMES" ]]
        then
            break
        fi
    done
    # Attach Volumes
#    echo "About to execute : $IAAS_HOME/bin/iaas-attach-volumes-to-vserver --vserver-id $VSERVER_ID --volume-ids $VOLUME_IDS"
#    $IAAS_HOME/bin/iaas-attach-volumes-to-vserver --vserver-id $VSERVER_ID --volume-ids $VOLUME_IDS
    CMD="$IAAS_HOME/bin/iaas-attach-volumes-to-vserver --vserver-id $VSERVER_ID --volume-ids $VOLUME_IDS"

    #*******************************************
    echo "$CMD_MSG $CMD"
    echo "$CMD_MSG $CMD" >> $LOG_FILE
    IFS=$'\n' RESULT=( $(eval $CMD) )
    unset IFS
    echo "Command Result : $RESULT" >> $LOG_FILE
    #*******************************************

  # Lets pause
  echo "Just Waiting $WAIT_INTERVAL Seconds......"
  sleep $WAIT_INTERVAL
}

#############################################################
##
## uploadServerTemplate
## ====================
##
## Upload a tgz file that defines a server template. It is 
## recommended these be copied to the ZFS first and then the
## appropriate URL from the ZFS be used.
##
#############################################################

function uploadServerTemplate() {
    # Upload Template
#    echo "About to execute : $IAAS_HOME/bin/iaas-create-server-template-from-url --name $TEMPLATE_NAME --url $TEMPLATE_URL"
#    $IAAS_HOME/bin/iaas-create-server-template-from-url --name $TEMPLATE_NAME --url $TEMPLATE_URL
    CMD="$IAAS_HOME/bin/iaas-create-server-template-from-url --name $TEMPLATE_NAME --url $TEMPLATE_URL"

    #*******************************************
    echo "$CMD_MSG $CMD"
    echo "$CMD_MSG $CMD" >> $LOG_FILE
    IFS=$'\n' RESULT=( $(eval $CMD) )
    unset IFS
    echo "Command Result : $RESULT" >> $LOG_FILE
    #*******************************************

  # Lets pause
    pauseUntilServerTemplateUploaded
}

function deleteServerTemplate() {
    $IAAS_HOME/bin/iaas-delete-server-template --force --server-template-id $TEMPLATE_ID
}

#############################################################
##
## pauseUntilServerTemplateUploaded
## ================================
##
## Pause the script until the Template file has been uploaded
## to the Account.
##
#############################################################

function pauseUntilServerTemplateUploaded() {
    echo "Pausing until Template upload has completed"
  getTemplateState
  while [[ "$TEMPLATE_STATE" != "OK" ]]
  do
  	echo "$NAME $TEMPLATE_STATE"
  	if [[ "$TEMPLATE_STATE" != "SCHEDULED" ]]
  	then
            echo "Sleeping......."
            sleep $WAIT_INTERVAL
  	elif [[ "$TEMPLATE_STATE" != "RUNNING" ]]
  	then
            echo "Sleeping......."
            sleep $WAIT_INTERVAL
  	elif [[ "$TEMPLATE_STATE" != "FAILED" ]]
  	then
            deleteServerTemplate
            echo "Sleeping......."
            sleep $WAIT_INTERVAL
  	fi
  	getTemplateState
  done
  echo "$NAME $TEMPLATE_STATE"
}

#############################################################
##
## createAssets
## ============
##
## This function loops through the information defined in
## the input file looking for actions to be executed. It will
## process the entries sequentially and simply call the
## appropriate sub-function to execute the iaas commands.
## Entries with invalid Actions will simply be ignored along
## with blank lines.
##
#############################################################

function createAssets() {
	echo ""
	echo "************************************************"
	echo "*** Logging Create to $LOG_FILE"
	echo "************************************************"
	echo ""
	# Used for backward compatibility allowing old asset files to be used
	filler="|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
	
  if [[ "$PASSWORD_FILE" != "" ]]
	then
		echo "Password File specified on command line we will use this in preference to password in file"
	fi
  # Read Entries into an Array
  IFS=$'\n' assetArray=( $(grep ":" $ASSET_FILE) )
  unset IFS
  # Process Array
  for line in "${assetArray[@]}"
  do
          #echo "Processing Line: $line"
          ACCOUNT=${line%%:*}
          line=${line#*:}
          ACTION=${line%%|*}
          line=${line#*|}$filler
  	IFS=$'|' lineElements=($line)
          if [[ "$ACTION" == "Connect" ]]
          then
              ACCOUNT_USER=${line%%|*}
              line=${line#*|}
              ACCOUNT_PASSWORD=${line%%|*}
              IAAS_USER=$ACCOUNT_USER
              if [[ "$PASSWORD_FILE" == "" ]]
							then
              	echo "$ACCOUNT_PASSWORD" > $IAAS_PASSWORD_FILE
              fi
              getAccounts
              getAccountId
              connectToAccount

              ## Account Info
              getNetworks
              getVSTypes
              getTemplates
          elif [[ "$ACTION" == "Create" ]]
          then
              ASSET=${line%%|*}
              line=${line#*|}
              ASSET_DETAILS=$line
              if [[ "$ASSET" == "vServer" ]]
              then
                  getDistributionGroups
                  VSERVER_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  VSTYPE_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  TEMPLATE_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  NETWORK_NAMES=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  IP_ADDRESSES=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  DISTGROUP_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  DESCRIPTION=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  POST_CREATE_SCRIPT=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  VSERVER_HA=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  VSERVER_HOSTNAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  VSERVER_NETWORK_HOSTNAMES=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
#                    PCS=${ASSET_DETAILS%%|*}
#echo "Post Create Script $PCS"

                  createVServer
              elif [[ "$ASSET" == "vServers" ]]
              then
                  getDistributionGroups
                  createVServers
              elif [[ "$ASSET" == "Volume" ]]
              then
                  VOLUME_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  VOLUME_SIZE=${ASSET_DETAILS%%|*}
                  createVolume
              elif [[ "$ASSET" == "DistributionGroup" ]]
              then
                  DISTGROUP_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  DISTGROUP_SIZE=${ASSET_DETAILS%%|*}
                  createDistributionGroup
              elif [[ "$ASSET" == "VirtualNetwork" ]]
              then
                  NETWORK_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  NETWORK_IPS=${ASSET_DETAILS%%|*}
                  createVirtualNetwork
              fi
          elif [[ "$ACTION" == "Upload" ]]
          then
              ASSET=${line%%|*}
              line=${line#*|}
              ASSET_DETAILS=$line
              if [[ "$ASSET" == "ServerTemplate" ]]
              then
                  TEMPLATE_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  TEMPLATE_URL=${ASSET_DETAILS%%|*}
                  uploadServerTemplate
              fi
          elif [[ "$ACTION" == "Attach" ]]
          then
              ASSET=${line%%|*}
              line=${line#*|}
              ASSET_DETAILS=$line
              if [[ "$ASSET" == "Volume" ]]
              then
                  getVolumes
                  getVServers
                  VSERVER_NAME=${ASSET_DETAILS%%|*}
                  ASSET_DETAILS=${ASSET_DETAILS#*|}
                  VOLUME_NAMES=${ASSET_DETAILS%%|*}
                  attachVolume
              fi
          elif [[ "$ACTION" == "Disconnect" ]]
          then
              disconnectFromAccount
          fi
  done
}

#export RUN_DATE=`date +"%Y%m%d-%H%M"`

#############################################################
##
## validateOnlySingleVServerForName
## ================================
##
## Check that only a single vServer exists with given name.
##
#############################################################

function validateOnlySingleVServerForName() {
	SINGLE_VMCFG=true
  VIRTUAL_MACHINES_DIR=$REPOSITORY_DIR/VirtualMachines
  GREP_VM_CFG=`grep "'$VSERVER_NAME'" $VIRTUAL_MACHINES_DIR/*/vm.cfg`
  GREP_VM_CFG_CNT=( $(grep "'$VSERVER_NAME'" $VIRTUAL_MACHINES_DIR/*/vm.cfg | wc -l) )
  if [[ "$GREP_VM_CFG_CNT" != "1" ]]
  then
  	SINGLE_VMCFG=false
  	echo "$ERROR_PREFIX Multiple vServers exist with name $VSERVER_NAME can not create template."
  	echo "$GREP_VM_CFG"
  fi
}

#############################################################
##
## copyServerFiles
## ===============
##
## Copy the vServer img files to working location.
##
#############################################################

function copyServerFiles() {
    echo "Copying vServer Files"
    TEMPLATE_DIR=$WORKING_DIR/$VSERVER_NAME/template/BASE
    VIRTUAL_MACHINES_DIR=$REPOSITORY_DIR/VirtualMachines
    VIRTUAL_DISKS_DIR=$REPOSITORY_DIR/VirtualDisks
    ROOT_IMG_FILE=""

    GREP_VM_CFG=`grep "'$VSERVER_NAME'" $VIRTUAL_MACHINES_DIR/*/vm.cfg`
    VM_CFG=${GREP_VM_CFG%%:*}

    mkdir -p $TEMPLATE_DIR    
    cp $VM_CFG $TEMPLATE_DIR

    echo "$INFO_PREFIX Processing: $VM_CFG"
    DISKS=`grep disk $VM_CFG`
    FILES=${DISKS#*:}
    DEVICES=${FILES#*,}
    DISK_CNT=0
    VM_CFG_TEMPLATE_NAME=$VSERVER_NAME"_TEMPLATE"
    while [[ "$DISKS" != "$FILES" ]]
    do
        #echo "FILES = $FILES"
        #echo "DISKS = $DISKS"
        #echo "DISK_CNT = $DISK_CNT"
        IMG_FILE=${FILES%%,*}
        echo "$INFO_PREFIX Found Image File $IMG_FILE"
        IMG_FILE=${IMG_FILE#*VirtualDisks/}
        #echo "Copying $IMG_FILE"
        DEVICE=${DEVICES%%,*}
        # Set root image we assume the disked marked as hda is the root
        #if [[ "$ROOT_IMG_FILE" == "" ]]
        if [[ "$DEVICE" == "hda" ]]
        then
        	echo "$INFO_PREFIX Copying: cp $VIRTUAL_DISKS_DIR/$IMG_FILE $TEMPLATE_DIR/System.img"
            cp $VIRTUAL_DISKS_DIR/$IMG_FILE $TEMPLATE_DIR/System.img
            SYSTEM_IMG=${IMG_FILE#*VirtualDisks/}
            ROOT_IMG_FILE=$TEMPLATE_DIR/$SYSTEM_IMG
            ROOT_IMG_FILE=$TEMPLATE_DIR/System.img
            #echo "Root Image $ROOT_IMG_FILE"
            NEW_DISKS="'file:/OVS/seed_pool/$VM_CFG_TEMPLATE_NAME/System.img,hda,w'"
        else
        	echo "$INFO_PREFIX Copying: cp $VIRTUAL_DISKS_DIR/$IMG_FILE $TEMPLATE_DIR/System$DISK_CNT.img"
            cp $VIRTUAL_DISKS_DIR/$IMG_FILE $TEMPLATE_DIR/System$DISK_CNT.img
            #echo "Secondary Image $IMG_FILE"
            FILES=${FILES#*,}
            #echo "FILES = $FILES"
            IMG_FILE_TYPE=${FILES%%\'*}
            #echo "IMG_FILE_TYPE = $IMG_FILE_TYPE"
            NEW_DISKS=$NEW_DISKS", 'file:/OVS/seed_pool/$VM_CFG_TEMPLATE_NAME/System$DISK_CNT.img,$IMG_FILE_TYPE'"
            #ADDITIONAL_SYSTEM_IMGS+=("$TEMPLATE_DIR/System$DISK_CNT.img")
        fi
        # Shuffle line for next disk
        DISKS=${DISKS#*:}
        FILES=${DISKS#*:}
        DEVICES=${FILES#*,}
        DISK_CNT=$((DISK_CNT+1))
    done

    # Generate vm.cfg

    # Add Standard name format to allow ModifyJeOS to work
    echo "name = '$VM_CFG_TEMPLATE_NAME'" > $TEMPLATE_DIR/vm.cfg
    echo "disk = [$NEW_DISKS]" >> $TEMPLATE_DIR/vm.cfg
    echo "OVM_simple_name = ''" >> $TEMPLATE_DIR/vm.cfg
    
    #############################################################
    ## Add standard Template vm.cfg information.               ##
    #############################################################
		echo "acpi = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "apic = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "pae = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "builder = 'hvm'" >> $TEMPLATE_DIR/vm.cfg
		echo "kernel = '/usr/lib/xen/boot/hvmloader'" >> $TEMPLATE_DIR/vm.cfg
		echo "device_model = '/usr/lib/xen/bin/qemu-dm'" >> $TEMPLATE_DIR/vm.cfg
		echo "memory = '4096'" >> $TEMPLATE_DIR/vm.cfg
		echo "maxmem = '4096'" >> $TEMPLATE_DIR/vm.cfg
		echo "OVM_os_type = 'Oracle Linux 5' " >> $TEMPLATE_DIR/vm.cfg
		echo "vcpus = 4" >> $TEMPLATE_DIR/vm.cfg
		echo "uuid = 'c4cb389c-288d-c46d-5fb1-83f18772184a'" >> $TEMPLATE_DIR/vm.cfg
		echo "on_crash = 'restart'" >> $TEMPLATE_DIR/vm.cfg
		echo "on_reboot = 'restart'" >> $TEMPLATE_DIR/vm.cfg
		echo "serial = 'pty'" >> $TEMPLATE_DIR/vm.cfg
		echo "keymap = 'en-us'" >> $TEMPLATE_DIR/vm.cfg
		echo "vnc = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "vncconsole = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "vnclisten = '127.0.0.1'" >> $TEMPLATE_DIR/vm.cfg
		echo "vncpasswd = ''" >> $TEMPLATE_DIR/vm.cfg
		echo "vncunused = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "vif = []" >> $TEMPLATE_DIR/vm.cfg
		echo "timer_mode = 2" >> $TEMPLATE_DIR/vm.cfg
		echo "exalogic_vnic = [" >> $TEMPLATE_DIR/vm.cfg
		echo "        {  'guid' : '0xbbb34d724b05dd73'," >> $TEMPLATE_DIR/vm.cfg
		echo "            'pkey' : ['0xffff']," >> $TEMPLATE_DIR/vm.cfg
		echo "            'port' : '1'}," >> $TEMPLATE_DIR/vm.cfg
		echo "        {  'guid' : '0xbbb34d724b05dd74'," >> $TEMPLATE_DIR/vm.cfg
		echo "            'pkey' : ['0xffff']," >> $TEMPLATE_DIR/vm.cfg
		echo "            'port' : '2'}," >> $TEMPLATE_DIR/vm.cfg
		echo "        ]" >> $TEMPLATE_DIR/vm.cfg
		echo "exalogic_ipoib = [" >> $TEMPLATE_DIR/vm.cfg
		echo "        { 'pkey' : ['0xffff']," >> $TEMPLATE_DIR/vm.cfg
		echo "            'port' : '1'}," >> $TEMPLATE_DIR/vm.cfg
		echo "        { 'pkey' : ['0xffff']," >> $TEMPLATE_DIR/vm.cfg
		echo "            'port' : '2'}," >> $TEMPLATE_DIR/vm.cfg
		echo "        ]" >> $TEMPLATE_DIR/vm.cfg
#		echo "EL_Template_Version = 1" >> $TEMPLATE_DIR/vm.cfg
		echo "expose_host_uuid = 1" >> $TEMPLATE_DIR/vm.cfg
		#############################################################

    # Copy remaining content of vm.cfg
    while read line
    do
        if [[ "$line" =~ ^EL_Template_Version.* ]]
        then
            echo $line >> $TEMPLATE_DIR/vm.cfg
        fi
#        if [[ "$line" =~ ^name.*|^disk.*|^OVM_simple_name.*|^boot.*|^cpu_weight.*|^cpu_cap.*|^OVM_high_availability.*|^OVM_description.*|^on_poweroff.*|^guest_of_type.*|^vfb.* ]]
#        then
#            echo "Ignoring vm.cfg entry : $line"
#        else
#            echo $line >> $TEMPLATE_DIR/vm.cfg
#        fi
    done < $VM_CFG

}

#############################################################
##
## unconfigureVM
## =============
##
## Remove / edit the files that a created / modified when the
## template has been used to created a vServer.
##
#############################################################

function unconfigureVM() {
    echo "$INFO_PREFIX Unconfiguring Root Image $ROOT_IMG_FILE"
    cd $WORKING_DIR
    # Make Temp Mount Directory
    mkdir -p $SYSTEMIMGDIR
    
		# Create Loop File System associated with image
    createLoopFileSystem
    
    validateLoopFileSystemType
    
    if [[ "$IMGFS_VALID" == "true" ]]
    then
	    # Mount the Image file
	    # Check if we are using LVM
	    if [[ "$LVM" == "true" ]]
	    then
					echo "***********************************************"
					echo "*** Scan Volume Group"
					echo "***********************************************"
	        vgscan
					echo "***********************************************"
					echo "*** Set Volume Group Available"
					echo "***********************************************"
	        vgchange -ay $VOL_GRP
	        ls -l /dev/mapper
					echo "***********************************************"
					echo "*** Mount $SYSTEMIMGDIR"
					echo "***********************************************"
	        mount /dev/mapper/$VOL_GRP-$LOG_VOL $SYSTEMIMGDIR
	        if [[ "$?" == "1" ]]
	        then
	            echo "Failed to mount image file - exiting"
	            vgchange -an $VOL_GRP
	            deleteLoopFileSystem
	            exit
	        fi
	    else
					echo "***********************************************"
					echo "*** Mount $SYSTEMIMGDIR"
					echo "***********************************************"
	        mount /dev/mapper/`basename $LOOP`p2 $SYSTEMIMGDIR
	        if [[ "$?" == "1" ]]
	        then
	            echo "Failed to mount image file - exiting"
	            deleteLoopFileSystem
	            exit
	        fi
	    fi
	
			echo "***********************************************"
			echo "*** Mounted $SYSTEMIMGDIR"
			echo "***********************************************"
	    #Change Dir into mounted Image
	    cd $SYSTEMIMGDIR
	    
	    IMG_VERSION=$(cat usr/lib/init-exalogic-node/.template_version)
	
			echo "***********************************************"
			echo "*** Image File currently at version $IMG_VERSION"
			echo "***********************************************"
	
	    # Unconfigure
	    cp etc/sysconfig/ovmd etc/sysconfig/ovmd.orig
	    sed 's/INITIAL_CONFIG=no/INITIAL_CONFIG=yes/g' etc/sysconfig/ovmd.orig > etc/sysconfig/ovmd
	    rm -v etc/sysconfig/ovmd.orig
	
	    cp etc/resolv.conf etc/resolv.conf.$RUN_DATE
	    if [[ "$KEEP_RESOLV" != "true" ]]
	    then
	        sed -i '/.*/d' etc/resolv.conf
	    else
	        echo "Keeping unmodified resolv.conf"
	    fi
	
	    # Remove existing ssh information
	    rm -v root/.ssh/*
	    rm -v etc/ssh/ssh_host*
	
	    # Clean up hosts
	    cp etc/hosts etc/hosts.$RUN_DATE
	    cp etc/sysconfig/networking/profiles/default/hosts etc/sysconfig/networking/profiles/default/hosts.$RUN_DATE
	    if [[ "$KEEP_HOSTS" != "true" ]]
	    then
	        sed -i '/localhost/!d' etc/hosts
	        sed -i '/localhost/!d' etc/sysconfig/networking/profiles/default/hosts
	    else
	        echo "Keeping unmodified hosts"
	    fi
	
	    # Clean up networking
	    sed -i '/^GATEWAY/d' etc/sysconfig/network
	
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
	
	    # Remove bash history
	    rm -v root/.bash_history
	    
	    # Enable console respawn
	    cp etc/inittab etc/inittab.orig
	    sed 's/#co:2345:respawn:\/sbin\/agetty ttyS0 19200 vt100-nav/co:2345:respawn:\/sbin\/agetty ttyS0 19200 vt100-nav/' etc/inittab.orig > etc/inittab
	    rm -v etc/inittab.orig
	    
	    if [[ "$TGZ" != "" ]]
	    then
					echo "***********************************************"
					echo "*** Extracting $TGZ to $SYSTEMIMGDIR"
					echo "***********************************************"
					tar -zxvf $TGZ -C $SYSTEMIMGDIR
	    fi
	    
	    # Set the configuration requirements
	    #chroot $SYSTEMIMGDIR ovm-chkconfig --list
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add authentication
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add datetime
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add exalogic
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add firewall
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add network
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add selinux
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add ssh
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add system
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add user
	    chroot $SYSTEMIMGDIR ovm-chkconfig --add vmsshkey
	    #chroot $SYSTEMIMGDIR ovm-chkconfig --list
	    
	    # Write Log file info specifying which version of this script was used
	    SCRIPT_LOG=var/log/SimpleExaCli.log
	    echo "[`date +\"%Y/%m/%d-%T\"`] Template Created By $0 " > $SCRIPT_LOG 
	    echo "[`date +\"%Y/%m/%d-%T\"`] Version : $VERSION " >> $SCRIPT_LOG 
	    
	    # Zero Fill image file to for smaller tgz
	    cd $SYSTEMIMGDIR
	    zeroFill
	
	    # Unmount the image file
	    cd $WORKING_DIR
	    umount $SYSTEMIMGDIR
			echo "***********************************************"
			echo "*** Unmounted $SYSTEMIMGDIR"
			echo "***********************************************"
	
	    # Check if we are using LVM
	    if [[ "$LVM" == "true" ]]
	    then
					echo "***********************************************"
					echo "*** Set Volume Group Unavailable"
					echo "***********************************************"
	        vgchange -an $VOL_GRP
	    fi
	  fi

		# Delete Loop File System associated with image
		deleteLoopFileSystem

    rm -rf $SYSTEMIMGDIR
}

function createLoopFileSystem() {
    export LOOP=`losetup -f`
		echo "***********************************************"
		echo "*** Using loop $LOOP"
		echo "***********************************************"
    # Create Loop for the System Image
    losetup $LOOP $ROOT_IMG_FILE
		echo "***********************************************"
		echo "*** Assign $LOOP to $ROOT_IMG_FILE"
		echo "***********************************************"
    kpartx -av $LOOP
}

function findFileSystemType() {
	# Identify if this is ext3 or lvm file system
	# If the disk is a LVM disk, in one of the line it should say "Linux LVM". e.g.
	#	      Device Boot      Start         End      Blocks   Id  System
	#/dev/loop0p1   *           1          13      104391   83  Linux
	#/dev/loop0p2              14         765     6040440   8e  Linux LVM

	IMGFS="ext3"
	P=0
	#fdisk -l $LOOP
	partitionArray=( $(fdisk -l $LOOP | sed 's/ /|/g') )
	for partition in "${partitionArray[@]}"
	do
		if [[ "$partition" == *"$LOOP"* ]]
		then
			P=$((P + 1))
			if [[ "$partition" == *"Linux|LVM"* ]]
			then
				IMGFS="lvm"
				break;
			fi
		fi
	done

	echo ""	
	echo ">>>>>>>>>>>>>> File System $IMGFS"
	echo ""	
	
}

function validateLoopFileSystemType() {
	findFileSystemType
	
	if [[ "$IMGFS" == "lvm" && ( "$VOL_GRP" == "" || "$LOG_VOL" == "") ]]
	then
		echo ""	
		echo "************************************************"
		echo "***                  Exiting                 ***"
		echo "***                                          ***"
		echo "*** LVM File system was found but no Volume  ***"
		echo "*** Group or Logical Volume information      ***"
		echo "*** specified.                               ***"
		echo "***                                          ***"
		echo "************************************************"
		echo ""	
		IMGFS_VALID=false
    PVScan=( $(pvscan) )
    VGChangeY=( $(vgchange -ay) )
    echo ""
    echo "Found the following Volume Groups - Logical Volumes"
    echo "==================================================="
    echo ""
    lvs | awk '{if ($1 != "LV" && $2 != "VG" && $3 != "Attr") print $2" - "$1}'
#    lvm lvs | awk '{print $2" - "$1}'
    echo ""
    echo "==================================================="
    echo ""
    VGChangeN=( $(vgchange -an) )
	elif  [[ "$IMGFS" == "ext3" && ( "$VOL_GRP" != "" || "$LOG_VOL" != "") ]]
	then
		echo ""	
		echo "************************************************"
		echo "***                  Exiting                 ***"
		echo "***                                          ***"
		echo "*** EXT3 File system was found but LVM       ***"
		echo "*** Volume Group or Logical Volume           ***"
		echo "*** information was specified.               ***"
		echo "***                                          ***"
		echo "************************************************"
		echo ""	
		IMGFS_VALID=false
	else
		IMGFS_VALID=true
	fi
}

function deleteLoopFileSystem() {
		echo "***********************************************"
		echo "*** Unmounting $LOOP"
		echo "***********************************************"
		sync
		kpartx -dv $LOOP
		sync
		losetup -dv $LOOP
		sync
}

function modifySize() {
    if [[ "$ROOT_SIZE" != "" ]]
    then
        cd $TEMPLATE_DIR
        $MODIFYJEOS -f System.img -T $ROOT_SIZE
    fi
    if [[ "$SWAP_SIZE" != "" ]]
    then
        cd $TEMPLATE_DIR
        $MODIFYJEOS -f System.img -T $SWAP_SIZE
    fi
}

function zeroFill() {
	echo "******************************************************"
	echo "*** Zero Filling Image File Free Space             ***"
	echo "***                                                ***"
	echo "*** The following Message can be ignored:          ***"
	echo "***                                                ***"
	echo "*** dd: writing zero.file: No space left on device ***"
	echo "***                                                ***"
	echo "******************************************************"
	dd if=/dev/zero of=zero.small.file bs=1024 count=102400
	dd if=/dev/zero of=zero.file bs=1024
#	echo "[`date +\"%Y/%m/%d-%T\"`] Sync"
	sync ; sleep 60 ; sync
#	echo "[`date +\"%Y/%m/%d-%T\"`] Remove Files"
	rm -f zero.small.file
	rm -f zero.file
}

function buildTemplateTgz() {
	echo "Creating the Template tgz file"
	mkdir -p $DESTINATION_DIR
	cd $TEMPLATE_DIR
	TEMPLATE_TGZ=$DESTINATION_DIR/el_template_$VSERVER_NAME.tgz
	tar -zcvf $TEMPLATE_TGZ *
	echo "Template $TEMPLATE_TGZ file created"
}

function cleanWorkingDir() {
	echo "Cleaning Working Directory"
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
	HERE=$(pwd)
    VSERVER_NAME=$VSERVER
    validateOnlySingleVServerForName
    if [[ "$SINGLE_VMCFG" == "true" ]]
    then
	    copyServerFiles
	    unconfigureVM
	    if [[ "$IMGFS_VALID" == "true" ]]
	    then
		    modifySize
		    buildTemplateTgz
		  fi
	    cleanWorkingDir
	    echo ""
	    echo ""
	    echo "****************************************************"
	    echo "**"
	    echo "** $TEMPLATE_TGZ has been created from"
	    echo "** vServer $VSERVER_NAME "
	    echo "**"
	    echo "****************************************************"
	    echo ""
	    echo ""
	  fi
	cd $HERE
}

#############################################################
##
## executeRemoteCreateTemplate
## ===========================
##
## Execute the CreateTemplateFromVServer.sh on the specified 
## Compute Node. This is required because the Repository is
## not accessible from the EC VM. It's assumed we will not 
## need to enter a password.
##
#############################################################

function executeRemoteCreateTemplate() {
    echo "Executing Remote Functions"
    if [[ "$CN_IP_ADDRESS" != "" ]]
    then
        ADDITIONAL=""
        if [[ "$KEEP_RESOLV" == "true" ]]
        then
            ADDITIONAL=" -keep-resolv"
        fi
        if [[ "$KEEP_HOSTS" == "true" ]]
        then
            ADDITIONAL=$ADDITIONAL" -keep-hosts"
        fi
        if [[ "$ROOT_SIZE" != "" ]]
        then
            ADDITIONAL=$ADDITIONAL" -T $ROOT_SIZE"
        fi
        if [[ "$SWAP_SIZE" != "" ]]
        then
            ADDITIONAL=$ADDITIONAL" -S $SWAP_SIZE"
        fi
        echo "Additional $ADDITIONAL"
        echo "Copying script $0 to $CN_IP_ADDRESS"
        scp $0 root@$CN_IP_ADDRESS:/tmp
        ssh root@$CN_IP_ADDRESS "chmod a+x /tmp/$(basename $0)"
        if [[ "$LVM" == "true" ]]
        then
            ssh root@$CN_IP_ADDRESS "/tmp/$(basename $0) --create-template -v $VSERVER_NAME -r $REPOSITORY_DIR -w $WORKING_DIR -d $DESTINATION_DIR -lvm $VOL_GRP $LOG_VOL $ADDITIONAL"
        else
            ssh root@$CN_IP_ADDRESS "/tmp/$(basename $0) --create-template -v $VSERVER_NAME -r $REPOSITORY_DIR -w $WORKING_DIR -d $DESTINATION_DIR $ADDITIONAL"
        fi
        ssh root@$CN_IP_ADDRESS "rm -f /tmp/$(basename $0)"

        TEMPLATE_TGZ=$DESTINATION_DIR/el_template_$VSERVER_NAME.tgz
    else
    	echo "Compute Node IP has not been specified assuming remository is mounted locally"
    	createTemplate
    fi
}

#############################################################
##
## generateAssetsFile
## ==================
##
## Generates a Input script that can be used with the 
## --create-assets to recreate the account assets. 
##
#############################################################

function generateAssetsFile() {
    echo "$ACCOUNT:Connect|$ACCOUNT_USER|$ACCOUNT_PASSWORD" >> $ASSET_FILE
    
    # Get VServer specific information
    getVServers
    getNetworks
    getVSTypes
    getTemplates
    getDistributionGroups

    for line in "${vserversArray[@]}"
    do
        VSERVER_ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        line=${line#*|}
        DESCRIPTION=${line%%|*}
        line=${line#*|}
        STATE=${line%%|*}
        line=${line#*|}
        NETWORK_IDS=${line%%|*}
        line=${line#*|}
        NETWORK_IPS=${line%%|*}
        line=${line#*|}
        TEMPLATE_ID=${line%%|*}
        line=${line#*|}
        SSH_KEY=${line%%|*}
        line=${line#*|}
        VSTYPE_ID=${line%%|*}
        line=${line#*|}
        HA_FLAG=${line%%|*}
        line=${line#*|}
        DISTGROUP_ID=${line%%|*}
        line=${line#*|}
        VOLUME_IDS=${line%%|*}
        line=${line#*|}

        VSERVER_NAME=$NAME

        NETWORK_NAMES=""
        #NETWORK_IPS=""
        for NETWORK_ID in ${NETWORK_IDS//,/ }
        do
            getNetworkName
            if [[ "$NETWORK_NAMES" == "" ]]
            then
                NETWORK_NAMES=$NETWORK_NAME
                if [[ "$BACKUP" != "true" ]]
                then
                    NETWORK_IPS="*"
                fi
            else
                NETWORK_NAMES=$NETWORK_NAMES","$NETWORK_NAME
                if [[ "$BACKUP" != "true" ]]
                then
                    NETWORK_IPS=$NETWORK_IPS",*"
                fi
            fi
        done
        
				# Convert VSType Id To Name
        getVSTypeName
        
        # Convert Template Id to Name
        getTemplateName

        if [[ "$ECHO_IAAS" == "true" ]]
        then
        	# Get Distribution Group Name
        	getDistributionGroupName
        else
        	DISTGROUP_NAME=""
        fi

				#     Account:Action|Asset Type|VServer Name|VServer Type Name|Template Name|VNet Names (,)|IPs (,)|Dist Group Name|Description|Post Create Script|HA Flag|Hostname|Network Hostnames (,)
        echo "$ACCOUNT:Create|vServer|$VSERVER_NAME|$VSTYPE_NAME|$TEMPLATE_NAME|$NETWORK_NAMES|$NETWORK_IPS|$DISTGROUP_NAME|$DESCRIPTION||$HA_FLAG|||" >> $ASSET_FILE

    done
    
    echo "$ACCOUNT:Disconnect" >> $ASSET_FILE
}

#############################################################
##
## generateCaptureAssetFile
## ========================
##
## Generates a Input script that can be used with the 
## --create-assets to create a server based on the new 
## template.
##
#############################################################

function generateCaptureAssetFile() {
    echo "Capturing Asset information to input file $ASSET_FILE"
    if [[ "$ASSET_FILE" == "" ]]
    then
        ASSET_FILE=$VSERVER_NAME"Asset.in"
    fi
    echo "$ACCOUNT:Connect|$ACCOUNT_USER|$ACCOUNT_PASSWORD" > $ASSET_FILE
    # Here we are assuming that we have used the recommended mount
    SN_TEMPLATE_FILE=${TEMPLATE_TGZ/u01/export}
    echo "$ACCOUNT:Upload|ServerTemplate|$VSERVER_NAME-Template|http://$SN_IP_ADDRESS/shares$SN_TEMPLATE_FILE" >> $ASSET_FILE
    # Get VServer specific information
    getVServers
    getNetworks
    getVSTypes
    getDistributionGroups

    for line in "${vserversArray[@]}"
    do
        VSERVER_ID=${line%%|*}
        line=${line#*|}
        NAME=${line%%|*}
        line=${line#*|}
        if [[ "$NAME" == "$VSERVER_NAME" ]]
        then
            DESCRIPTION=${line%%|*}
            line=${line#*|}
            STATE=${line%%|*}
            line=${line#*|}
            NETWORK_IDS=${line%%|*}
            line=${line#*|}
            NETWORK_IPS=${line%%|*}
            line=${line#*|}
            TEMPLATE_ID=${line%%|*}
            line=${line#*|}
            SSH_KEY=${line%%|*}
            line=${line#*|}
            VSTYPE_ID=${line%%|*}
            line=${line#*|}
            HA_FLAG=${line%%|*}
            line=${line#*|}
            DISTGROUP_ID=${line%%|*}
            line=${line#*|}
            VOLUME_IDS=${line%%|*}
            line=${line#*|}

            NETWORK_NAMES=""
            #NETWORK_IPS=""
            IFS=$',' networkIdsArray=( $NETWORK_IDS )
            #for NETWORK_ID in ${NETWORK_IDS//,/ }
            for NETWORK_ID in ${networkIdsArray[@]}
            do
                getNetworkName
                if [[ "$NETWORK_NAMES" == "" ]]
                then
                    NETWORK_NAMES=$NETWORK_NAME
                    if [[ "$BACKUP" != "true" ]]
                    then
                        NETWORK_IPS="*"
                    fi
                else
                    NETWORK_NAMES=$NETWORK_NAMES","$NETWORK_NAME
                    if [[ "$BACKUP" != "true" ]]
                    then
                        NETWORK_IPS=$NETWORK_IPS",*"
                    fi
                fi
            done

            if [[ "$VSTYPE" == "" ]]
            then
                # Get VServer Type Name
                getVSTypeName
            else
                VSTYPE_NAME=$VSTYPE
            fi
            
            DISTGROUP_NAME=""
            if [[ "$ECHO_IAAS" == "true" ]]
            then
	            if [[ "$VSDG" == "" ]]
	            then
	            	# Get Distribution Group Name
	            	getDistributionGroupName
	            else
	            	DISTGROUP_NAME=$VSDG
	            fi
            else
            	DISTGROUP_NAME=$VSDG
            fi

						#     Account:Action|Asset Type|VServer Name|VServer Type Name|Template Name|VNet Names (,)|IPs (,)|Dist Group Name|Description|Post Create Script|HA Flag|Hostname|Network Hostnames (,)
		        echo "$ACCOUNT:Create|vServer|$VSERVER_NAME|$VSTYPE_NAME|$VSERVER_NAME-Template|$NETWORK_NAMES|$NETWORK_IPS|$DISTGROUP_NAME|$DESCRIPTION||$HA_FLAG|||" >> $ASSET_FILE

            break
        fi
    done

    echo "$ACCOUNT:Disconnect" >> $ASSET_FILE

    echo "Generated Asset File $ASSET_FILE"

}

#############################################################
##
## captureVServer
## ==============
##
## High level template creation function that will call the 
## required processing function in the necessary sequence.
##
#############################################################

function captureVServer() {
    VSERVER_NAME=$VSERVER
    stopVServer
    executeRemoteCreateTemplate
    startVServer
    generateCaptureAssetFile
    echo ""
    echo ""
    echo "****************************************************"
    echo "**"
    echo "** $TEMPLATE_TGZ has been created from"
    echo "** vServer $VSERVER_NAME "
    echo "**"
    echo "****************************************************"
    echo ""
    echo ""
}

function simpleCreateVServer() {
    ASSET_FILE=/tmp/simpleCreateAsset.$$.in
    echo "$ACCOUNT:Connect|$ACCOUNT_USER|$ACCOUNT_PASSWORD" > $ASSET_FILE
    echo "$ACCOUNT:Create|vServer|$VSERVER|$VSTYPE|$VSTEMPLATE|$NETWORK_NAMES|$NETWORK_IPS|$VSDG|$VSDESCRIPTION|$SCRIPT|" >> $ASSET_FILE
    echo "$ACCOUNT:Disconnect" >> $ASSET_FILE
    getAccounts
    createAssets
    rm -f $ASSET_FILE
}

function simpleStopVServer() {
    VSERVER_NAME=$VSERVER
    stopVServer
}

function simpleStartVServer() {
    VSERVER_NAME=$VSERVER
    startVServer
}

function simpleRestartVServer() {
    simpleStopVServer
    simpleStartVServer
}

function simpleDeleteVServer() {
    VSERVER_NAME=$VSERVER
    deleteVServer
}

#############################################################
##
## usage
## =====
##
## Show usage.
##
#############################################################

function usage() {
	echo ""
#	echo >&2 "usage: $0 [-a <Account Name>] [-v <vServer Name>] [-u <Account User>] [-p <Account Password>] [-r <Repository Directory>] [-w <Working Directory>] [-d <Destination Directory>] [-cip <Compute Node (01) IP Address>] [-sip <Storage Node IP Address>] [-url <IAAS Base URL>] [-f <Asset Definition File>] [-remove-ssh] [--verbose] <Command>"
	echo >&2 "usage: $0 <Command> <Parameters>"
	echo >&2 " "
	echo >&2 "Commands "
	echo >&2 " "
	echo >&2 "          --status-vservers"
	echo >&2 "                List the status all the vServers in the specified Account. If no Account is specified then it"
	echo >&2 "                will loop through all Accounts within the vDC listing the vServers. To successfully"
	echo >&2 "                achieve this the mandatory Username and Password must have access to all the accounts."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [-v <vServer Name>] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --start-vservers"
	echo >&2 "                Start all or the named -v vServer(s) in the specified Account. If no Account is specified"
	echo >&2 "                then it will loop through all Accounts within the vDC starting the vServers."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [-v <vServer Name>] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --reboot-vservers"
	echo >&2 "                Reboot all or the named -v vServer(s) in the specified Account. If no Account is specified"
	echo >&2 "                then it will loop through all Accounts within the vDC starting the vServers."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [-v <vServer Name>] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --stop-vservers"
	echo >&2 "                Stop all or the named -v vServer(s) in the specified Account. If no Account is specified"
	echo >&2 "                then it will loop through all Accounts within the vDC stoping the vServers."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [-v <vServer Name>] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --list-vservers"
	echo >&2 "                List all the vServers in the specified Account. If no Account is specified then it"
	echo >&2 "                will loop through all Accounts within the vDC listing the vServers. To successfully"
	echo >&2 "                achieve this the mandatory Username and Password must have access to all the accounts."
	echo >&2 "                If --verbose is also specified the all available vServer information will be listed."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [--verbose] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --list-vnets"
	echo >&2 "                List all the vNets in the specified Account. If no Account is specified then it"
	echo >&2 "                will loop through all Accounts within the vDC listing the vNets. To successfully"
	echo >&2 "                achieve this the mandatory Username and Password must have access to all the accounts."
	echo >&2 "                If --verbose is also specified the all available vNet information will be listed."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [--verbose] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --list-distgroups"
	echo >&2 "                List all the Distribution Groups in the specified Account. If no Account is specified then it"
	echo >&2 "                will loop through all Accounts within the vDC listing the Distribution Groups. To successfully"
	echo >&2 "                achieve this the mandatory Username and Password must have access to all the accounts."
	echo >&2 "                If --verbose is also specified the all available Distribution Group information will be listed."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [--verbose] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --list-volumes"
	echo >&2 "                List all the Volumes in the specified Account. If no Account is specified then it"
	echo >&2 "                will loop through all Accounts within the vDC listing the Volumes. To successfully"
	echo >&2 "                achieve this the mandatory Username and Password must have access to all the accounts."
	echo >&2 "                If --verbose is also specified the all available Volumes information will be listed."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [--verbose] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --list-templates"
	echo >&2 "                List all the Templates in the specified Account. If no Account is specified then it"
	echo >&2 "                will loop through all Accounts within the vDC listing the Templates. To successfully"
	echo >&2 "                achieve this the mandatory Username and Password must have access to all the accounts."
	echo >&2 "                If --verbose is also specified the all available Template information will be listed."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] [--verbose] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --create-vserver"
	echo >&2 "                Creates a single vServer based on the information provided in the parameters. All parameters"
	echo >&2 "                are name based and the ids will be found based on the provided name."
	echo >&2 " "
	echo >&2 "                Required parameters: -a <Account Name> -u <Account User> -p <Account Password> -v <vServer Name> -vs-type <VServer Type Name> -vs-template <VServer Template Name> -vs-networks <Network Names> -vs-ips <Network IPs> "
	echo >&2 "                Optional parameters: [-vs-dg <Distribution Group Name>] [-vs-desc <Description>] [-url <IAAS Base URL>] [-vs-script <Post Execution Script>"
	echo >&2 " "
	echo >&2 "          --delete-vserver"
	echo >&2 "                Deletes a single vServer based on the information provided in the parameters. All parameters"
	echo >&2 "                are name based and the ids will be found based on the provided name."
	echo >&2 " "
	echo >&2 "                Required parameters: -a <Account Name> -u <Account User> -p <Account Password> -v <vServer Name> "
	echo >&2 "                Optional parameters: [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --stop-vserver"
	echo >&2 "                Stops a single vServer based on the information provided in the parameters. All parameters"
	echo >&2 "                are name based and the ids will be found based on the provided name."
	echo >&2 " "
	echo >&2 "                Required parameters: -a <Account Name> -u <Account User> -p <Account Password> -v <vServer Name> "
	echo >&2 "                Optional parameters: [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --start-vserver"
	echo >&2 "                Starts a single vServer based on the information provided in the parameters. All parameters"
	echo >&2 "                are name based and the ids will be found based on the provided name."
	echo >&2 " "
	echo >&2 "                Required parameters: -a <Account Name> -u <Account User> -p <Account Password> -v <vServer Name> "
	echo >&2 "                Optional parameters: [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --restart-vserver"
	echo >&2 "                Restarts a single vServer based on the information provided in the parameters. All parameters"
	echo >&2 "                are name based and the ids will be found based on the provided name."
	echo >&2 " "
	echo >&2 "                Required parameters: -a <Account Name> -u <Account User> -p <Account Password> -v <vServer Name> "
	echo >&2 "                Optional parameters: [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --create-assets"
	echo >&2 "                Reads the specified Asset file and creates all the assets defined within it. If multiple"
	echo >&2 "                projects are defined these are worked through. The file is processed sequentially and"
	echo >&2 "                therefore must contain action in an appropriate sequence."
	echo >&2 " "
	echo >&2 "                Required parameters: -f <Asset Definition File>"
	echo >&2 "                Optional parameters: [-remove-ssh-key] [-url <IAAS Base URL>]"
	echo >&2 " "
	echo >&2 "          --create-template"
	echo >&2 "                Takes the specified vServer name and identifies the associated img files which will then"
	echo >&2 "                be copied to a working directory before being opened and edited thus converting them to a"
	echo >&2 "                template. If multiple images exist (because vServers uses volumes) it will be converted to"
	echo >&2 "                a single template with multiple img files and hence larger size. This command must be executed"
	echo >&2 "                on a physical compute node preferably cn01."
	echo >&2 " "
	echo >&2 "                Required parameters: -v <vServer Name>"
	echo >&2 "                Optional parameters: [-lvm <Volume Group> <Logical Volume>] [-r <Repository Directory>] [-w <Working Directory>] [-d <Destination Directory>] [-tgz <Archive to be extracted to root>] -keep-hosts -keep-resolv [-snapshot <Snapshot Name>]"
	echo >&2 " "
	echo >&2 "          --capture-vserver"
	echo >&2 "                Access the Exalogic EMOC system and retrieve the information about the specified vServer. This"
	echo >&2 "                information is recorded in an Asset file that can be used with --create-assets. The script also"
	echo >&2 "                takes the existing vServer image files and converts them into a template and the upload is added"
	echo >&2 "                to the Asset file."
	echo >&2 " "
	echo >&2 "                Required parameters: -a <Account Name> -v <vServer Name> -u <Account User> -p <Account Password> -cip <Compute Node (01) IP Address> -sip <Storage Node IP Address>"
	echo >&2 "                Optional parameters: [-lvm <Volume Group> <Logical Volume>] [-r <Repository Directory>] [-w <Working Directory>] [-d <Destination Directory>] [-new-ips] [-url <IAAS Base URL>] -keep-hosts -keep-resolv [-vs-dg <Distribution Group Name>] -vs-type <Replacement VServer Type Name> "
	echo >&2 " "
	echo >&2 "          --capture-vservers"
	echo >&2 "                Access the Exalogic EMOC system and retrieve the information about vServers in the specified Account."
	echo >&2 "                This information is recorded in an Asset file that can be used with --create-assets."
	echo >&2 " "
	echo >&2 "                Required parameters: -u <Account User> -p <Account Password>"
	echo >&2 "                Optional parameters: [-a <Account Name>] "
	echo >&2 " "
	echo >&2 "Parameters "
	echo >&2 " "
	echo >&2 "          -a <Account Name> Name of the Account that contains the Specified vServer."
	echo >&2 "          -u <Account User> User that is allowed to access the specified account the default is root"
	echo >&2 "          -p <Account Password> password of the specified user"
	echo >&2 "          -v <vServer Name> vServer to be templatised or cloned."
	echo >&2 "          -r <Repository Directory> Location of the repository the default is $REPOSITORY_DIR"
	echo >&2 "          -w <Working Directory> Working directory where intermediate files will be copied default $WORKING_DIR."
	echo >&2 "          -d <Destination Directory> Directory where the template tgz will be created. Default is $DESTINATION_DIR"
	echo >&2 "          -f <Asset Definition File> (Default is CreateAssets.in)"
	echo >&2 "          -vs-type <VServer Type Name> Name of the vServer Type to be used during the vServer Creation"
	echo >&2 "          -vs-template <VServer Template Name> Name of the vServer Template to be used during the vServer Creation"
	echo >&2 "          -vs-desc <VServer Description> Description of the vServer to be used during the vServer Creation"
	echo >&2 "          -vs-networks <Network Names> Comma separated list of Network Names the vServer will be associated with"
	echo >&2 "          -vs-ips <Network IPs> Comma separated list of IP Addresses, or * for automatic, associated with the network name list."
	echo >&2 "          -vs-dg <Distribution Group Name> Name of the Distribution Group that the server will be placed in."
	echo >&2 "          -vs-script <Post Execution Script> This script will be copied to the vServer and then executed once it has been created."
	echo >&2 "          -keep-hosts If set the hosts file will not be re-initialised during template creation."
	echo >&2 "          -keep-resolv If set the resolv.conf file will not be re-initialised during template creation."
	echo >&2 "          -remove-ssh-key Indicates that the ssh keys should be removed"
	echo >&2 "          -new-ips Indicates that the IP Address in a -capture-vserver should be replaced by * within the Asset file"
	echo >&2 "          -cip <Compute Node (01) IP Address> This is the IP Address of the Compute Node that will be used to access"
  echo >&2 "               the /OVS/Repository and the actual vserver image files"
	echo >&2 "          -sip <Storage Node IP Address> IP Address of the Storage node that will be placed in the generated Asset "
  echo >&2 "               file for the load template entry. This must be accessible from EMOC."
	echo >&2 "          -url <IAAS Base URL> URL to access the EMOC interface the default is https://localhost."
	echo >&2 "          -lvm <Volume Group> <Logical Volume> If the images file uses LVM then this parameter must be specified."
	echo >&2 "          -tgz <Path to Archive to be extracted> Path to a tgz archive that will be extracted to the root of the System.img during templating."
	echo >&2 "          -snapshot <Snapshot Name> Name of the ZFS snapshot to be used as the source of the vm.cfg & .img files during the creation of a template."
	echo >&2 "          -verbose Displays more information for list commands."
	echo >&2 "          -to-hrf Converts the verbose output to a Human Readable Form, i.e. replaces Ids with names."
	echo >&2 "          -h This message."
	echo >&2 " "
	echo""
	exit 1
}

###############################################################
##
## Simple start for the script that will extract the parameters
## and call the appropriate start function.
##
###############################################################

export ACCOUNT_USER=""
export ACCOUNT_PASSWORD=""
export SYSTEMIMGDIR=/mnt/elsystem$$
export REMOVE_SSH_KEYS=false
export WORKING_DIR="/u01/common/images/vServerTemplatesWIP"
export DESTINATION_DIR="/u01/common/images/vServerTemplates"
export REPOSITORY_DIR="/OVS/Repositories/*"
export CN_IP_ADDRESS=""
export SN_IP_ADDRESS=""
export BACKUP=true
export VSDESCRIPTION=""
export MODIFYJEOS="modifyjeos"

# Disclaimer
disclaimer
displayVersion

while [ $# -gt 0 ]
do
	case "$1" in	
# Parameters
		-a) ACCOUNT="$2"; shift;;
		-d) DESTINATION_DIR="$2"; shift;;
		-f) ASSET_FILE="$2"; shift;;
		-p) ACCOUNT_PASSWORD="$2"; shift;;
		-pf) PASSWORD_FILE="$2"; shift;;
		-r) REPOSITORY_DIR="$2"; shift;;
		-u) ACCOUNT_USER="$2"; shift;;
		-v) VSERVER="$2"; shift;;
		-w) WORKING_DIR="$2"; shift;;
		-cip) CN_IP_ADDRESS="$2"; shift;;
		-sip) SN_IP_ADDRESS="$2"; shift;;
		-url) IAAS_BASE_URL="$2"; shift;;
    -new-ips) BACKUP=false;;
    -keep-resolv) KEEP_RESOLV=true;;
    -keep-hosts) KEEP_HOSTS=true;;
		-remove-ssh-key) REMOVE_SSH_KEYS=true;;
    -lvm) LVM=true; VOL_GRP="$2"; LOG_VOL="$3"; shift; shift;;
    -vs-type) VSTYPE="$2"; shift;;
    -vs-template) VSTEMPLATE="$2"; shift;;
    -vs-desc) VSDESCRIPTION="$2"; shift;;
    -vs-networks) NETWORK_NAMES="$2"; shift;;
    -vs-ips) NETWORK_IPS="$2"; shift;;
    -vs-dg) VSDG="$2"; shift;;
    -vs-script) SCRIPT="$2"; shift;;
		-to-hrf) HRF=true;;
		-tgz) TGZ="$2"; shift;;
		-snapshot) SNAPSHOT="$2"; shift;;
    -T) ROOT_SIZE="$2"; shift;;
    -S) SWAP_SIZE="$2"; shift;;
		-verbose) VERBOSE=true;;
		--verbose) VERBOSE=true;;
		-debug) DEBUG=true;;
		--debug) DEBUG=true;;
# Commands
		--create-vserver) CREATE_VSERVER=true;;		
		--delete-vserver) DELETE_VSERVER=true;;		
		--stop-vserver) STOP_VSERVER=true;;		
		--start-vserver) START_VSERVER=true;;		
		--restart-vserver) RESTART_VSERVER=true;;		
		--stop-vservers) STOP_VSERVERS=true;;		
		--start-vservers) START_VSERVERS=true;;		
		--reboot-vservers) REBOOT_VSERVERS=true;;		
		--status-vservers) STATUS_VSERVERS=true;;		
		--list-vservers) LIST_VSERVERS=true;;               
		--list-vnets) LIST_VNETS=true;;		
		--list-distgroups) LIST_DISTGRPS=true;;		
		--list-templates) LIST_TEMPLATES=true;;		
		--list-volumes) LIST_VOLUMES=true;;	
    --create-assets) CREATE_ASSETS=true;;
    --create-template) CREATE_TEMPLATE=true;;
    --capture-vserver) CAPTURE_VSERVER=true;;
    --capture-vservers) CAPTURE_VSERVERS=true;;

    --test-cli) TEST_CLI=true;;
    --show-version) SHOW_VERSION=true;;
    --show-history) SHOW_VERSION=true;;

		*) usage;;
		*) break;;
	esac
	shift
done

IAAS_USER=$ACCOUNT_USER

if [[ "$PASSWORD_FILE" != "" ]]
then
	IAAS_PASSWORD_FILE="$PASSWORD_FILE"
	ACCOUNT_PASSWORD="$PASSWORD_FILE"
else
	echo "$ACCOUNT_PASSWORD" > $IAAS_PASSWORD_FILE
fi

# Check if the JAVA_HOME is set
if [[ "$JAVA_HOME" == "" ]]
then
	export JAVA_HOME=/usr/java/latest
#	echo "JAVA_HOME is not defined using $JAVA_HOME"
fi

identifyInstalledIaaS

FOUND_ACCOUNT=false

if [[ "$SNAPSHOT" != "" ]]
then
	SNAPSHOT_DIR=".zfs/snapshot/$SNAPSHOT"
	REPOSITORY_DIR+="/$SNAPSHOT_DIR"
	echo "Snapshot specified changing Repository to $REPOSITORY_DIR"
fi

if [[ "$CREATE_ASSETS" == "true" && "$ASSET_FILE" != "" ]]
then
    createAssets
elif [[ "$CREATE_TEMPLATE" == "true" && "$VSERVER" != "" ]]
then
    if [[ "$LVM" == "true" ]]
    then
        if [[ "$VOL_GRP" == "" || "$LOG_VOL" == "" ]]
        then
            usage
        else
            grep "^ *filter.*a/\.*" /etc/lvm/lvm.conf >/dev/null
            if [[ "$?" == "1" ]]
            then
               echo please change filter entry in /etc/lvm/lvm.conf from:
               grep "^ *filter.*r/\.*" /etc/lvm/lvm.conf
               echo to:
               echo '    filter = [ "a/.*/" ]'
               exit
            fi   
        fi
    fi
    time createTemplate
elif [[ "$TEST_CLI" == "true" && \
        "$ACCOUNT_USER" != "" && \
        "$ACCOUNT_PASSWORD" != "" ]]
then
    testCli
elif [[ "$CAPTURE_VSERVER" == "true" && \
        "$ACCOUNT" != "" && \
        "$ACCOUNT_USER" != "" && \
        "$ACCOUNT_PASSWORD" != "" && \
        "$VSERVER" != "" && \
        "$SN_IP_ADDRESS" != "" ]]
then
#        "$CN_IP_ADDRESS" != "" && \
    getAccounts
    for account in "${accountsArray[@]}"
    do
        ACCOUNT_ID=${account%%|*}
        account=${account#*|}
        ACCOUNT_NAME=${account%%|*}
        if [[ "$ACCOUNT" == "$ACCOUNT_NAME" && "$ACCOUNT_ID" == ACC-* ]]
        then
        		FOUND_ACCOUNT=true
            connectToAccount
            captureVServer
            disconnectFromAccount
        fi
    done
    if [[ "$FOUND_ACCOUNT" != "true" ]]
    then
    	echo "$INFO_PREFIX Failed to find account $ACCOUNT"
    fi
elif [[ "$CAPTURE_VSERVERS" == "true" && \
        "$ACCOUNT_USER" != "" && \
        "$ACCOUNT_PASSWORD" != "" ]]
then
    getAccounts
    ASSET_FILE=CreateAssets.$$.in
    for account in "${accountsArray[@]}"
    do
        ACCOUNT_ID=${account%%|*}
        account=${account#*|}
        ACCOUNT_NAME=${account%%|*}
        if [[ ("$ACCOUNT" == "" || "$ACCOUNT" == "$ACCOUNT_NAME") && "$ACCOUNT_ID" == ACC-* ]]
        then
            connectToAccount
            generateAssetsFile
            disconnectFromAccount
        fi
    done
elif [[ "$CREATE_VSERVER" == "true" && \
        "$ACCOUNT" != "" && \
        "$ACCOUNT_USER" != "" && \
        "$ACCOUNT_PASSWORD" != "" && \
        "$VSERVER" != "" && \
        "$VSTYPE" != "" && \
        "$VSTEMPLATE" != "" && \
        "$NETWORK_NAMES" != "" && \
        "$NETWORK_IPS" != "" ]]
then
    simpleCreateVServer
elif [[ ("$DELETE_VSERVER" == "true" || \
        "$STOP_VSERVER" == "true" || \
        "$START_VSERVER" == "true" || \
        "$RESTART_VSERVER" == "true") && \
        "$ACCOUNT" != "" && \
        "$ACCOUNT_USER" != "" && \
        "$ACCOUNT_PASSWORD" != "" && \
        "$VSERVER" != "" ]]
then
    getAccounts

    for account in "${accountsArray[@]}"
    do
        ACCOUNT_ID=${account%%|*}
        account=${account#*|}
        ACCOUNT_NAME=${account%%|*}
        if [[ ("$ACCOUNT" == "" || "$ACCOUNT" == "$ACCOUNT_NAME") && "$ACCOUNT_ID" == ACC-* ]]
        then
            connectToAccount
            if [[ "$DELETE_VSERVER" == "true" ]]
            then
                simpleDeleteVServer
            elif [[ "$STOP_VSERVER" == "true" ]]
            then
                simpleStopVServer
            elif [[ "$START_VSERVER" == "true" ]]
            then
                simpleStartVServer
            elif [[ "$RESTART_VSERVER" == "true" ]]
            then
                simpleRestartVServer
            fi
            disconnectFromAccount
        fi
    done
elif [[ ("$STOP_VSERVERS" == "true" || \
        "$START_VSERVERS" == "true" || \
        "$REBOOT_VSERVERS" == "true" || \
        "$LIST_VSERVERS" == "true" || \
        "$STATUS_VSERVERS" == "true" || \
        "$LIST_VNETS" == "true" || \
        "$LIST_DISTGRPS" == "true" || \
        "$LIST_TEMPLATES" == "true" || \
        "$LIST_VOLUMES" == "true") && \
        "$ACCOUNT_USER" != "" && \
        "$ACCOUNT_PASSWORD" != "" ]]
then
    getAccounts

    for account in "${accountsArray[@]}"
    do
        ACCOUNT_ID=${account%%|*}
        account=${account#*|}
        ACCOUNT_NAME=${account%%|*}
        if [[ ("$ACCOUNT" == "" || "$ACCOUNT" == "$ACCOUNT_NAME") && "$ACCOUNT_ID" == ACC-* ]]
        then
                connectToAccount
                if [[ "$STOP_VSERVERS" == "true" ]]
                then
                        stopVServers
                elif [[ "$START_VSERVERS" == "true" ]]
                then
                        startVServers
                elif [[ "$REBOOT_VSERVERS" == "true" ]]
                then
                        rebootVServers
                elif [[ "$LIST_VSERVERS" == "true" ]]
                then
                        listVServers
                elif [[ "$STATUS_VSERVERS" == "true" ]]
                then
                        listVServerStatus
                elif [[ "$LIST_VNETS" == "true" ]]
                then
                        listVNets
                elif [[ "$LIST_DISTGRPS" == "true" ]]
                then
                        listDistributionGroups
                elif [[ "$LIST_TEMPLATES" == "true" ]]
                then
                        listTemplates
                elif [[ "$LIST_VOLUMES" == "true" ]]
                then
                        listVolumes
                fi
                disconnectFromAccount
        fi
    done
elif [[ "$SHOW_VERSION" == "true" ]]
then
	displayVersion
	showVersionHistory
else
    usage
fi

if [[ "$PASSWORD_FILE" == "" ]]
then
	rm -f $IAAS_PASSWORD_FILE
fi

