#/bin/bash

export PATH=${PATH}:/opt/ant/apache-ant-1.8.3/bin

echo "Deploying the succesful build to the staging environment"

#  Copy all the relevant files to the staged folder

FULL_PATH_STAGED_FOLDER=${stagedPath}/${stagedFolder}

rm -fr ${stagedFolder}/webapps/ROOT
cp -R ${WORKSPACE}/../bundles/tomcat-7.0.40/webapps/ROOT ${FULL_PATH_STAGED_FOLDER}/webapps

cp ${WORKSPACE}/../bundles/tomcat-7.0.40/lib/ext/{support-tomcat,portal-service}.jar ${FULL_PATH_STAGED_FOLDER}/lib/ext


# Include the current revision in the theme

echo "Generating current revision in the default theme . . ."

LIFERAY_GITHUB_REPO=https://github.com/liferay/liferay-portal/commit

FILE=$(find ${FULL_PATH_STAGED_FOLDER} -name bottom-ext.jsp)

CURRENT_HEAD=$(git rev-parse HEAD)

CURRENT_DATE=$(git log -1 --pretty=format:%cd HEAD)

URL_CURRENT_HEAD=${LIFERAY_GITHUB_REPO}/${CURRENT_HEAD}

LAST_COMMIT="<div class='alert alert-info' style='margin: 2em'>Commit <a href='${URL_CURRENT_HEAD}'>${CURRENT_HEAD} - ${CURRENT_DATE}</a></div>"

echo '<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>' > $FILE
echo '<% String ppstate = ParamUtil.getString(request, "p_p_state", "normal");%>' >> $FILE
echo '<c:if test="<%= ppstate.equals("normal") %>">' >> $FILE
echo ${LAST_COMMIT} >> $FILE
echo "</c:if>" >> $FILE

#echo "<div class='portlet-msg-info' style='margin: 2em'>Commit <a href='${URL_CURRENT_HEAD}'>${CURRENT_HEAD}</a></div>" > $FILE
