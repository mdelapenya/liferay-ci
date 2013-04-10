#!/bin/bash

TYPE_OF_PLUGINS="themes webs hooks layouttpl portlets"

for plugin in $TYPE_OF_PLUGINS
do
        find ${WORKSPACE}/$plugin/* -maxdepth 0 -type d -exec sh -c "cd {}; /opt/ant/apache-ant-1.8.3/bin/ant war" \;
done
