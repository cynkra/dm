test_that("dummy", {
  # To avoid deletion of file
  expect_snapshot({
    TRUE
  })
})

test_that("dm_meta() data model", {
  skip_if_src_not(c("mssql", "postgres"))

  expect_snapshot({
    dm_meta(my_test_src()) %>%
      dm_paste(options = c("select", "keys", "color"))
  })
})
