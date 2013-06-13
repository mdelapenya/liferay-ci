#!/bin/bash

##
# This script assumes that the environment is stopped
##

##
# FUNCTIONS
##

PARAMS_COUNT=${#}

function copy() {
	rsync -av --delete ${1} ${2}
}

function backupDatabase() {
	mysqldump -u${2} -p${3} -h${1} liferay_${4} > ${5}
}

function restoreDatabase() {
	mysql -u${2} -p${3} -h${1} liferay_${4} < ${5}
}

function usage() {
	if [ ${PARAMS_COUNT} -ne 5 ]
	then
		echo "Please use this script with five parameters: host, environment-name, operation {restore | backup}, db-user and db-password. Actually ${PARAMS_COUNT} parameters have been sent."
		exit 1
	fi
}

usage

# 
# ${1} : hostname where files will be copied from/to
# ${2} : server name {master | master_demo | master_erpl | master_so | master_pre_alloy2}
# ${3} : type of operation {restore | backup}
# ${4} : database user
# ${5} : database password 
#

HOST=${1}
ENVIRONMENT=${2}
OPERATION_TYPE=${3}

DB_USER=${4}
DB_PASSWORD=${5}

BACKUP_PREFIX="/backup"

DIR_APP_ENVIRONMENT="/deploy"
DIR_HOME_ENVIRONMENT="/home/liferay"

DIR_BACKUP_APP_ENVIRONMENT=${BACKUP_PREFIX}${DIR_APP_ENVIRONMENT}
DIR_BACKUP_HOME_ENVIRONMENT=${BACKUP_PREFIX}${DIR_HOME_ENVIRONMENT}

DB_ENVIRONMENT_FILENAME="liferay_${ENVIRONMENT}.sql"
DB_BACKUP_ENVIRONMENT_FILENAME="${DIR_BACKUP_HOME_ENVIRONMENT}/liferay_${ENVIRONMENT}.sql"

if [ "${OPERATION_TYPE}" == "restore" ]
then
	# restore portal application server
	copy ${DIR_BACKUP_APP_ENVIRONMENT}/${ENVIRONMENT} ${DIR_APP_ENVIRONMENT}/

	# restore portal home
	copy ${DIR_BACKUP_HOME_ENVIRONMENT}/${ENVIRONMENT} ${DIR_HOME_ENVIRONMENT}/

	# restore database
	restoreDatabase ${HOST} ${DB_USER} ${DB_PASSWORD} ${ENVIRONMENT} ${DB_BACKUP_ENVIRONMENT_FILENAME}
else
	if [ "${OPERATION_TYPE}" == "backup" ]
	then
		# backup portal application server
		copy ${DIR_APP_ENVIRONMENT}/${ENVIRONMENT} ${DIR_BACKUP_APP_ENVIRONMENT}/

		# backup portal home
		copy ${DIR_HOME_ENVIRONMENT}/${ENVIRONMENT} ${DIR_BACKUP_HOME_ENVIRONMENT}/

		# backup database
		backupDatabase ${HOST} ${DB_USER} ${DB_PASSWORD} ${ENVIRONMENT} ${DB_BACKUP_ENVIRONMENT_FILENAME}
	else
		echo "Please use restore or backup as third parameter"
		exit 1
	fi
fi