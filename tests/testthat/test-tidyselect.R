table_names <- c("table_1", "table_2", "table_3")
quo <- quo(c(table_3_new = table_3, table_1_new = table_1))

test_that("tidyselecting tables works", {
  expect_identical(
    eval_select_table_indices(quo, table_names),
    c(table_3_new = 3L, table_1_new = 1L)
  )

  expect_identical(
    eval_select_table(quo, table_names),
    set_names(c("table_3", "table_1"), c("table_3_new", "table_1_new"))
  )

  expect_identical(
    eval_rename_table_all(quo, table_names),
    set_names(table_names, c("table_1_new", "table_2", "table_3_new"))
  )
})

test_that("output", {
  expect_snapshot(error = TRUE, {
    dm_for_filter() %>%
      dm_select_tbl(tf_7)

    dm_for_filter() %>%
      dm_rename_tbl(tf_0 = tf_7)
  })
})
