decompose_table_data_ts_names <-
  find_testthat_root_file(paste0("out/decompose-table-data-ts-", src_names, ".txt"))
reunite_parent_child_data_ts_names <-
  find_testthat_root_file(paste0("out/reunite-parent-child-data-ts-", src_names, ".txt"))
reunite_parent_child_from_list_data_ts_names <-
  find_testthat_root_file(paste0("out/reunite-parent-child_from_list-data-ts-", src_names, ".txt"))

test_that("decompose_table() decomposes tables nicely on all sources?", {
  walk2(
    data_ts_src,
    decompose_table_data_ts_names,
    ~ expect_known_output(
      print(decompose_table(.x, aef_id, a, e, f) %>% map(arrange_all)),
      .y
    )
  )
})

test_that("decomposition works with {tidyselect}", {
  pt_iris <- select(iris, starts_with("Sepal")) %>%
    distinct() %>%
    arrange(Sepal.Length, Sepal.Width) %>%
    mutate(Sepal_id = row_number()) %>%
    select(Sepal_id, everything())

  ct_iris <- left_join(iris, pt_iris, by = c("Sepal.Length", "Sepal.Width")) %>%
    select(-Sepal.Length, -Sepal.Width)

  reference_flower_object <- list(
    child_table = ct_iris,
    parent_table = pt_iris
  ) %>%
    map(arrange_all)

  expect_identical(
    decompose_table(iris, Sepal_id, starts_with("Sepal")) %>% map(arrange_all),
    reference_flower_object
  )
})

test_that("reunite_parent_child() reunites parent and child nicely on all sources?", {
  pwalk(
    list(
      data_ts_child_src, data_ts_parent_src, reunite_parent_child_data_ts_names
    ),
    ~ expect_known_output(
      print(reunite_parent_child(..1, ..2, aef_id) %>% arrange_all()),
      ..3
    )
  )
})

test_that("reunite_parent_child_from_list() reunites parent and child nicely on all sources?", {
  walk2(
    list_of_data_ts_parent_and_child_src,
    reunite_parent_child_from_list_data_ts_names,
    ~ expect_known_output(
      print(reunite_parent_child_from_list(.x, aef_id) %>% arrange_all()),
      .y
    )
  )
})


test_that("table surgery functions fail in the expected ways?", {
  walk(
    data_ts_src,
    ~ expect_error(
      decompose_table(., aex_id, a, e, x),
      class = if_pkg_version("vctrs", "0.2.99.9004", "vctrs_error_subscript_oob")
    )
  )

  walk(
    data_ts_src,
    ~ expect_dm_error(
      decompose_table(., a, a, e, x),
      class = "dupl_new_id_col_name"
    )
  )

  walk(
    data_ts_src,
    function(data_ts) {
      expect_equal(
        decompose_table(data_ts, abcdef_id, a, b, c, d, e, f)$parent_table %>%
          select(-abcdef_id) %>%
          arrange_all() %>%
          collect(),
        data_ts %>%
          arrange_all() %>%
          collect()
      )
    }
  )
})
