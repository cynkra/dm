table_names <- c("table_1", "table_2", "table_3")
quo <- quo(c(table_3_new = table_3, table_1_new = table_1))

test_that("tidyselecting tables works", {
  expect_identical(
    quo_get_table_indices(quo, table_names),
    set_names(c(3L, 1L), c("table_3_new", "table_1_new"))
  )

  expect_identical(
    quo_select_table(quo, table_names),
    set_names(c("table_3", "table_1"), c("table_3_new", "table_1_new"))
  )

  expect_identical(
    quo_rename_table(quo, table_names),
    set_names(table_names, c("table_1_new", "table_2", "table_3_new"))
  )
})
