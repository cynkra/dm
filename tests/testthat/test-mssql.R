test_that("dummy", {
  expect_snapshot({
    "dummy"
  })
})

skip_if_src_not("mssql")

test_that("dm_sql()", {
  expect_snapshot({
    dm_for_filter() %>%
      collect() %>%
      dm_sql(my_test_con())
  })
})
