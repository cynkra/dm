test_src_df <- function() {
  default_local_src()
}

test_src_sqlite <- function() {
  dbplyr::src_dbi(DBI::dbConnect(RSQLite::SQLite(), ":memory:"), auto_disconnect = TRUE)
}

test_src_postgres <- function() {
  con <- DBI::dbConnect(RPostgres::Postgres())
  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}

test_src_maria <- function() {
  con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname = "test")
  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}

test_src_mssql <- function() {
  con <- DBI::dbConnect(
    odbc::odbc(),
    "mssql-test",
    uid = "kirill", pwd = keyring::key_get("mssql", "kirill")
  )
  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}
