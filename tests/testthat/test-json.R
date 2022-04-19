test_that("json joins work", {
  skip_if_not_installed("rlang", "0.99.0.9003")

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

test_that("`json_pack()` works", {
  skip_if_not_installed("rlang", "0.99.0.9003")

  expect_snapshot({
    df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
    packed <- json_pack(df, x = c(x1, x2, x3), y = y)
    packed
  })
})

test_that("`json_nest()` works", {
  skip_if_not_installed("rlang", "0.99.0.9003")

  expect_snapshot({
    df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
    nested <- json_nest(df, data = c(y, z))
    nested
  })
})
