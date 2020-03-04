test_that("'nest_join_zoomed_dm()'-method for `zoomed_dm` works", {
  skip("`nest_join_zoomed_dm()` NYI (basic test)")
  expect_identical(
    zoomed_dm_2 %>%
      nest_join_zoomed_dm() %>%
      pull_tbl(),
    t3 %>%
      nest_join(t2, by = c("f" = "e")) %>%
      mutate(t2 = vctrs::as_list_of(t2)) %>%
      nest_join(t4, by = c("f" = "j")) %>%
      mutate(t4 = vctrs::as_list_of(t4))
  )

  expect_identical(
    zoomed_dm_2 %>%
      nest_join_zoomed_dm(t4, t2) %>%
      pull_tbl(),
    t3 %>%
      nest_join(t4, by = c("f" = "j")) %>%
      mutate(t4 = vctrs::as_list_of(t4)) %>%
      nest_join(t2, by = c("f" = "e")) %>%
      mutate(t2 = vctrs::as_list_of(t2))
  )

  expect_message(
    expect_equivalent_dm(
      dm_rm_pk(dm_for_filter, t3, TRUE) %>% dm_zoom_to(t3) %>% nest_join_zoomed_dm(),
      dm_rm_pk(dm_for_filter, t3, TRUE) %>% dm_zoom_to(t3)
    ),
    "didn't have a primary key"
  )

  expect_dm_error(
    zoomed_dm_2 %>% select(g) %>% nest_join_zoomed_dm(),
    "pk_not_tracked"
  )
})

test_that("'nest_join_zoomed_dm()' fails for Postgres-'dm'", {
  skip("`nest_join_zoomed_dm()` NYI (PG test)")
  skip_if_not("postgres" %in% src_names)
  expect_dm_error(
    dm_zoom_to(dm_for_filter_src$postgres, t3) %>% nest_join_zoomed_dm(),
    "only_for_local_src"
  )
})

test_that("'nest_join_zoomed_dm()' fails for SQLite-'dm'", {
  skip("`nest_join_zoomed_dm()` NYI (SQLite test)")
  skip_if_not("sqlite" %in% src_names)
  expect_dm_error(
    dm_zoom_to(dm_for_filter_src$sqlite, t3) %>% nest_join_zoomed_dm(),
    "only_for_local_src"
  )
})
