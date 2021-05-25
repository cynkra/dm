
testthat::test_that("testthat wrappers return the object", {
  expect_equal(
    expect_message_obj({message("abc");"foo"}, "a"),
    "foo"
  )
  expect_equal(
    expect_warning_obj({warning("abc");"foo"}, "a"),
    "foo"
  )
  expect_equal(
    expect_condition_obj({message("abc");"foo"}, "a"),
    "foo"
  )
})
