#!/bin/bash

# Check if the Docker container named 'msql' exists
if docker ps -a --format '{{.Names}}' | grep -q "^mssql$"; then
    echo "Container 'msql' exists. Proceeding..."
    # Commands to execute if the container exists
    docker exec -it rdm R -q -e 'suppressMessages(pkgload::load_all());
    DBI::dbExecute(DBI::dbConnect(
      odbc::odbc(),
      driver = "ODBC Driver 18 for SQL Server",
      server = "mssql",
      uid = "SA",
      pwd = "YourStrong!Passw0rd",
      port = 1433,
      TrustServerCertificate = "yes"), "CREATE DATABASE test")' #>/dev/null 2>&1 || true
else
    echo "Container 'msql' does not exist."
    # Commands to execute if the container does not exist
fi

#!/bin/bash

# Check if the Docker container named 'msql' exists
if docker ps -a --format '{{.Names}}' | grep -q "^oracle$"; then
    echo "Container 'oracle' exists. Proceeding..."
    # Commands to execute if the container exists
    # Wait for the Oracle database to fully initialize
    echo "Waiting for the Oracle database to start..."
    sleep 10

    SQL0='alter session set "_ORACLE_SCRIPT"=true;
    CREATE USER compose IDENTIFIED BY password1;
    GRANT ALL PRIVILEGES TO compose;
    exit;
    '
    docker exec -it -e SQL0="$SQL0" oracle bash -c 'echo "$SQL0" | sqlplus SYS/Oradoc_db1 AS SYSDBA'.

else
    echo "Container 'oracle' does not exist."
    # Commands to execute if the container does not exist
fi

