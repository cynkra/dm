context("test-table-surgery")

test_that("decompose_table() decomposes tables nicely on all sources?", {
  expect_known_output(
    print(
      map(
        data_ts_src,
        ~ decompose_table(.x, aef_id, a, e, f)
      )
    ),
    file = find_testthat_root_file("out/decompose_table_data_ts_all_srcs.txt")
  )
})

test_that("reunite_parent_child() reunites parent and child nicely on all sources?", {
  expect_known_output(
    print(
      map2(
        .x = data_ts_child_src, data_ts_parent_src, ~ reunite_parent_child(.x, .y, aef_id)
      )
    ),
    file = find_testthat_root_file("out/reunite_parent_child_data_ts_all_srcs.txt")
  )
})

test_that("reunite_parent_child_from_list() reunites parent and child nicely on all sources?", {
  expect_known_output(
    print(
      map(
        .x = list_of_data_ts_parent_and_child_src,
        ~ reunite_parent_child_from_list(.x, aef_id)
      )
    ),
    file = find_testthat_root_file("out/reunite_parent_child_from_list_data_ts_all_srcs.txt")
  )
})


test_that("table surgery functions fail in the expected ways?", {
  map(data_ts_src,
      ~ expect_error(
        decompose_table(., aex_id, a, e, x),
        class = cdm_error("wrong_col_names"),
        error_txt_wrong_col_names(".", c("a", "b", "c", "d", "e", "f"), c("a", "e", "x"))
      ))

  map(data_ts_src,
      ~ expect_error(
        decompose_table(., a, a, e, x),
        class = cdm_error("dupl_new_id_col_name"),
        error_txt_dupl_new_id_col_name(".")
      ))

  map(data_ts_src,
      ~ expect_error(
        decompose_table(., abcdef_id, a, b, c, d, e, f),
        class = cdm_error("too_many_cols"),
        error_txt_too_many_cols(".")
      ))

})
