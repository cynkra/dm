test_that("functions working with graphs do the right thing?", {
  join_list_tbl_1 <- tibble(
    lhs = c("t2", "t3", "t4", "t5", "t6"),
    rhs = c("t1", "t2", "t3", "t4", "t5"),
    rank = as.numeric(2:6),
    has_father = rep(TRUE, 5)
  )

  join_list_tbl_3 <- tibble(
    lhs = c("t4", "t2", "t5", "t1", "t6"),
    rhs = c("t3", "t3", "t4", "t2", "t5"),
    rank = as.numeric(2:6),
    has_father = rep(TRUE, 5)
  )

  map(
    dm_for_filter_src,
    ~ expect_equivalent(
      calculate_join_list(.x, "t1"),
      join_list_tbl_1
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equivalent(
      calculate_join_list(.x, "t3"),
      join_list_tbl_3
    )
  )

  map(
    dm_for_filter_w_cycle_src,
    ~ expect_error(
      calculate_join_list(.x, "t3"),
      class = cdm_error("no_cycles"),
      error_txt_no_cycles()
    )
  )

  map(
    dm_for_filter_w_cycle_src,
    ~ expect_identical(
      igraph::graph_from_data_frame(
        tibble(
          tables = c("t1", "t2", "t3", "t3", "t4", "t6", "t7"),
          ref_tables = c("t2", "t7", "t2", "t4", "t5", "t5", "t6")
        ),
        directed = FALSE
      ) %>%
        unclass() %>%
        pluck(9) %>%
        pluck(3, "name"),
      create_graph_from_dm(.x) %>% unclass() %>% pluck(9) %>% pluck(3, "name")
    )
  )
})
