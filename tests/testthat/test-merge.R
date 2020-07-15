test_that("dm_merge() works?", {
  expect_equivalent_dm(
    dm_merge(dm_for_filter()),
    dm_for_filter()
  )

  expect_equivalent_dm(
    dm_merge(dm_for_filter(), dm_for_flatten(), dm_for_filter()),
    bind_rows(
      dm_get_def(dm_for_filter()),
      dm_get_def(dm_for_flatten()),
      dm_get_def(dm_for_filter())
    ) %>%
      new_dm3()
  )
})

test_that("are empty_dm() handled correctly?", {
  expect_equivalent_dm(
    dm_merge(empty_dm()),
    empty_dm()
  )

  expect_equivalent_dm(
    dm_merge(empty_dm(), empty_dm(), empty_dm()),
    empty_dm()
  )
})

test_that("error if empty ellipsis", {
  expect_error(
    dm_merge(),
    class = dm_error_full("empty_ellipsis")
  )
})
