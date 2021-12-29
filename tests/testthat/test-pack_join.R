test_that("`pack_join()` works", {
  df1 <- tibble(col1 = 1:2, key = letters[1:2])
  df2 <- tibble(col2 = 3:4, key = letters[1:2])
  df3 <- tibble(col3 = 3:4, key3 = letters[1:2])
  expect_snapshot(pack_join(df1, df2))
  expect_snapshot(pack_join(df1, df2, name = "packed_col"))
  expect_snapshot(pack_join(df1, df3, by = c(key = "key3")))
  expect_snapshot(pack_join(df1, df3, by = c(key = "key3"), keep = TRUE))
})
