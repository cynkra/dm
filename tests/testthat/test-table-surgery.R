context("test-table-surgery")

test_that("decompose_table() decomposes tables nicely?", {
  expect_identical(list_of_data_4_parent_and_child, decompose_table(data_4, aef_id, a, e, f))

})

test_that("reunite_parent_child() reunites parent and child nicely?", {
  expect_true(all_equal(data_4, reunite_parent_child(data_4_child, data_4_parent, aef_id))) # not identical, since column order is normally changed
})

test_that("reunite_parent_child_from_list() reunites parent and child nicely?", {
  expect_true(all_equal(data_4, reunite_parent_child_from_list(list_of_data_4_parent_and_child, aef_id))) # not identical, since column order is normally changed
})

