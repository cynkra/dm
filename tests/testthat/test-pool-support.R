test_that("dm_from_src supports 'Pool'", {
  # expect no error
  conn <- pool::dbPool(RSQLite::SQLite(), "", timeout = 10)
  DBI::dbWriteTable(conn, "mtcars", mtcars)
  dm <- dm::dm_from_src(conn, learn_keys = FALSE)
  expect_identical(names(dm), "mtcars")
})
