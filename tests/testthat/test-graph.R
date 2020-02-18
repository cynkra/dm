test_that("functions working with graphs do the right thing?", {
  join_list_tbl_1 <- tibble(
    lhs = c("t2", "t3", "t4", "t5", "t6"),
    rhs = c("t1", "t2", "t3", "t4", "t5"),
    rank = as.numeric(2:6),
    has_father = rep(TRUE, 5)
  )

  join_list_tbl_3 <- tibble::tribble(
    ~lhs, ~rhs, ~rank, ~has_father,
    "t2", "t3",     2,        TRUE,
    "t4", "t3",     3,        TRUE,
    "t1", "t2",     4,        TRUE,
    "t5", "t4",     5,        TRUE,
    "t6", "t5",     6,        TRUE
  )

  expect_identical_graph(
    igraph::graph_from_data_frame(
      tibble(
        tables = c("t1", "t2", "t2", "t3", "t4", "t5", "t6"),
        ref_tables = c("t2", "t7", "t3", "t4", "t5", "t6", "t7")
      ),
      directed = FALSE
    ),
    create_graph_from_dm(dm_for_filter_w_cycle)
  )
})
