test_that("'nest_join_dm_zoomed()'-method for `dm_zoomed` works", {
  skip("FIXME")
  skip_if_remote_src()
  expect_equivalent_tbl(
    dm_zoomed_2() %>%
      nest_join_dm_zoomed() %>%
      pull_tbl(),
    tf_3() %>%
      nest_join(tf_2(), name = "tf_2", by = c("f" = "e", "f1" = "e1")) %>%
      mutate(tf_2 = as_list_of(tf_2)) %>%
      nest_join(tf_4(), name = "tf_4", by = c("f" = "j")) %>%
      mutate(tf_4 = as_list_of(tf_4))
  )

  expect_equivalent_tbl(
    dm_zoomed_2() %>%
      nest_join_dm_zoomed(tf_4, tf_2) %>%
      pull_tbl(),
    tf_3() %>%
      nest_join(tf_4(), name = "tf_4", by = c("f" = "j")) %>%
      mutate(tf_4 = as_list_of(tf_4)) %>%
      nest_join(tf_2(), name = "tf_2", by = c("f" = "e", "f1" = "e1")) %>%
      mutate(tf_2 = as_list_of(tf_2))
  )

  expect_message(
    expect_equivalent_dm(
      dm_rm_pk(dm_for_filter(), tf_3, TRUE) %>% dm_zoom_to(tf_3) %>% nest_join_dm_zoomed(),
      dm_rm_pk(dm_for_filter(), tf_3, TRUE) %>% dm_zoom_to(tf_3)
    ),
    "didn't have a primary key"
  )

  expect_dm_error(
    dm_zoomed_2() %>% select(g) %>% nest_join_dm_zoomed(),
    "pk_not_tracked"
  )
})

test_that("'nest_join_dm_zoomed()' fails for DB-'dm'", {
  expect_dm_error(
    dm_zoom_to(dm_for_filter_duckdb(), tf_3) %>% nest_join_dm_zoomed(),
    "only_for_local_src"
  )
})


# tests for compound keys -------------------------------------------------

# FIXME: COMPOUND:: `nest_join_dm_zoomed()` cannot deal with composite keys yet
# verify_output(
#   "out/compound-nest.txt", {
#     dm_zoom_to(nyc_comp(), weather) %>%
#       nest_join_dm_zoomed()
#   }
# )
