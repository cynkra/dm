test_src_df <- function() {
  NULL
}

test_src_sqlite <- function() {
  dbplyr::src_dbi(DBI::dbConnect(RSQLite::SQLite(), ":memory:"), auto_disconnect = TRUE)
}

test_src_duckdb <- function() {
  dbplyr::src_dbi(DBI::dbConnect(duckdb::duckdb()), auto_disconnect = TRUE)
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
  if (Sys.getenv("CI") != "") {
    con <- DBI::dbConnect(
      odbc::odbc(),
      "mssql-test",
      uid = "SA",
      pwd = "YourStrong!Passw0rd",
      port = 1433
    )
  } else {
    con <- DBI::dbConnect(
      odbc::odbc(),
      "dm-test",
      uid = keyring::key_get("mssql", "dm-test-user"),
      pwd = keyring::key_get("mssql", "dm-test-password")
    )
  }

  dbExecute(con, "SET IMPLICIT_TRANSACTIONS OFF", immediate = TRUE)

  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}
