test_that("dummy", {
  expect_snapshot({
    "dummy"
  })
})

test_that("dm_sql()", {
  # Need skip in every test block, unfortunately
  skip_if_src_not("mssql")

  expect_snapshot({
    dm_for_filter() %>%
      collect() %>%
      dm_sql(my_test_con())
  })
})
