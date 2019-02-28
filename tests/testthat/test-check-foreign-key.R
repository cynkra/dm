context("test-check-foreign-key")

test_that("check_foreign_key() checks foreign key property properly?", {
  expect_silent(check_if_subset(data_1, a, data_2, a))
  expect_error(check_if_subset(data_2, a, data_1, a))
})
