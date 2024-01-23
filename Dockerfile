FROM ghcr.io/cynkra/rig-ubuntu:main

RUN mkdir -p /root/workspace

COPY DESCRIPTION /root/workspace

RUN R -q -e 'pak::pak()'

RUN apt-get install -y gnupg lsb-release time

# https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=ubuntu18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

RUN curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18

WORKDIR /opt/oracle/

RUN apt-get update && \
    apt-get install -y libaio1 wget unzip

# Download the Oracle Instant Client and ODBC Drivers
RUN wget https://download.oracle.com/otn_software/linux/instantclient/1921000/instantclient-basic-linux.x64-19.21.0.0.0dbru.zip
RUN wget https://download.oracle.com/otn_software/linux/instantclient/1921000/instantclient-odbc-linux.x64-19.21.0.0.0dbru.zip

RUN unzip instantclient-basic-linux.x64-19.21.0.0.0dbru.zip
RUN unzip instantclient-odbc-linux.x64-19.21.0.0.0dbru.zip
RUN rm instantclient-basic-linux.x64-19.21.0.0.0dbru.zip
RUN rm instantclient-odbc-linux.x64-19.21.0.0.0dbru.zip

RUN sh -c "echo /opt/oracle/instantclient_19_21 > \
      /etc/ld.so.conf.d/oracle-instantclient.conf"
RUN ldconfig

RUN export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_21:$LD_LIBRARY_PATH
RUN export PATH=/opt/oracle/instantclient_19_21:$PATH

# Path to the odbc.ini file
ARG ODBC_FILE="/etc/odbc.ini"

# Create the odbc.ini file if it doesn't exist, and append the required content
RUN mkdir -p $(dirname $ODBC_FILE) && \
    { \
      echo "[oracle]"; \
      echo "Driver      = OracleODBC-19c"; \
<<<<<<< HEAD
      #echo "Server      = 127.0.0.1"; \
      #echo "ServerName  = //127.0.0.1:1521/FREE"; \
      echo "Server      = oracle"; \
      echo "ServerName  = //oracle:1521/FREE"; \
=======
      echo "Server      = 127.0.0.1"; \
      echo "ServerName  = //127.0.0.1:1521/FREE"; \
>>>>>>> 689b4adbe0d200ddecec03ecca68c640a5c176c6
      echo "Port        = 1521"; \
      echo "Database    = FREE"; \
      echo ""; \
    } >> $ODBC_FILE

# Path to the odbc.ini file
ARG ODBCI_FILE="/etc/odbcinst.ini"

# Create the odbc.ini file if it doesn't exist, and append the required content
RUN mkdir -p $(dirname $ODBCI_FILE) && \
    { \
      echo "[OracleODBC-19c]"; \
      echo "Description = Oracle ODBC driver for Oracle 19c"; \
      echo "Driver = /opt/oracle/instantclient_19_21/libsqora.so.19.1"; \
      echo "FileUsage = 1"; \
      echo ""; \
    } >> $ODBCI_FILE


<<<<<<< HEAD
WORKDIR /root/workspace
=======
>>>>>>> 689b4adbe0d200ddecec03ecca68c640a5c176c6


