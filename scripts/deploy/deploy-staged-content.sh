#!/bin/bash

##
## Env variables
## 

# Default deployment directory in Deployment Server
export PREFIX="/deploy"

#The specific path for each specific environment 
export SERVER_ROOT=${PREFIX}/${environment}

#Location of the stable source code
export STAGED_FOLDER="/opt/tomcat/liferay-master-staging"

# Stop the running server
ssh  ${server} "shutdown-server.sh ${environment}"

# sleeping waiting for remote command
sleep 15

# backup environment
ssh ${server} "/home/liferay/liferay-ci/scripts/deploy/backup-environment.sh harry ${environment} backup liferay liferay ${doFileSystemBackup}"

# remove osgi state
ssh ${server} "rm -fr /home/liferay/${environment}/data/osgi/state"

# Move the source code (staging) to the live server 

ssh ${server} "rm -fr ${SERVER_ROOT}/webapps/ROOT ${SERVER_ROOT}/lib/ext/{support-tomcat,portal-service}.jar ${SERVER_ROOT}/{work,temp,logs}/*"

###
## Tar the staged contents and sent them to the remote server
###
ROOT_TAR_ORIG=/tmp/ROOT_${environment}.tar
ROOT_TAR_DEST=${SERVER_ROOT}/webapps/ROOT_${environment}.tar

tar vcf ${ROOT_TAR_ORIG} -C ${STAGED_FOLDER}/webapps ROOT
scp ${ROOT_TAR_ORIG} ${server}:${ROOT_TAR_DEST}

# Untar the staged content in the specific Deployment Server defind by enviroment variable
ssh ${server} "tar vxf ${ROOT_TAR_DEST} --directory='${SERVER_ROOT}/webapps'; rm -f ${ROOT_TAR_DEST}"

#Copy the portal dependency to the specific Deployment Server
scp ${STAGED_FOLDER}/lib/ext/{support-tomcat,portal-service}.jar ${server}:${SERVER_ROOT}/lib/ext

###
## Configure the portal properties and copy to the specific Deployment Server
##
LOCAL_PORTAL_EXT_PROPERTIES_FILE=/tmp/portal-ext-${environment}.properties
PORTAL_EXT_PROPERTIES_FILE=${SERVER_ROOT}/webapps/ROOT/WEB-INF/classes/portal-ext.properties

rm -f ${LOCAL_PORTAL_EXT_PROPERTIES_FILE} && touch ${LOCAL_PORTAL_EXT_PROPERTIES_FILE}

for property in ${portalProperties}
do
        echo $property >> ${LOCAL_PORTAL_EXT_PROPERTIES_FILE}
done

#Copy to the specific Deployment Server
scp ${LOCAL_PORTAL_EXT_PROPERTIES_FILE} ${server}:${PORTAL_EXT_PROPERTIES_FILE}

###
# Restart the application server
### 
ssh  ${server} "start-server.sh ${environment}"
