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

  # to tibble
  expect_snapshot({
    tbl <- dm_to_tibble(dm_for_filter(), tf_4)
    tbl
    tbl$tf_3$tf_2[[3]]
    tbl$tf_5[[2]]
  })

  # back to dm
  expect_snapshot({
    dm2 <- tibble_to_dm(tbl, dm_for_filter())
    dm2
    dm2$tf_4
    dm2$tf_1
    dm2$tf_6
  })

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_1, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- tibble_to_dm(dm_to_tibble(dm, tf_1), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_2, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- tibble_to_dm(dm_to_tibble(dm, tf_2), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_3, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- tibble_to_dm(dm_to_tibble(dm, tf_3), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_4, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- tibble_to_dm(dm_to_tibble(dm, tf_4), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_5, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- tibble_to_dm(dm_to_tibble(dm, tf_5), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_6, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- tibble_to_dm(dm_to_tibble(dm, tf_6), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)
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

  expect_snapshot({
    dm_wrapped <- dm_wrap(dm_for_filter(), tf_1)
    dm_wrapped
    dm_wrapped$tf_2
  })
  expect_error(dm_wrap(dm_for_filter(), tf_2), "not a terminal parent or child table")

  expect_snapshot({
    dm_unwrapped <- dm_unwrap(dm_wrap(dm_for_filter(), tf_1), tf_2, dm_for_filter())
    dm_unwrapped
    dm_unwrapped$tf_1
  })

  # nothing to unwrap = no op
  expect_identical(
    dm_unwrap(dm_wrap(dm_for_filter(), tf_1), tf_3, dm1),
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

  expect_snapshot({
    dm_packed <- dm_pack_wrap(dm1, tf_1)
    dm_packed

    dm_packed_nested <- dm_nest_wrap(dm_packed, tf_2)
    dm_packed_nested

    dm_packed_nested_unnested <- dm_unnest_unwrap(dm_packed_nested, tf_3, tf_2, dm1)
    dm_packed_nested_unnested

    dm_packed_nested_unnested_unpacked <- dm_unpack_unwrap(dm_packed_nested_unnested, tf_2, tf_1, dm1)
    dm_packed_nested_unnested_unpacked
  })

  # trying to unpack or unnest a column that doesn't exist gives informative error
  expect_error(dm_unpack_unwrap(dm1, tf_2, tf_1, dm1), "Column `tf_1` doesn't exist")
  expect_error(dm_unnest_unwrap(dm1, tf_2, tf_1, dm1), "Column `tf_1` doesn't exist")
})
