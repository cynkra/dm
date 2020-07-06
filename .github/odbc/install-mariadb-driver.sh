# from https://mariadb.com/kb/en/about-mariadb-connector-odbc/#installing-mariadb-connectorodbc-on-debianubuntu
mkdir odbc_package
pushd odbc_package
wget https://downloads.mariadb.com/Connectors/odbc/connector-odbc-3.1.7/mariadb-connector-odbc-3.1.7-ga-debian-x86_64.tar.gz
tar -xvzf mariadb-connector-odbc-3.1.7-ga-debian-x86_64.tar.gz
sudo install lib/libmaodbc.so /usr/lib/
sudo install -d /usr/lib/mariadb/
sudo install -d /usr/lib/mariadb/plugin/
sudo install lib/mariadb/plugin/auth_gssapi_client.so /usr/lib/mariadb/plugin/
sudo install lib/mariadb/plugin/caching_sha2_password.so /usr/lib/mariadb/plugin/
sudo install lib/mariadb/plugin/client_ed25519.so /usr/lib/mariadb/plugin/
sudo install lib/mariadb/plugin/dialog.so /usr/lib/mariadb/plugin/
sudo install lib/mariadb/plugin/mysql_clear_password.so /usr/lib/mariadb/plugin/
sudo install lib/mariadb/plugin/sha256_password.so /usr/lib/mariadb/plugin/
popd
rm -r odbc_package
