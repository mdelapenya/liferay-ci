#!/bin/bash
MODBC="$1"
MUSER="$2"
MPASS="$3"
MDB="$4"

# Detect the paths for the SQLServer command
TSQL=$(which tsql)

if [ $# -ne 4 ]
then
        echo "Usage: $0 {SQL Server-ODBC-Name}{SQL Server-UserName}{SQL Server-Password}{SQL Server-Database-Name}"
        echo "Deletes and (re) create the indicated database"
        exit 1
fi

DB_ODBC_NAME=${MODBC}
DB_USER=${MUSER}
DB_PWD=${MPASS}
DB_NAME=${MDB}

TMP_FILE="/tmp/input.sql"

touch ${TMP_FILE}

echo "USE [master]" > ${TMP_FILE}
echo "GO" >> ${TMP_FILE}
echo "DROP DATABASE [${DB_NAME}]" >> ${TMP_FILE}
echo "GO" >> ${TMP_FILE}
echo "CREATE DATABASE [${DB_NAME}]" >> ${TMP_FILE}
echo "GO" >> ${TMP_FILE}

cat ${TMP_FILE} | ${TSQL} -S ${DB_ODBC_NAME} -U ${DB_USER} -P ${DB_PWD}

rm ${TMP_FILE}