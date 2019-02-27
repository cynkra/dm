context("test-check-key")

data <-
  tribble(~c1, ~c2, ~c3,
          1, 2, 3,
          4, 5, 3,
          1, 2, 4)

test_that("check_key() checks primary key properly?", {
  expect_error(check_key(data, c1, c2))
  expect_silent(check_key(data, c1, c3))
  expect_silent(check_key(data, c2, c3))
})
