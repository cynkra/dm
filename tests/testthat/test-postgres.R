test_that("dummy", {
  expect_snapshot({
    "dummy"
  })
})

test_that("snapshot test", {
  skip_if_src_not("postgres")

  expect_snapshot({
    dm_for_filter() %>%
      collect() %>%
      dm_sql(my_test_con())
  })
})
