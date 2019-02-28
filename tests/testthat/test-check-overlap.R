context("test-check-overlap")

test_that("check_set_equality() checks overlap properly?", {
  expect_error(check_set_equality(data_1, a, data_2, a))
  expect_silent(check_set_equality(data_1, a, data_3, a))
})
