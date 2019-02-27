context("test-check-overlap")

test_that("check_overlap() checks overlap properly?", {
  expect_error(check_overlap(data_1, a, data_2, a))
  expect_silent(check_overlap(data_1, a, data_3, a))
})
