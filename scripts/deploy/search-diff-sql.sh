#!/bin/sh

if [ $# != 3 ]
then
        echo "<Usage> $0 <staged folder><deployment environment><liferay.version>"
        exit
fi

#DEPLOYED_PORTAL_IMPL_JAR=$2/webapps/ROOT/WEB-INF/lib/portal-impl.jar
DEPLOYED_PORTAL_IMPL_JAR=/tmp/portal-impl.jar
STAGED_PORTAL_IMPL_JAR=$1/webapps/ROOT/WEB-INF/lib/portal-impl.jar

scp james:/deploy/$2/webapps/ROOT/WEB-INF/lib/portal-impl.jar ${DEPLOYED_PORTAL_IMPL_JAR}


TEMP_FOLDER_DEPLOYED=/tmp/deployed/
TEMP_FOLDER_STAGED=/tmp/staged/


rm -fr ${TEMP_FOLDER_DEPLOYED} ${TEMP_FOLDER_STAGED}
mkdir ${TEMP_FOLDER_DEPLOYED} ${TEMP_FOLDER_STAGED}

cp ${DEPLOYED_PORTAL_IMPL_JAR} ${TEMP_FOLDER_DEPLOYED}
cp ${STAGED_PORTAL_IMPL_JAR} ${TEMP_FOLDER_STAGED}

for folder in ${TEMP_FOLDER_DEPLOYED} ${TEMP_FOLDER_STAGED}
do
        unzip -o ${folder}/portal-impl.jar -d ${folder}
done

DEPLOYED_SQL_FILE=`find ${TEMP_FOLDER_DEPLOYED} -name "*$3.sql"`
STAGED_SQL_FILE=`find ${TEMP_FOLDER_STAGED} -name "*$3.sql"`

diff -a --normal ${DEPLOYED_SQL_FILE} ${STAGED_SQL_FILE}

echo $DEPLOYED_SQL_FILE
echo $STAGED_SQL_FILE