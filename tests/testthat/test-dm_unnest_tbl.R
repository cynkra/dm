test_that("`dm_unnest_tbl()` and `dm_unpack_tbl()` failure modes", {
  skip_if_remote_src()

  # trying to unpack or unnest a column that doesn't exist gives informative error
  expect_error(dm_unnest_tbl(dm_for_filter(), tf_2, tf_1, dm_for_filter()), "Column `tf_1` doesn't exist")
})

test_that("`dm_unpack_tbl()` failure modes", {
  skip_if_remote_src()

  # trying to unpack a column that doesn't exist gives informative error
  expect_error(dm_unpack_tbl(dm_for_filter(), tf_2, tf_1, dm_for_filter()), "Column `tf_1` doesn't exist")
})
