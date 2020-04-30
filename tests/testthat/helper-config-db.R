test_src_df <- function() {
  default_local_src()
}

test_src_sqlite <- function() {
  src_dbi(DBI::dbConnect(RSQLite::SQLite(), ":memory:"), auto_disconnect = TRUE)
}

test_src_postgres <- function() {
  con <- DBI::dbConnect(RPostgres::Postgres())
  src_dbi(con, auto_disconnect = TRUE)
}

test_src_maria <- function() {
  con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname = "test")
  src_dbi(con, auto_disconnect = TRUE)
}

test_src_mssql <- function() {
  con <- DBI::dbConnect(
    odbc::odbc(),
    "mssql-test",
    uid = "kirill", pwd = keyring::key_get("mssql", "kirill")
  )
  src_dbi(con, auto_disconnect = TRUE)
}
