test_that("json joins work", {
  skip_if_not_installed("rlang", "0.99.0.9003")

  df1 <- tibble(col1 = 1:2, key = letters[1:2])
  df2 <- tibble(col2 = 3:5, col3 = c("X", "Y", "Z"), key = letters[c(1,1:2)])

  expect_snapshot({
    packed <- json_pack_join(df1, df2, by = "key")
    packed
    packed$df2
    })
  expect_snapshot({
    nested <- json_nest_join(df1, df2, by = "key")
    nested
    nested$df2
    })
})
