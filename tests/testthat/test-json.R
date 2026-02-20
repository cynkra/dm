test_that("json joins work", {
  df1 <- tibble(col1 = 1:2, key = letters[1:2])
  df2 <- tibble(col2 = c(3:4, pi), col3 = c("X", "Y", "Z"), key = letters[c(1, 1:2)])

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

  # Make sure precision is not lost in JSON conversion
  packed <- json_pack_join(df1, df2, by = "key")
  nested <- json_nest_join(df1, df2, by = "key")
  expect_equal(jsonlite::fromJSON(packed$df2[[3]])[["col2"]], pi)
  expect_equal(jsonlite::fromJSON(nested$df2[[2]])[["col2"]], pi)
})
