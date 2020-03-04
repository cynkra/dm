test_that("utils-methods work", {
  skip("`head.zoomed_dm()` and `tail.zoomed_dm()` NYI")
  expect_identical(
    zoomed_dm %>% head(3) %>% get_zoomed_tbl(),
    head(t2, 3)
  )

  expect_identical(
    zoomed_dm %>% tail(2) %>% get_zoomed_tbl(),
    tail(t2, 2)
  )
})
