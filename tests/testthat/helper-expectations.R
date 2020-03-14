expect_identical_graph <- function(g1, g2) {
  expect_true(igraph::identical_graphs(g1, g2))
}

expect_equivalent_dm <- function(dm1, dm2) {
  tables1 <- dm_get_tables_impl(dm1) %>% map(collect)
  tables2 <- dm_get_tables_impl(dm2) %>% map(collect)

  expect_identical(names(tables1), names(tables2))
  walk2(tables1, tables2, expect_equal)

  expect_equal(dm_get_all_pks_impl(dm1), dm_get_all_pks_impl(dm2))
  expect_equal(dm_get_all_fks_impl(dm1), dm_get_all_fks_impl(dm2))
}

expect_dm_error <- function(expr, class) {
  expect_error(expr, class = dm_error(class))
}

expect_name_repair_message <- function(expr) {
  # Name repair did not get a message during some time in {vctrs}
  # https://github.com/r-lib/vctrs/issues/849
  if (packageVersion("vctrs") < "0.2.99.9006") {
    expr
  } else {
    expect_message(expr)
  }
}
