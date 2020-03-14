test_that("utils-methods work", {
  expect_identical(
    zoomed_dm %>% head(3) %>% get_zoomed_tbl(),
    head(t2, 3)
  )

  expect_identical(
    zoomed_dm %>% tail(2) %>% get_zoomed_tbl(),
    tail(t2, 2)
  )
})
