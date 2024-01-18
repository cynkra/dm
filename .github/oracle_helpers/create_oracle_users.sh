#!/bin/bash

# adding users through compose does not work
# tried different options, this is the one that finally worked...

# Wait for the Oracle database to fully initialize
echo "Waiting for the Oracle database to start..."
sleep 30

SQL0='alter session set "_ORACLE_SCRIPT"=true;
CREATE USER compose IDENTIFIED BY password1;
GRANT ALL PRIVILEGES TO compose;
exit;
'
docker exec -it -e SQL0="$SQL0" oracle bash -c 'echo "$SQL0" | sqlplus SYS/Oradoc_db1 AS SYSDBA'

