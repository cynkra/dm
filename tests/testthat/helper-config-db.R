test_src_df <- function() {
  default_local_src()
}

test_src_sqlite <- function() {
  src_dbi(DBI::dbConnect(RSQLite::SQLite(), ":memory:"), auto_disconnect = TRUE)
}

test_src_postgres <- function() {
  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = "postgres", host = "localhost", port = 5432,
    user = "postgres", bigint = "integer"
  )
  src_dbi(con, auto_disconnect = TRUE)
}

test_src_mssql <- function() {
  source("/Users/tobiasschieferdecker/git/cynkra/dm/.Rprofile")
  con_mssql <- mssql_con()
  src_mssql <- src_dbi(con_mssql, auto_disconnect = TRUE)
}
