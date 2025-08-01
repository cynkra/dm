# This file is generated automatically by tools/generate-backend-tests.R
# Do not edit manually - edit the template and regenerate

# Backend-specific tests for SQL Server
test_that("dummy", {
  # To avoid deletion of file
  expect_snapshot({
    TRUE
  })
})

test_that("dm_meta() data model", {
  skip_if_schema_not_supported()

  expect_snapshot({
    dm_meta(test_src_mssql()) %>%
      dm_paste(options = c("select", "keys", "color"))
  })
})

test_that("dm_meta(simple = TRUE) columns", {
  # Still stored as snapshot in columns.csv, never cleared
  skip("Dependent on database version, find better way to record this info")

  columns <- tryCatch(
    test_src_mssql() %>%
      dm_meta(simple = TRUE) %>%
      .$columns %>%
      filter(tolower(table_schema) == "information_schema") %>%
      arrange(table_name, ordinal_position) %>%
      select(-table_catalog) %>%
      collect(),
    error = function(e) {
      data.frame(error = conditionMessage(e))
    }
  )

  path <- withr::local_tempfile(fileext = ".csv")
  write.csv(columns, path, na = "")

  expect_snapshot_file(path, name = "columns.csv", variant = "mssql")
})
