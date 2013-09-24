#!/bin/bash
MHOST="$1"
MUSER="$2"
MPASS="$3"
MDB="$4"
 
# Detect the paths for the PostgreSQL command
POSTGRESQL=$(which psql)
 
if [ $# -ne 4 ]
then
	echo "Usage: $0 {Hostname}{PostgreSQL-User-Name}{PostgreSQL-Password}{PostgreSQL-Database-Name}"
	echo "Deletes and (re) create the indicated database"
	exit 1
fi

echo "Deleting database $MDB ..."
$POSTGRESQL -h ${MHOST} -U $MUSER -c "DROP DATABASE $MDB"
echo "Creating the database $MDB . . ."
$POSTGRESQL -h ${MHOST} -U $MUSER -c "CREATE DATABASE ${MDB} ENCODING = 'UTF8'"
echo "Database $MDB has been created"