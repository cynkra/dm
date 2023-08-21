test_that("dm_from_con() supports 'Pool'", {
  skip_if_not_installed("pool")
  skip_if_not_installed("RSQLite")

  # expect no error
  conn <- pool::dbPool(RSQLite::SQLite(), dbname = "", timeout = 10)
  on.exit(pool::poolClose(conn))
  DBI::dbWriteTable(conn, "mtcars", mtcars)
  dm <- dm::dm_from_con(conn, learn_keys = FALSE)
  expect_identical(names(dm), "mtcars")
})
