test_that("snapshot test", {
  skip_if_src_not("df")

  expect_snapshot({
    dm_for_filter() %>%
      dm_sql(test_src_duckdb()$con)
  })
})
