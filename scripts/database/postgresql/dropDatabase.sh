#!/bin/bash
MUSER="$1"
MPASS="$2"
MDB="$3"
 
# Detect the paths for the PostgreSQL command
POSTGRESQL=$(which psql)
 
if [ $# -ne 3 ]
then
	echo "Usage: $0 {PostgreSQL-User-Name}{PostgreSQL-Password}{PostgreSQL-Database-Name}"
	echo "Deletes and (re) create the indicated database"
	exit 1
fi

echo "Deleting database $MDB ..."
$POSTGRESQL -U $MUSER -c "DROP DATABASE $MDB"
echo "Creating the database $MDB . . ."
$POSTGRESQL -U $MUSER -c "CREATE DATABASE ${MDB} ENCODING = 'UTF8'"
echo "Database $MDB has been created" 
