##
# Configure the portal properties
##
PORTAL_EXT_PROPERTIES_FILE=/jenkins-data/jobs/${peerReviewerName}/workspace/portal-impl/src/portal-ext.properties

echo "Removing "${PORTAL_EXT_PROPERTIES_FILE}

rm -f ${PORTAL_EXT_PROPERTIES_FILE} && touch ${PORTAL_EXT_PROPERTIES_FILE}

echo "Creating "${PORTAL_EXT_PROPERTIES_FILE}
for property in ${portalProperties}
do
        echo $property >> ${PORTAL_EXT_PROPERTIES_FILE}
done

##
# Configure the portal test properties
##
PORTAL_TEST_EXT_PROPERTIES_FILE=/jenkins-data/jobs/${peerReviewerName}/workspace/portal-impl/test/portal-test-ext.properties

echo "Removing "${PORTAL_TEST_EXT_PROPERTIES_FILE}

rm -f ${PORTAL_TEST_EXT_PROPERTIES_FILE} && touch ${PORTAL_TEST_EXT_PROPERTIES_FILE}

echo "Creating "${PORTAL_TEST_EXT_PROPERTIES_FILE}
for property in ${portalTestProperties}
do
        echo $property >> ${PORTAL_TEST_EXT_PROPERTIES_FILE}
done

# Creating build.properties for user

##
# Configure the build properties
##
BUILD_PROPERTIES_FILE=/jenkins-data/jobs/${peerReviewerName}/workspace/build.liferay.properties

echo "Removing "${BUILD_PROPERTIES_FILE}
rm -f ${BUILD_PROPERTIES_FILE} && touch ${BUILD_PROPERTIES_FILE}

echo "Creating "${BUILD_PROPERTIES_FILE}
for property in ${buildProperties}
do
        echo $property >> ${BUILD_PROPERTIES_FILE}
done
