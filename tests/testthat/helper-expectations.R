expect_identical_graph <- function(g1, g2) {
  expect_true(igraph::identical_graphs(g1, g2))
}

expect_equivalent_dm <- function(dm1, dm2) {
  tables1 <- dm_get_tables_impl(dm1) %>% map(collect)
  tables2 <- dm_get_tables_impl(dm2) %>% map(collect)

  expect_equivalent_tbl_lists(tables1, tables2)

  expect_equal(dm_get_all_pks_impl(dm1), dm_get_all_pks_impl(dm2))
  expect_equal(dm_get_all_fks_impl(dm1), dm_get_all_fks_impl(dm2))
}

expect_equivalent_why <- function(ex1, ex2) {
  if (inherits(my_test_src(), "src_dbi")) {
    ex1 <-
      ex1 %>%
      mutate(why = (why != ""))
    ex2 <-
      ex2 %>%
      mutate(why = (why != ""))
  }

  expect_identical(ex1, ex2)
}

expect_dm_error <- function(expr, class) {
  expect_error(expr, class = dm_error(class))
}

expect_dm_warning <- function(expr, class) {
  expect_warning(expr, class = dm_warning(class))
}

expect_name_repair_message <- function(expr) {
  expect_message(expr)
}

arrange_if_no_list <- function(tbl) {
  if (inherits(tbl, "tbl_dbi")) {
    arrange_all(tbl)
  } else {
    arrange(tbl, across(where(~ !is.list(.))))
  }
}

# are two tables identical minus the `src`
expect_equivalent_tbl <- function(tbl_1, tbl_2, ...) {
  tbl_1_lcl <- collect(tbl_1) %>% mutate(...) %>% arrange_if_no_list()
  tbl_2_lcl <- collect(tbl_2) %>% mutate(...) %>% arrange_if_no_list()
  expect_identical(tbl_1_lcl, tbl_2_lcl)
}

# are two lists of tables identical minus the `src`
expect_equivalent_tbl_lists <- function(list_1, list_2) {
  expect_identical(names(list_1), names(list_2))
  walk2(list_1, list_2, expect_equivalent_tbl)
}
