#!/bin/bash

##
## Env variables
## 

export JAVA_HOME=/opt/java/jdk1.6.0_31
export PATH=${PATH}:/opt/ant/apache-ant-1.8.3/bin

echo "Deploying the succesful build to the staging environment"

STAGING_APP_SERVER_PARENT_FOLDER=/opt/tomcat/liferay-master-staging

APP_SERVER_PARENT_FOLDER=/opt/tomcat/liferay-master
APP_SERVER_RUNNING_PID=${APP_SERVER_PARENT_FOLDER}/liferay.pid

APP_SERVER_PROPERTIES="app.server.${USER}.properties"

#  Create the file
touch ${APP_SERVER_PROPERTIES}

#  Write the configuration
echo "app.server.tomcat.dir=${STAGING_APP_SERVER_PARENT_FOLDER}" > ${APP_SERVER_PROPERTIES}

#  Configure the database
PORTAL_EXT_PROPERTIES_FILE=./portal-impl/src/portal-ext.properties

mv ${PORTAL_EXT_PROPERTIES_FILE} ${PORTAL_EXT_PROPERTIES_FILE}.bak

# Configure the database

echo "jdbc.default.driverClassName=com.mysql.jdbc.Driver" > ${PORTAL_EXT_PROPERTIES_FILE}
echo "jdbc.default.url=jdbc:mysql://localhost/liferay?useUnicode=true&characterEncoding=UTF-8&useFastDateParsing=false" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "jdbc.default.username=liferay" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "jdbc.default.password=liferay" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "web.server.host=master.liferay.org.es" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "web.server.http.port=80" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "redirect.url.security.mode=domain" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "redirect.url.domains.allowed=master.liferay.org.es" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "index.on.startup=true" >> ${PORTAL_EXT_PROPERTIES_FILE}
echo "session.store.password=true" >> ${PORTAL_EXT_PROPERTIES_FILE}

#  Make the deploy
ant deploy

#  Revert the configuration
rm -f ${APP_SERVER_PROPERTIES} 
mv ${PORTAL_EXT_PROPERTIES_FILE}.bak ${PORTAL_EXT_PROPERTIES_FILE}

# Include the current revision in the theme

LIFERAY_GITHUB_REPO=https://github.com/liferay/liferay-portal/commit

FILE=$(find ${STAGING_APP_SERVER_PARENT_FOLDER} -name bottom-ext.jsp)

CURRENT_HEAD=$(git rev-parse HEAD)

URL_CURRENT_HEAD=${LIFERAY_GITHUB_REPO}/${CURRENT_HEAD}

LAST_COMMIT="<div class='portlet-msg-info' style='margin: 2em'>Commit <a href='${URL_CURRENT_HEAD}'>${CURRENT_HEAD}</a></div>"

echo '<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>' > $FILE
echo '<% String ppstate = ParamUtil.getString(request, "p_p_state", "normal");%>' >> $FILE
echo '<c:if test="<%= ppstate.equals("normal") %>">' >> $FILE
echo ${LAST_COMMIT} >> $FILE
echo "</c:if>" >> $FILE

#echo "<div class='portlet-msg-info' style='margin: 2em'>Commit <a href='${URL_CURRENT_HEAD}'>${CURRENT_HEAD}</a></div>" > $FILE
