#!/bin/bash

#
# ${server}: server in which the plugin will be deployed
# ${environment}: name of the application where the plugin will be deployed 
# ${plugin}: name of the plugin to deploy
# ${pluginProperties}: properties to customize the plugin 
#

LIFERAY_PLUGINS_REPOSITORY=${pluginsStagingPath}

TMP_DIRECTORY=/tmp/{environment}-${plugin}

echo "Creating temp folder..."

mkdir ${TMP_DIRECTORY}

echo "Copying plugin ${plugin} from staging to tmp..."

find ${LIFERAY_PLUGINS_REPOSITORY} -name ${plugin}*.war -exec cp {} ${TMP_DIRECTORY}/ \;

echo "Exploding ${plugin}..."

cd ${TMP_DIRECTORY} && find ${TMP_DIRECTORY} -name ${plugin}*.war -exec jar -xf {} \;

echo "Removing ${plugin} after exploded..."

find ${TMP_DIRECTORY} -name ${plugin}*.war -exec rm {} \;

echo "Creating portlet-ext.properties file..."

PORTLET_EXT_PROPERTIES_FILE=${TMP_DIRECTORY}/WEB-INF/classes/portlet-ext.properties

touch ${PORTLET_EXT_PROPERTIES_FILE}

for property in ${pluginProperties}
do
        echo $property >> ${PORTLET_EXT_PROPERTIES_FILE}
done

echo "Repackaging plugin ${plugin} with custom properties..."

cd ${TMP_DIRECTORY} && jar -cfv ${plugin}.war .

echo "Undeploying plugin from ${environment}..."

ssh liferay@${server} "find /deploy/${environment}/webapps -type d -name *${plugin}* -maxdepth 1 -exec rm -fr {} \;"

echo "Re-deploying plugin ${plugin} to ${environment}..."

scp ${TMP_DIRECTORY}/${plugin}.war ${server}:/home/liferay/${environment}/deploy \;

echo "Plugin ${plugin} deployed ${environment} sucessfully"