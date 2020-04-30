test_that("commas() works", {
  skip_if_remote_src()
  expect_equal(
    # `strsplit()` creates vector, which is 1 longer than number of split-characters found
    length(strsplit(commas(fact()$fact), ",")[[1]]),
    MAX_COMMAS
  )
  expect_identical(
    length(strsplit(commas(fact()$fact), cli::symbol$ellipsis, fixed = TRUE)[[1]]) - 1L,
    1L
  )
})

test_that("default_local_src() works", {
  expect_s3_class(default_local_src(), "src")
})
