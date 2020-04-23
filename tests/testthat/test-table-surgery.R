decompose_table_data_ts <-
  find_testthat_root_file(paste0("out/decompose-table-data-ts.txt"))
reunite_parent_child_data_ts <-
  find_testthat_root_file(paste0("out/reunite-parent-child-data-ts.txt"))
reunite_parent_child_from_list_data_ts <-
  find_testthat_root_file(paste0("out/reunite-parent-child_from_list-data-ts.txt"))

test_that("decompose_table() decomposes tables nicely on chosen source", {
  skip_if_remote_src()
  verify_output(
    decompose_table_data_ts,
    decompose_table(data_ts(), aef_id, a, e, f) %>% map(arrange_all)
  )
})

test_that("decompose_table() decomposes tables nicely on chosen source", {
  expect_equivalent_tbl(
    decompose_table(data_ts(), abcdef_id, a, b, c, d, e, f)$parent_table %>%
      select(-abcdef_id),
    data_ts()
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

  expect_equivalent_tbl_lists(
    decompose_table(iris, Sepal_id, starts_with("Sepal")) %>% map(arrange_all),
    reference_flower_object
  )
})

test_that("reunite_parent_child() reunites parent and child nicely on chosen source", {
  skip_if_remote_src()
  verify_output(
    reunite_parent_child_data_ts,
    reunite_parent_child(data_ts_child(), data_ts_parent(), aef_id) %>% arrange_all()
  )
})

test_that("reunite_parent_child_from_list() reunites parent and child nicely on chosen source", {
  skip_if_remote_src()
  verify_output(
    reunite_parent_child_from_list_data_ts,
    reunite_parent_child_from_list(list_of_data_ts_parent_and_child(), aef_id) %>% arrange_all()
  )
})


test_that("table surgery functions fail in the expected ways?", {
  expect_error(
    decompose_table(data_ts(), aex_id, a, e, x),
    class = if_pkg_version("vctrs", "0.2.99.9004", "vctrs_error_subscript_oob")
  )

  expect_dm_error(
    decompose_table(data_ts(), a, a, e, x),
    class = "dupl_new_id_col_name"
  )
})
