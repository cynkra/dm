test_that("general check-functions work", {
  expect_silent(check_param_class(1, "numeric", "one"))
  expect_dm_error(check_param_class("1", "numeric", "one"), "parameter_not_correct_class")
  expect_silent(check_param_length(1:3, 3, "count_to_three"))
  expect_dm_error(check_param_length(1:4, 3, "count_to_three"), "parameter_not_correct_length")
})
