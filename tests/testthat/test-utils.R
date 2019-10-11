test_that("commas() works", {
  expect_equal(
    str_count(commas(fact$fact), ","),
    MAX_COMMAS - 1
  )
  expect_identical(
    str_count(commas(fact$fact), fixed(cli::symbol$ellipsis)),
    1L
  )
})

test_that("default_local_src() works", {
  expect_identical(
    default_local_src(),
    src_df(env = .GlobalEnv)
  )
})
