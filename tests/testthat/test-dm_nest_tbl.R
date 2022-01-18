test_that("`dm_pack_tbl()`, `dm_unpack_tbl()`, `dm_nest_tbl()`, `dm_unnest_tbl()` work", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()

  # is terminal parent
  expect_error(dm_nest_tbl(dm1, tf_1), "not a terminal child table")
  # has several parents
  expect_error(dm_nest_tbl(dm1, tf_2), "not a terminal child table")
  # has several children
  expect_error(dm_nest_tbl(dm1, tf_3), "not a terminal child table")
  # has both parent and child
  expect_error(dm_nest_tbl(dm1, tf_4), "not a terminal child table")

  # has several parents
  expect_error(dm_pack_tbl(dm1, tf_2), "not a terminal parent table")
  # has several children
  expect_error(dm_pack_tbl(dm1, tf_3), "not a terminal parent table")
  # has both parent and child
  expect_error(dm_pack_tbl(dm1, tf_4), "not a terminal parent table")

  expect_snapshot({
    dm_packed <- dm_pack_tbl(dm1, tf_1)
    dm_packed

    dm_packed_nested <- dm_nest_tbl(dm_packed, tf_2)
    dm_packed_nested

    dm_packed_nested_unnested <- dm_unnest_tbl(dm_packed_nested, tf_3, tf_2, prototype = dm1)
    dm_packed_nested_unnested

    dm_packed_nested_unnested_unpacked <- dm_unpack_tbl(dm_packed_nested_unnested, tf_2, tf_1, prototype = dm1)
    dm_packed_nested_unnested_unpacked
  })

  # trying to unpack or unnest a column that doesn't exist gives informative error
  expect_error(dm_unpack_tbl(dm1, tf_2, tf_1, dm1), "Column `tf_1` doesn't exist")
  expect_error(dm_unnest_tbl(dm1, tf_2, tf_1, dm1), "Column `tf_1` doesn't exist")
})
