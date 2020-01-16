expect_identical_graph <- function(g1, g2) {
  expect_true(igraph::identical_graphs(g1, g2))
}

expect_equivalent_dm <- function(dm1, dm2) {
  tables1 <- dm_get_tables_impl(dm1) %>% map(collect)
  tables2 <- dm_get_tables_impl(dm2) %>% map(collect)

  expect_identical(names(tables1), names(tables2))
  walk2(tables1, tables2, expect_equal)

  expect_equal(
    unnest(dm_get_all_pks_impl(dm1), pk_col),
    unnest(dm_get_all_pks_impl(dm2), pk_col)
    )
  expect_equal(
    unnest(dm_get_all_fks_impl(dm1), child_fk_col),
    unnest(dm_get_all_fks_impl(dm2), child_fk_col)
    )
}

expect_dm_error <- function(expr, class) {
  expect_error(expr, class = dm_error(class))
}
