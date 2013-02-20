#!/bin/bash
MHOST="$1"
MUSER="$2"
MPASS="$3"
MDB="$4"
 
# Detect the paths for the MySQL command
MYSQL=$(which mysql)
 
if [ $# -ne 4 ]
then
	echo "Usage: $0 {Database hostname}{MySQL-User-Name}{MySQL-Password}{MySQL-Database-Name}"
	echo "Deletes and (re) create the indicated database"
	exit 1
fi

echo "Deleting database $MDB ..."
$MYSQL -h $MHOST -u$MUSER -p$MPASS -e "DROP SCHEMA $MDB"
echo "Creating the schema $MDB . . ."
$MYSQL -h $MHOST -u$MUSER -p$MPASS -e "CREATE SCHEMA $MDB DEFAULT CHARACTER SET utf8 ;"
echo "Database $MDB has been created" 
