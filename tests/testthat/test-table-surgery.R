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
