test_that("snapshot test", {
  skip_if_src_not(c("df", "duckplyr"))

  expect_snapshot({
    dm_for_filter() %>%
      dm_sql(test_src_duckdb()$con)
  })
})
