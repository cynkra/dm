test_src_df <- function() {
  NULL
}

test_src_sqlite <- function() {
  testthat::skip_if_not_installed("DBI")
  testthat::skip_if_not_installed("dbplyr")
  testthat::skip_if_not_installed("RSQLite")
  dbplyr::src_dbi(
    DBI::dbConnect(RSQLite::SQLite(), ":memory:"),
    auto_disconnect = TRUE
  )
}

test_src_duckdb <- function() {
  testthat::skip_if_not_installed("DBI")
  testthat::skip_if_not_installed("dbplyr")
  testthat::skip_if_not_installed("duckdb")
  dbplyr::src_dbi(DBI::dbConnect(duckdb::duckdb()), auto_disconnect = TRUE)
}

test_src_postgres <- function() {
  # Check for PostgreSQL-specific host first, then fall back to general docker host
  postgres_host <- Sys.getenv("DM_TEST_POSTGRES_HOST")
  docker_host <- Sys.getenv("DM_TEST_DOCKER_HOST")

  if (postgres_host != "" || docker_host != "") {
    host <- if (postgres_host != "") postgres_host else docker_host
    con <- DBI::dbConnect(
      RPostgres::Postgres(),
      host = host,
      user = "compose",
      password = "YourStrong!Passw0rd"
    )
  } else {
    con <- DBI::dbConnect(RPostgres::Postgres())
  }
  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}

test_src_maria <- function(root = FALSE) {
  # Check for MariaDB-specific host first, then fall back to general docker host
  maria_host <- Sys.getenv("DM_TEST_MARIA_HOST")
  docker_host <- Sys.getenv("DM_TEST_DOCKER_HOST")

  if (maria_host != "" || docker_host != "") {
    host <- if (maria_host != "") maria_host else docker_host
    con <- DBI::dbConnect(
      RMariaDB::MariaDB(),
      host = host,
      username = if (root) "root" else "compose",
      password = "YourStrong!Passw0rd",
      dbname = "test"
    )
  } else {
    con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname = "test")
  }
  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}

test_src_mssql <- function(database = TRUE) {
  if (Sys.getenv("DM_TEST_DOCKER_HOST") != "") {
    con <- DBI::dbConnect(
      odbc::odbc(),
      driver = "ODBC Driver 18 for SQL Server",
      server = Sys.getenv("DM_TEST_DOCKER_HOST"),
      database = if (database) "test",
      uid = "SA",
      pwd = "YourStrong!Passw0rd",
      port = 1433,
      TrustServerCertificate = "yes"
    )
  } else if (Sys.getenv("CI") != "") {
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

  DBI::dbExecute(con, "SET IMPLICIT_TRANSACTIONS OFF", immediate = TRUE)

  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}
