test_that("functions working with graphs do the right thing?", {
  join_list_tbl_1 <- tibble(
    lhs = c("tf_2", "tf_3", "tf_4", "tf_5", "tf_6"),
    rhs = c("tf_1", "tf_2", "tf_3", "tf_4", "tf_5"),
    rank = as.numeric(2:6),
    has_father = rep(TRUE, 5)
  )

  join_list_tbl_3 <- tibble::tribble(
    ~lhs,     ~rhs, ~rank, ~has_father,
    "tf_2", "tf_3",     2,        TRUE,
    "tf_4", "tf_3",     3,        TRUE,
    "tf_1", "tf_2",     4,        TRUE,
    "tf_5", "tf_4",     5,        TRUE,
    "tf_6", "tf_5",     6,        TRUE
  )

  expect_identical_graph(
    igraph::graph_from_data_frame(
      tibble(
        tables = c("tf_1", "tf_2", "tf_2", "tf_3", "tf_4", "tf_5", "tf_6"),
        ref_tables = c("tf_2", "tf_7", "tf_3", "tf_4", "tf_5", "tf_6", "tf_7")
      ),
      directed = FALSE
    ),
    create_graph_from_dm(dm_for_filter_w_cycle())
  )

  expect_snapshot({
    attr(igraph::E(create_graph_from_dm(nyc_comp())), "vnames")
  })
})
