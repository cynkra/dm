x <- tibble::tibble(
  x_id = integer(0L),
  x_data = character(0L),
)
y <- tibble::tibble(
  y_id = integer(0L),
  x_id = integer(0L),
  y_data = character(0L),
)

dm <- dm(x, y) %>%
  dm_add_pk(x, x_id, autoincrement = TRUE) %>%
  dm_add_pk(y, y_id, autoincrement = FALSE) %>%
  dm_add_fk(y, x_id, x)

test_that("autoincrement produces valid R code", {
  expect_snapshot(dm)
})

test_that("autoincrement produces valid SQL queries and R code - RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite())
  df <- dm:::build_copy_queries(con, dm)

  expect_snapshot(df$sql_table)
  expect_snapshot(dm)
})
