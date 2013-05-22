#!/bin/bash

TYPE_OF_PLUGINS="themes webs hooks layouttpl portlets shared"

for plugin in $TYPE_OF_PLUGINS
do
        find ${WORKSPACE}/$plugin/* -maxdepth 0 -type d -exec sh -c "cd {}; /usr/bin/ant $1" \;
done