test_that("`dm_wrap()` and `dm_unwrap()` work", {
  skip_if_remote_src()

  dm1 <- dm_for_filter()
  dm_wrapped <- dm_wrap(dm1, tf_4, silent = TRUE)
  expect_length(dm_wrapped, 1)
  expect_equal(names(dm_wrapped), "tf_4")
  dm_unwrapped <- dm_unwrap(dm_wrapped, dm1)
  expect_identical(dm_unwrapped, dm_unwrap(dm_wrapped, dm1))

  # to tibble
  expect_snapshot({
    wrapped <- dm_wrap(dm_for_filter(), tf_4)
    wrapped
    wrapped$tf_4
    wrapped$tf_4$tf_3$tf_2[[3]]
    wrapped$tf_4$tf_5[[2]]
  })

  # back to dm
  expect_snapshot({
    unwrapped <- dm_unwrap(dm_wrap(dm_for_filter(), tf_4), dm_for_filter())
    unwrapped
    unwrapped$tf_4
    unwrapped$tf_1
    unwrapped$tf_6
  })
})

test_that("`dm_wrap()` and `dm_unwrap()` round trip", {
  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_1, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- dm_unwrap(dm_wrap(dm, tf_1, silent = TRUE), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_2, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- dm_unwrap(dm_wrap(dm, tf_2, silent = TRUE), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_3, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- dm_unwrap(dm_wrap(dm, tf_3, silent = TRUE), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_4, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- dm_unwrap(dm_wrap(dm, tf_4, silent = TRUE), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_5, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- dm_unwrap(dm_wrap(dm, tf_5, silent = TRUE), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)

  dm <- dm_for_filter()
  reduced_dm <-
    dm %>%
    dm_filter(tf_6, TRUE) %>%
    dm_apply_filters()
  roundtrip_dm <- dm_unwrap(dm_wrap(dm, tf_6, silent = TRUE), dm)
  expect_equivalent_dm(roundtrip_dm, reduced_dm, sort = TRUE, ignore_on_delete = TRUE)
})

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
