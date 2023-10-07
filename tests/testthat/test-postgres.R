skip_if_src_not("postgres")

test_that("snapshot test", {
  expect_snapshot({
    dm_for_filter() %>%
      dm_sql(my_test_con())
  })
})
