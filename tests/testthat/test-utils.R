test_that("commas() works", {
  expect_identical(
    str_count(commas(fact$fact), ","),
    6L
  )
  expect_identical(
    str_count(commas(fact$fact), cli::symbol$ellipsis),
    1L
  )
})
