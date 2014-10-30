#!/bin/bash
# ZFS project and share creation
# Oracle - DDY : 2014/09/08 : Creation 
# Variables
zfsServer=172.17.0.5
zfsUser=root
remoteScript=/export/scripts/storage/tmp_project.aksh
# Functions
confirmResp()
{
  while [ "x${reponse}" == "x" ]; 
  do
    echo "Invalid Input - ${MESSAGE}"; read reponse
  done
}

# Main 
# Clear the screen before running it
clear
# set Project Name as user input
echo "This script generates a project and all shares for a specific Forms project"
MESSAGE="Enter ZFS project Name : "
echo ${MESSAGE}; read reponse
confirmResp
projectName=${reponse}
sProjectName=$(echo ${projectName}| tr -s [A-Z] [a-z])

# confirm creation
MESSAGE="Confirm ZFS Project Creation (yes/no)"
echo ${MESSAGE}; read reponse
confirmResp
validation=$( echo ${reponse}| tr -s [A-Z] [a-z])
while [[ "${validation}" != "yes" ]] && [[ "${validation}" != "no" ]]
do
  echo "Invalid Input - Enter yes or no"; read reponse
  validation=$(echo ${reponse}|tr -s [A-Z] [a-z])
done
if [ "${validation}" == "no" ]; 
then
  echo "Project creation canceled by user"
  exit 99
fi

# generate aksh script for zsh storage server
# create project and every share
echo "script" > ${remoteScript}
echo "  run('shares');" >> ${remoteScript}
echo "  run('project ${projectName}');" >> ${remoteScript}
echo "  run('set mountpoint=/export/${sProjectName}');" >> ${remoteScript}
echo "  run('set default_group=wls');" >> ${remoteScript}
echo "  run('set default_user=wls');" >> ${remoteScript}
echo "  run('set default_permissions=750');" >> ${remoteScript}
echo "  run('set sharenfs=\"sec=sys,rw,root=@172.17.0.0/16\"');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('select ${projectName}');" >> ${remoteScript}
echo "  run('filesystem admin');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('filesystem backup');" >> ${remoteScript}
echo "  run('set root_user=wls');" >> ${remoteScript}
echo "  run('set root_group=wls');" >> ${remoteScript}
echo "  run('set root_permissions=775');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('filesystem jmsta');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('filesystem products');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('filesystem scripts');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('filesystem tmp_forms');" >> ${remoteScript}
echo "  run('set root_permissions=775');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

echo "  run('filesystem wllogs');" >> ${remoteScript}
echo "  run('set root_permissions=775');" >> ${remoteScript}
echo "  run('commit');" >> ${remoteScript}

# Run script on zfs storage server
echo "ssh ${zfsUser}@${zfsServer} < ${remoteScript}"
#ssh ${zfsUser}@${zfsServer} < ${remoteScript}
