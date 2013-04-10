#!/bin/bash
peerReviewerName=$1

DATABASE_NAME="lportal_${peerReviewerName}"
GITHUB_PROJECT="http://github.com/${peerReviewerName}/liferay-portal"
GITHUB_REPOSITORY=${GITHUB_PROJECT}
JENKINS_BUILD_PORTAL_IMPL_PATH="/jenkins-data/jobs/build."${peerReviewerName}"/workspace/portal-impl"
JENKINS_BASE_URL="http://ci.liferay.org.es/jenkins"

echo "Creating Jenkins build for "${peerReviewerName}

# Create the build using via HTTP POST (see Jenkins API http://ci.liferay.org.es/jenkins/api)
curl -u XXX:XXX --data 'name=${peerReviewerName}&mode=copy&from=build.mdelapenya' ${JENKINS_BASE_URL}/createItem

##
# Create database lportal_${peerReviewName}
##
echo "Creating database for "${peerReviewerName}
mysql -u root -h harry -pXXXX -Bse "CREATE DATABASE ${DATABASE_NAME};"

##
# Grant privileges to default liferay user in the database
##
echo "Granting priviliges in "${DATABASE_NAME}" to "${peerReviewerName}
mysql -u root -h -pXXXX -Bse "GRANT ALL ON ${DATABASE_NAME}.* to 'liferay'@'localhost' identified by 'liferay';"

##
# Disable new build
##

##
# Configure specific parameters
##
echo "Configuring Github parameters for "${peerReviewerName}

# Github Project

# Github repository URL

# Gihub pull request builder

# Admin
# Whitelist

##
# File System
##
echo "Configuring file system for "${peerReviewerName}

# Copy bundles from an existing build

# Copy workspace from Github
git clone https://github.com/${peerReviewerName}/liferay-portal.git

# Edit remotes for GIT
git remote rm origin
git remote add origin https://github.com/${peerReviewerName}/liferay-portal

##
# Edit liferay configuration files
##

echo "Configuring Liferay properties files for "${peerReviewerName}

# edit portal-ext.properties

PORTAL_EXT_PROPERTIES_FILE=${JENKINS_BUILD_PORTAL_IMPL_PATH}/src/portal-ext.properties

rm -f ${PORTAL_EXT_PROPERTIES_FILE} && touch ${PORTAL_EXT_PROPERTIES_FILE}

for property in ${portalProperties}
do
        echo $property >> ${PORTAL_EXT_PROPERTIES_FILE}
done

# edit portal-test-ext.properties

PORTAL_TEST_EXT_PROPERTIES_FILE=${JENKINS_BUILD_PORTAL_IMPL_PATH}/test/portal-test-ext.properties

rm -f ${PORTAL_TEST_EXT_PROPERTIES_FILE} && touch ${PORTAL_TEST_EXT_PROPERTIES_FILE}

for property in ${portalTestProperties}
do
        echo $property >> ${PORTAL_TEST_EXT_PROPERTIES_FILE}
done
