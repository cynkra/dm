# Extracted from test-learn.R:191

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
con_sqlite <- skip_if_error(DBI::dbConnect(RSQLite::SQLite(), ":memory:"))
withr::defer(DBI::dbDisconnect(con_sqlite))
DBI::dbExecute(con_sqlite, "CREATE TABLE first (id INTEGER PRIMARY KEY)")
DBI::dbExecute(con_sqlite, paste(
    "CREATE TABLE second (",
    "id INTEGER PRIMARY KEY, first_id INTEGER,",
    "FOREIGN KEY (first_id) REFERENCES first (id))"
  ))
DBI::dbExecute(con_sqlite, paste(
    "CREATE TABLE third (",
    "id INTEGER PRIMARY KEY, first_id INTEGER, second_id INTEGER,",
    "FOREIGN KEY (first_id) REFERENCES first (id),",
    "FOREIGN KEY (second_id) REFERENCES second (id))"
  ))
learned_dm <- dm_from_con(con_sqlite, learn_keys = TRUE) %>%
    collect()
