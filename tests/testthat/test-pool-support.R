test_that("dm_from_src supports 'Pool'", {
  # expect no error
  expect_error(regexp = NA, {
    conn <- pool::dbPool(RSQLite::SQLite(), "", timeout = 10)
    DBI::dbWriteTable(conn, "mtcars", mtcars)
    thedb_raw <- dm::dm_from_src(conn, learn_keys = FALSE)
  })
})
