zoomed_dm <- cdm_zoom_to_tbl(dm_for_filter, t2)

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

test_that("basic test: 'distinct()'-methods work", {
  expect_identical(
    distinct(zoomed_dm, d_new = d) %>% cdm_update_zoomed_tbl() %>% tbl("t2"),
    distinct(t2, d_new = d)
  )

  expect_cdm_error(
    distinct(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'arrange()'-methods work", {
  # standard arrange
  expect_identical(
    arrange(zoomed_dm, e) %>% get_zoomed_tbl(),
    arrange(t2, e)
  )

  # arrange within groups
  expect_identical(
    group_by(zoomed_dm, e) %>% arrange(desc(e), .by_group = TRUE) %>% get_zoomed_tbl(),
    arrange(group_by(t2, e), desc(e), .by_group = TRUE)
  )

  expect_cdm_error(
    arrange(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'pull()'-methods work", {
  expect_identical(
    pull(zoomed_dm, d),
    pull(t2, d)
  )

  expect_cdm_error(
    pull(dm_for_filter),
    "no_table_zoomed_dplyr"
  )
})

test_that("basic test: 'slice()'-methods work", {
  expect_identical(
    slice(zoomed_dm, 3:6) %>% get_zoomed_tbl(),
    slice(t2, 3:6)
  )

  expect_cdm_error(
    slice(dm_for_filter, 2),
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

  expect_identical(
    distinct(zoomed_dm, d_new = d) %>% cdm_update_zoomed_tbl() %>% cdm_get_all_fks(),
    cdm_get_all_fks(dm_for_filter) %>%
      filter(child_fk_col != "e") %>%
      mutate(child_fk_col = if_else(child_fk_col == "d", "d_new", child_fk_col))
  )

  expect_identical(
    arrange(zoomed_dm, e) %>% cdm_update_zoomed_tbl() %>% cdm_get_all_fks(),
    cdm_get_all_fks(dm_for_filter)
  )

  # it should be possible to combine 'filter' on a zoomed_dm with all other dplyr-methods; example: 'rename'
  expect_equivalent_dm(
    cdm_zoom_to_tbl(dm_for_filter, t2) %>%
      filter(d < 6) %>%
      rename(c_new = c, d_new = d) %>%
      cdm_update_zoomed_tbl(),
    cdm_filter(dm_for_filter, t2, d < 6) %>%
      cdm_rename(t2, c_new = c, d_new = d)
  )
})

