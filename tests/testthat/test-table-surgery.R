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

