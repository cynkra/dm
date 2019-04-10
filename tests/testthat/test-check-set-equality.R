context("test-check-set-equality")

test_that("check_set_equality() checks properly if 2 sets of values are equal?", {

  map2(
    .x = data_1_src,
    .y = data_3_src,
    ~ expect_silent(
      check_set_equality(.x, a, .y, a)
      )
    )

  map2(
    .x = data_1_src,
    .y = data_2_src,
    ~ expect_error(
      check_set_equality(.x, a, .y, a),
      "Column `a` in table `.y` contains values \\(see above\\) that are not present in column `a` in table `.x`"
    )
  )
})
