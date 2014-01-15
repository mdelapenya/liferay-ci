#!/bin/bash

TYPE_OF_PLUGINS="themes webs hooks layouttpl portlets shared"

for plugin in $TYPE_OF_PLUGINS
do
	for dir in $(find ${WORKSPACE}/$plugin/* -maxdepth 0 -type d) 
	do
		if [[ ! "${dir}" == *sync-engine-shared* ]];
		then
			cd ${dir}; /usr/bin/ant $1
		else
			echo "Excluding ${dir}"
		fi
	done
done
