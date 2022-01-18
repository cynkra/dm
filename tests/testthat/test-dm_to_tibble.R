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
