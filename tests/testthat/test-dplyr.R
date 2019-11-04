zoomed_dm <- cdm_zoom_to_tbl(dm_for_filter, t2)
zoomed_dm_2 <- cdm_zoom_to_tbl(dm_for_filter, t3)

# basic tests -------------------------------------------------------------


test_that("basic test: 'group_by()'-methods work", {
  expect_identical(
    group_by(zoomed_dm, e) %>% get_zoomed_tbl(),
    group_by(t2, e)
  )

  expect_cdm_error(
    group_by(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'select()'-methods work", {
  expect_identical(
    select(zoomed_dm, e, a = c) %>% get_zoomed_tbl(),
    select(t2, e, a = c)
  )

  expect_cdm_error(
    select(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'rename()'-methods work", {
  expect_identical(
    rename(zoomed_dm, a = c) %>% get_zoomed_tbl(),
    rename(t2, a = c)
  )

  expect_cdm_error(
    rename(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'mutate()'-methods work", {
  expect_identical(
    mutate(zoomed_dm, d_2 = d * 2) %>% get_zoomed_tbl(),
    mutate(t2, d_2 = d * 2)
  )

  expect_cdm_error(
    mutate(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})


test_that("basic test: 'transmute()'-methods work", {
  expect_identical(
    transmute(zoomed_dm, d_2 = d * 2) %>% get_zoomed_tbl(),
    transmute(t2, d_2 = d * 2)
  )

  expect_cdm_error(
    transmute(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'ungroup()'-methods work", {
  expect_identical(
    group_by(zoomed_dm, e) %>% ungroup() %>% get_zoomed_tbl(),
    group_by(t2, e) %>% ungroup()
  )

  expect_cdm_error(
    ungroup(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'summarise()'-methods work", {
  expect_identical(
    summarise(zoomed_dm, d_2 = mean(d)) %>% get_zoomed_tbl(),
    summarise(t2, d_2 = mean(d))
  )

  expect_cdm_error(
    summarise(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'filter()'-methods work", {
  expect_identical(
    filter(zoomed_dm, d > mean(d)) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    filter(t2, d > mean(d))
  )

  expect_cdm_error(
    filter(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})


test_that("basic test: 'join()'-methods for `zoomed.dm` work", {
  expect_identical(
    left_join(zoomed_dm, t1) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    left_join(t2, t1, by = c("d" = "a"))
    )

  expect_identical(
    inner_join(zoomed_dm, t1) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    inner_join(t2, t1, by = c("d" = "a"))
  )

  expect_identical(
    full_join(zoomed_dm, t1) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    full_join(t2, t1, by = c("d" = "a"))
  )

  expect_identical(
    semi_join(zoomed_dm, t1) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    semi_join(t2, t1, by = c("d" = "a"))
  )

  expect_identical(
    anti_join(zoomed_dm, t1) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    anti_join(t2, t1, by = c("d" = "a"))
  )

  expect_identical(
    right_join(zoomed_dm, t1) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    right_join(t2, t1, by = c("d" = "a"))
  )

  # fails if RHS not linked to zoomed table and no by is given
  expect_cdm_error(
    left_join(zoomed_dm, t4),
    "tables_not_neighbours"
  )

  # works, if by is given
  expect_identical(
    left_join(zoomed_dm, t4, by = c("e" = "j")) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    left_join(t2, t4, by = c("e" = "j"))
  )

  # explicitly select columns from RHS using argument `select`
  expect_identical(
    left_join(zoomed_dm_2, t2, select = c(starts_with("c"), e)) %>% cdm_update_zoomed_tbl() %>% tbl("t3"),
    left_join(t3, select(t2, c, e), by = c("f" = "e"))
  )

  # explicitly select and rename columns from RHS using argument `select`
  expect_identical(
    left_join(zoomed_dm_2, t2, select = c(starts_with("c"), d_new = d, e)) %>% cdm_update_zoomed_tbl() %>% tbl("t3"),
    left_join(t3, select(t2, c, d_new = d, e), by = c("f" = "e"))
  )

  # a former FK-relation could not be tracked
  expect_cdm_error(
    zoomed_dm %>% mutate(e = e) %>% left_join(t3),
    "fk_not_tracked"
  )
})

test_that("basic test: 'join()'-methods for `dm` throws error", {

    expect_cdm_error(
      left_join(dm_for_filter),
      "no_table_zoomed_dplyr"
    )

    expect_cdm_error(
      inner_join(dm_for_filter),
      "no_table_zoomed_dplyr"
    )

    expect_cdm_error(
      full_join(dm_for_filter),
      "no_table_zoomed_dplyr"
    )

    expect_cdm_error(
      semi_join(dm_for_filter),
      "no_table_zoomed_dplyr"
    )

    expect_cdm_error(
      anti_join(dm_for_filter),
      "no_table_zoomed_dplyr"
    )

    expect_cdm_error(
      right_join(dm_for_filter),
      "no_table_zoomed_dplyr"
    )
})


# test key tracking for all methods ---------------------------------------

# dm_for_filter, zoomed to t2; PK: c; 2 outgoing FKs: d, e; no incoming FKS
zoomed_grouped_out_dm <- cdm_zoom_to_tbl(dm_for_filter, t2) %>% group_by(c, e)

# dm_for_filter, zoomed to t3; PK: f; 2 incoming FKs: t4$j, t2$e; no outgoing FKS:
zoomed_grouped_in_dm <- cdm_zoom_to_tbl(dm_for_filter, t3) %>% group_by(g)

test_that("key tracking works", {

  # rename()

  expect_identical(
    zoomed_grouped_out_dm %>% rename(c_new = c) %>% cdm_update_zoomed_tbl() %>% cdm_get_pk(t2),
    "c_new"
  )

  expect_identical(
    zoomed_grouped_out_dm %>%
      rename(e_new = e) %>%
      cdm_update_zoomed_tbl() %>%
      cdm_get_all_fks() %>%
      filter(child_table == "t2", parent_table == "t3") %>%
      pull(child_fk_col),
    "e_new"
  )

  expect_identical(
    # FKs should not be dropped when renaming the PK they are pointing to; tibble from `cdm_get_all_fks()` shouldn't change
    zoomed_grouped_in_dm %>%
      rename(f_new = f) %>%
      cdm_update_zoomed_tbl() %>%
      cdm_get_all_fks(),
    zoomed_grouped_in_dm %>%
      cdm_get_all_fks()
  )

  # summarize()

  expect_identical(
    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      summarize(d_mean = mean(d)) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(c("c", "e"))
  )

  expect_identical(
    # grouped_by non-key col means, that no keys remain
    zoomed_grouped_in_dm %>%
      summarize(g_list = list(g)) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(character())
  )

  # transmute()

  expect_identical(
    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      transmute(d_mean = mean(d)) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(c("c", "e"))
  )

  expect_identical(
    # grouped_by non-key col means, that no keys remain
    zoomed_grouped_in_dm %>%
      transmute(g_list = list(g)) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(character())
  )

  # mutate()

  expect_identical(
    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      mutate(d_mean = mean(d), d = d * 2) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(c("c", "e"))
  )

  expect_identical(
    # grouped_by non-key col means, that only key-columns that are not touched remain for mutate()
    zoomed_grouped_in_dm %>%
      mutate(f = list(g)) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(character())
  )

  expect_identical(
    # grouped_by non-key col means, that only key-columns that are not touched remain for
    zoomed_grouped_in_dm %>%
      mutate(g_new = list(g)) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names("f")
  )

  # chain of renames other transformations

  expect_identical(
    zoomed_grouped_out_dm %>%
      summarize(d_mean = mean(d)) %>%
      ungroup() %>%
      rename(e_new = e) %>%
      group_by(e_new) %>%
      transmute(c = paste0(c, "_animal")) %>%
      cdm_insert_zoomed_tbl("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names("e_new")
  )

  # FKs that point to a PK that vanished, should also vanish
  pk_gone_dm <- zoomed_grouped_in_dm %>%
    select(g_new = g) %>%
    cdm_update_zoomed_tbl()

  expect_identical(
    pk_gone_dm %>%
      cdm_get_fk(t2, t3),
    character()
  )

  expect_identical(
    pk_gone_dm %>%
      cdm_get_fk(t4, t3),
    character()
  )
})
