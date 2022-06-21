test_that("dummy", {
  # To avoid deletion of file
  expect_snapshot({
    TRUE
  })
})

test_that("dm_meta() data model", {
  skip_if_src_not(c("mssql", "postgres", "maria"))

  expect_snapshot({
    dm_meta(my_test_src()) %>%
      dm_paste(options = c("select", "keys", "color"))
  })
})

test_that("dm_meta(simple = TRUE) columns", {
  tryCatch(
    columns <-
      my_db_test_src() %>%
      dm_meta(simple = TRUE) %>%
      .$columns %>%
      filter(tolower(table_schema) == "information_schema") %>%
      arrange(table_name, ordinal_position) %>%
      select(-table_catalog) %>%
      collect(),
    error = function(e) {
      skip(conditionMessage(e))
    }
  )

  path <- tempfile(fileext = ".csv")
  write.csv(columns, path, na = "")

  expect_snapshot_file(path, name = "columns.csv", variant = my_test_src_name)
})
