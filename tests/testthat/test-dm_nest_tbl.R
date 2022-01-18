test_that("`dm_nest_tbl()` failure modes", {
  skip_if_remote_src()

  # is terminal parent
  expect_error(dm_nest_tbl(dm_for_filter(), tf_1), "not a terminal child table")
  # has several parents
  expect_error(dm_nest_tbl(dm_for_filter(), tf_2), "not a terminal child table")
  # has several children
  expect_error(dm_nest_tbl(dm_for_filter(), tf_3), "not a terminal child table")
  # has both parent and child
  expect_error(dm_nest_tbl(dm_for_filter(), tf_4), "not a terminal child table")
})

test_that("`dm_pack_tbl()`, `dm_unpack_tbl()`, `dm_nest_tbl()`, `dm_unnest_tbl()` work", {
  skip_if_remote_src()

  expect_snapshot({
    dm_packed <- dm_pack_tbl(dm_for_filter(), tf_1)
    dm_packed

    dm_packed_nested <- dm_nest_tbl(dm_packed, tf_2)
    dm_packed_nested

    dm_packed_nested_unnested <- dm_unnest_tbl(dm_packed_nested, tf_3, tf_2, prototype = dm_for_filter())
    dm_packed_nested_unnested

    dm_packed_nested_unnested_unpacked <- dm_unpack_tbl(dm_packed_nested_unnested, tf_2, tf_1, prototype = dm_for_filter())
    dm_packed_nested_unnested_unpacked
  })
})

test_that("`dm_pack_tbl()` failure modes", {
  # has several parents
  expect_error(dm_pack_tbl(dm_for_filter(), tf_2), "not a terminal parent table")
  # has several children
  expect_error(dm_pack_tbl(dm_for_filter(), tf_3), "not a terminal parent table")
  # has both parent and child
  expect_error(dm_pack_tbl(dm_for_filter(), tf_4), "not a terminal parent table")
})

test_that("`dm_pack_tbl()`, `dm_unpack_tbl()`, `dm_nest_tbl()`, `dm_unnest_tbl()` work", {
  skip_if_remote_src()

  expect_snapshot({
    dm_packed <- dm_pack_tbl(dm_for_filter(), tf_1)
    dm_packed

    dm_packed_nested <- dm_nest_tbl(dm_packed, tf_2)
    dm_packed_nested

    dm_packed_nested_unnested <- dm_unnest_tbl(dm_packed_nested, tf_3, tf_2, prototype = dm_for_filter())
    dm_packed_nested_unnested

    dm_packed_nested_unnested_unpacked <- dm_unpack_tbl(dm_packed_nested_unnested, tf_2, tf_1, prototype = dm_for_filter())
    dm_packed_nested_unnested_unpacked
  })
})
