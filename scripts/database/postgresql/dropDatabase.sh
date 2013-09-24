#!/bin/bash
MHOST="$1"
MUSER="$2"
MDB="$3"

# Detect the paths for the PostgreSQL command
POSTGRESQL=$(which psql)

if [ $# -ne 3 ]
then
        echo "Usage: $0 {Database hostname}{PostgreSQL-User}{PostgreSQL-Database-Name}"
        echo "Deletes and (re) create the indicated database"
        exit 1
fi

echo "Deleting database $MDB ..."
$POSTGRESQL -h $MHOST -U postgres -c "DROP DATABASE ${MDB};"
echo "Creating the database $MDB . . ."
$POSTGRESQL -h $MHOST -U postgres -c "CREATE DATABASE ${MDB} WITH OWNER ${MUSER} ENCODING 'UTF8';"
echo "Database $MDB has been created"