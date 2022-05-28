test_that("dm_meta() data model", {
  skip_if_src("df")

  expect_snapshot({
    dm_meta(my_test_src()) %>%
      dm_paste(options = c("select", "keys", "color"))
  })
})
