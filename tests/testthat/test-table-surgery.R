iris_1_pt <-
  iris_1() %>%
  select(starts_with("Sepal"), Species) %>%
  distinct() %>%
  mutate(Species_Sepal =  as.integer(coalesce(row_number(Sepal.Length), 0L))) %>%
  select(Species_Sepal, everything())

iris_1_ct <-
  left_join(iris_1(), iris_1_pt, by = c("Species", "Sepal.Width", "Sepal.Length")) %>%
  select(-Species, -Sepal.Width, -Sepal.Length)
iris_1_w_key_col <-
  left_join(iris_1_ct, iris_1_pt, by = "Species_Sepal")



test_that("dm_separate_tbl() works", {
  expect_equivalent_dm(
    dm_for_disambiguate() %>% dm_separate_tbl(iris_1, Species_Sepal, starts_with("Sepal"), Species),
    dm_for_disambiguate() %>%
      dm_rm_tbl(iris_1) %>%
      dm_add_tbl(iris_1 = iris_1_ct, iris_1_lookup = iris_1_pt) %>%
      dm_select_tbl(iris_1, iris_2, iris_3, iris_1_lookup) %>%
      dm_add_pk(iris_1_lookup, Species_Sepal) %>%
      dm_add_pk(iris_1, key) %>%
      dm_add_fk(iris_2, key, iris_1) %>%
      dm_add_fk(iris_1, Species_Sepal, iris_1_lookup)
  )

  expect_dm_error(
    dm_for_disambiguate() %>% dm_separate_tbl(iris_1, new_col, key, Species, Sepal.Width),
    "no_pk_in_separate_tbl"
  )

  expect_dm_error(
    dm_for_disambiguate() %>%
      dm_separate_tbl(iris_1, Species_Sepal, starts_with("Sepal"), Species, new_table_name = iris_2),
    "need_unique_names"
  )
})

test_that("dm_unite_tbls() works", {
  expect_equivalent_dm(
    dm_for_disambiguate() %>%
      dm_separate_tbl(iris_1, Species_Sepal, starts_with("Sepal"), Species) %>%
      dm_unite_tbls(iris_1, iris_1_lookup) %>%
      dm_select(iris_1, key, Sepal.Length, Sepal.Width, everything()),
    dm_for_disambiguate()
  )

  expect_equivalent_dm(
    dm_for_disambiguate() %>%
      dm_separate_tbl(iris_1, Species_Sepal, starts_with("Sepal"), Species) %>%
      dm_unite_tbls(iris_1, iris_1_lookup, rm_key_col = FALSE),
    dm_for_disambiguate() %>%
      dm_zoom_to(iris_1) %>%
      replace_zoomed_tbl(iris_1_w_key_col) %>%
      dm_update_zoomed()
  )

  expect_dm_error(
    dm_for_disambiguate() %>%
      dm_add_fk(iris_2, Species, iris_1) %>%
      dm_unite_tbls(iris_1, iris_2),
    "no_cycles"
  )
})


test_that("decompose_table() decomposes tables nicely on chosen source", {
  out <- decompose_table(data_ts(), aef_id, a, e, f)
  expect_equivalent_tbl(
    out$parent_table,
    list_of_data_ts_parent_and_child()$parent_table,
    # https://github.com/tidyverse/dbplyr/pull/496/files#r523986061
    across(where(is.integer), as.numeric)
  )
  expect_equivalent_tbl(
    out$child_table,
    list_of_data_ts_parent_and_child()$child_table,
    # https://github.com/tidyverse/dbplyr/pull/496/files#r523986061
    across(where(is.integer), as.numeric)
  )
})

test_that("decompose_table() decomposes everything() to the original", {
  out <- decompose_table(data_ts(), abcdef_id, everything())$parent_table
  expect_equivalent_tbl(
    out %>% select(-abcdef_id),
    data_ts()
  )
})

test_that("decomposition works with {tidyselect}", {
  pt_iris <-
    iris %>%
    select(starts_with("Sepal")) %>%
    distinct() %>%
    mutate(Sepal_id = row_number(Sepal.Length)) %>%
    select(Sepal_id, everything())

  ct_iris <-
    left_join(iris, pt_iris, by = c("Sepal.Length", "Sepal.Width")) %>%
    select(-Sepal.Length, -Sepal.Width)

  reference_flower_object <- list(
    child_table = ct_iris,
    parent_table = pt_iris
  )

  out <- decompose_table(iris, Sepal_id, starts_with("Sepal"))
  expect_equivalent_tbl(
    out$parent_table,
    reference_flower_object$parent_table
  )
  expect_equivalent_tbl(
    out$child_table,
    reference_flower_object$child_table
  )
})

test_that("reunite_parent_child() reunites parent and child nicely on chosen source", {
  out <- reunite_parent_child(
    list_of_data_ts_parent_and_child()$child_table,
    list_of_data_ts_parent_and_child()$parent_table,
    aef_id
  )
  ref <-
    left_join(
      list_of_data_ts_parent_and_child()$child_table,
      list_of_data_ts_parent_and_child()$parent_table,
      by = "aef_id"
    ) %>%
    select(-aef_id)

  expect_equivalent_tbl(out, ref)
})

test_that("reunite_parent_child_from_list() reunites parent and child nicely on chosen source", {
  out <- reunite_parent_child_from_list(
    list_of_data_ts_parent_and_child(), aef_id
  )
  ref <-
    left_join(
      list_of_data_ts_parent_and_child()$child_table,
      list_of_data_ts_parent_and_child()$parent_table,
      by = "aef_id"
    ) %>%
    select(-aef_id)

  expect_equivalent_tbl(out, ref)
})


test_that("table surgery functions fail in the expected ways?", {
  expect_error(
    decompose_table(data_ts(), aex_id, a, e, x),
    class = if_pkg_version("vctrs", "0.2.99.9004", "vctrs_error_subscript_oob")
  )

  expect_dm_error(
    decompose_table(data_ts(), a, a, e),
    class = "dupl_new_id_col_name"
  )
})

test_that("decompose_table() doesn't create NAs in key column", {
  data <- tibble(a = c(1, 2, NA, 3), b = letters[1:4])
  decomposed <- decompose_table(data, id, a)
  expect_true(!anyNA(decomposed$parent_table$id))
})
