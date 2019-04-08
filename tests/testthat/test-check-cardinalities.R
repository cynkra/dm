context("test-check-cardinalities")

test_that("check_cardinality_...() functions are checking the cardinality correctly?", {
  # expecting silent:
  expect_silent(check_cardinality_0_n(parent_table = d1, primary_key_column = a, child_table = d3, foreign_key_column = c))
  expect_silent(check_cardinality_1_n(d1, a, d3, c))
  expect_silent(check_cardinality_1_1(d1, a, d3, c))
  expect_silent(check_set_equality(d1, a, d3, c))
  expect_silent(check_cardinality_0_n(d5, a, d4, c))
  expect_silent(check_cardinality_0_1(d5, a, d6, c))

  # expecting errors:
  expect_known_output(
    expect_error(
      check_cardinality_0_n(parent_table = d1, primary_key_column = a, child_table = d2, foreign_key_column = a)
    ),
    "out/card-0-n-d1-d2.txt"
  )

  expect_error(check_cardinality_1_1(d1, a, d4, c))
  expect_error(check_cardinality_1_1(d4, c, d1, a))
  expect_error(check_cardinality_0_1(d1, a, d2, a))
  expect_error(check_cardinality_0_1(d1, a, d4, c))
  expect_error(check_cardinality_0_1(d4, c, d1, a))
  expect_error(check_cardinality_0_n(d4, c, d5, a))
  expect_error(check_cardinality_1_1(d5, a, d4, c))
})
