#!/bin/bash

##
## Env variables
## 

export JAVA_HOME=/opt/java/jdk1.6.0_31
export PATH=${PATH}:/opt/ant/apache-ant-1.8.3/bin

STAGING_APP_SERVER_PARENT_FOLDER=/opt/tomcat/liferay-master-staging

APP_SERVER_PARENT_FOLDER=/opt/tomcat/liferay-master
APP_SERVER_RUNNING_PID=${APP_SERVER_PARENT_FOLDER}/liferay.pid

# Stop the running server

PID=$(cat ${APP_SERVER_RUNNING_PID})
echo "Stopping the running server with PID: ${PID} "
kill -9 ${PID}

# Move the info the the live server

rm -fr ${APP_SERVER_PARENT_FOLDER}/webapps/ROOT
rm -fr ${APP_SERVER_PARENT_FOLDER}/lib/ext/{support-tomcat,portal-service}.jar
rm -fr ${APP_SERVER_PARENT_FOLDER}/{work,temp,logs,conf}/*

cp -pR ${STAGING_APP_SERVER_PARENT_FOLDER}/webapps/ROOT ${APP_SERVER_PARENT_FOLDER}/webapps
cp -p  ${STAGING_APP_SERVER_PARENT_FOLDER}/lib/ext/{support-tomcat,portal-service}.jar ${APP_SERVER_PARENT_FOLDER}/lib/ext
cp -pR ${STAGING_APP_SERVER_PARENT_FOLDER}/conf/* ${APP_SERVER_PARENT_FOLDER}/conf/

/home/tomcat/tools/database/dropDatabase.sh liferay liferay lportal

##
## Restart the application server
##

${APP_SERVER_PARENT_FOLDER}/bin/startup.sh
