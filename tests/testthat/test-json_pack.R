test_that("`json_pack()` works", {
  expect_snapshot({
    df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
    packed <- json_pack(df, x = c(x1, x2, x3), y = y)
    packed
  })
})
