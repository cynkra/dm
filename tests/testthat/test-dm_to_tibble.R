test_that("`node_type_from_graph()` works", {
  dm1 <- dm_for_filter()
  graph <- create_graph_from_dm(dm1, directed = TRUE)
  expect_snapshot({
    node_type_from_graph(graph)
  })
  expect_snapshot({
    node_type_from_graph(graph, drop = "tf_4")
  })
})

test_that("`dm_to_tibble()`/`tibble_to_dm()` round trip works", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()

  # to tibble
  tbl <- dm_to_tibble(dm1, tf_4)
  expect_snapshot({
    tbl
  })
  expect_snapshot({
    tbl$tf_3$tf_2[[3]]
  })
  expect_snapshot({
    tbl$tf_5[[2]]
  })

  # back to dm
  dm2 <- tibble_to_dm(tbl, dm1)
  expect_snapshot({
    dm2
  })
  expect_snapshot({
    dm2$tf_4
  })
  expect_snapshot({
    dm2$tf_1
  })
  expect_snapshot({
    dm2$tf_6
  })

  expect_snapshot({
    waldo::compare(dm_ptype(dm1), dm_ptype(dm2))
  })
})

test_that("`dm_wrap_all()` and `dm_unwrap_all()` work", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()
  dm_wrapped <- dm_wrap_all(dm1, tf_4)
  expect_length(dm_wrapped, 1)
  expect_equal(names(dm_wrapped), "tf_4")
  tibble_from_dm <- dm_to_tibble(dm1, tf_4)
  expect_identical(dm_wrapped$tf_4, tibble_from_dm)
  dm_unwrapped <- dm_unwrap_all(dm_wrapped, dm1)
  expect_identical(dm_unwrapped, tibble_to_dm(tibble_from_dm, dm1))
})

test_that("`dm_wrap()` and `dm_unwrap()` work", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()
  dm_wrapped <- dm_wrap(dm1, tf_1)
  expect_snapshot(dm_wrapped)
  expect_snapshot(dm_wrapped$tf_2)
  expect_error(dm_wrap(dm1, tf_2), "not a terminal parent or child table")

  dm_unwrapped <- dm_unwrap(dm_wrapped, tf_2, dm1)
  expect_snapshot(dm_unwrapped)
  expect_snapshot(dm_unwrapped$tf_1)

  # nothing to unwrap = no op
  expect_identical(
    dm_unwrap(dm_wrapped, tf_3, dm1),
    dm_wrapped
  )
})

test_that("`dm_pack_wrap()`, `dm_unpack_unwrap()`, `dm_nest_wrap()`, `dm_unnest_unwrap()` work", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()

  # is terminal parent
  expect_error(dm_nest_wrap(dm1, tf_1), "not a terminal child table")
  # has several parents
  expect_error(dm_nest_wrap(dm1, tf_2), "not a terminal child table")
  # has several children
  expect_error(dm_nest_wrap(dm1, tf_3), "not a terminal child table")
  # has both parent and child
  expect_error(dm_nest_wrap(dm1, tf_4), "not a terminal child table")

  # has several parents
  expect_error(dm_pack_wrap(dm1, tf_2), "not a terminal parent table")
  # has several children
  expect_error(dm_pack_wrap(dm1, tf_3), "not a terminal parent table")
  # has both parent and child
  expect_error(dm_pack_wrap(dm1, tf_4), "not a terminal parent table")

  dm_packed <- dm_pack_wrap(dm1, tf_1)
  expect_snapshot(dm_packed)

  dm_packed_nested <- dm_nest_wrap(dm_packed, tf_2)
  expect_snapshot(dm_packed_nested)

  dm_packed_nested_unnested <- dm_unnest_unwrap(dm_packed_nested, tf_3, tf_2, dm1)
  expect_snapshot(dm_packed_nested_unnested)

  dm_packed_nested_unnested_unpacked <-
    dm_unpack_unwrap(dm_packed_nested_unnested, tf_2, tf_1, dm1)
  expect_snapshot(dm_packed_nested_unnested_unpacked)

  # trying to unpack or unnest a column that doesn't exist gives informative error
  expect_error(dm_unpack_unwrap(dm1, tf_2, tf_1, dm1), "Column `tf_1` doesn't exist")
  expect_error(dm_unnest_unwrap(dm1, tf_2, tf_1, dm1), "Column `tf_1` doesn't exist")
})
