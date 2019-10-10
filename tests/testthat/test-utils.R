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

test_that("default_local_src() works", {
  expect_identical(
    default_local_src(),
    src_df(env = .GlobalEnv)
  )
})
