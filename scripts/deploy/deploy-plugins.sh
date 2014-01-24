#!/bin/bash

###
# Copy staged  plugins to the specific Server Deployment
###

OLD_IFS=${IFS}

IFS=','

LIFERAY_PLUGINS_REPOSITORY=${pluginsStagingPath}

for plugin in $plugins
do 
	echo Removing deployed plugin
	ssh liferay@${server} "find /deploy/${environment}/webapps -type d -name *${plugin}* -maxdepth 1 -exec rm -fr {} \;"

  echo Deploying the $plugin plugins
  find ${LIFERAY_PLUGINS_REPOSITORY} -name $plugin*.war -exec scp {} ${server}:/home/liferay/${environment}/deploy \;
done

echo The plugins "$plugins" has been copied to the autodeploy folder present at /home/liferay/${environment}/deploy. The autodeploy process will start in a few seconds
