decompose_table_data_ts_names <-
  find_testthat_root_file(paste0("out/decompose-table-data-ts-", src_names, ".txt"))
reunite_parent_child_data_ts_names <-
  find_testthat_root_file(paste0("out/reunite-parent-child-data-ts-", src_names, ".txt"))
reunite_parent_child_from_list_data_ts_names <-
  find_testthat_root_file(paste0("out/reunite-parent-child_from_list-data-ts-", src_names, ".txt"))

context("test-table-surgery")

test_that("decompose_table() decomposes tables nicely on all sources?", {
  walk2(
    data_ts_src,
    decompose_table_data_ts_names,
    ~ expect_known_output(
      print(decompose_table(.x, aef_id, a, e, f)),
      .y
    )
  )
})

test_that("reunite_parent_child() reunites parent and child nicely on all sources?", {
  pwalk(
    list(
      data_ts_child_src, data_ts_parent_src, reunite_parent_child_data_ts_names
    ),
    ~ expect_known_output(
      print(reunite_parent_child(..1, ..2, aef_id)),
      ..3
    )
  )
})

test_that("reunite_parent_child_from_list() reunites parent and child nicely on all sources?", {
  walk2(
    list_of_data_ts_parent_and_child_src,
    reunite_parent_child_from_list_data_ts_names,
    ~ expect_known_output(
      print(reunite_parent_child_from_list(.x, aef_id)),
      .y
    )
  )
})


test_that("table surgery functions fail in the expected ways?", {
  map(
    data_ts_src,
    ~ expect_cdm_error(
      decompose_table(., aex_id, a, e, x),
      class = "wrong_col_names"
    )
  )

  map(
    data_ts_src,
    ~ expect_cdm_error(
      decompose_table(., a, a, e, x),
      class = "dupl_new_id_col_name"
    )
  )

  map(
    data_ts_src,
    ~ expect_cdm_error(
      decompose_table(., abcdef_id, a, b, c, d, e, f),
      class = "too_many_cols"
    )
  )
})
