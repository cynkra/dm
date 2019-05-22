

test_that("cdm_select() selects a part of a larger `dm` as a reduced `dm`?", {
  map2(
    dm_for_filter_src,
    dm_for_filter_smaller_src,
    ~ expect_equal(
      cdm_select(.x, t3, t5, all_connected = TRUE) %>% cdm_get_tables(),
      cdm_get_tables(.y))
  )

  map2(
    dm_for_filter_src,
    dm_for_filter_smaller_src,
    ~ expect_equivalent( # row indices differ after removal of references in data_model$references -> expect_equal() fails
      cdm_select(.x, t3, t5, all_connected = TRUE) %>% cdm_get_data_model(),
      cdm_get_data_model(.y))
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_select(.x),
      .x
      )
    )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_select(.x, t1, t6, all_connected = TRUE),
      .x
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_error(
      cdm_rm_fk(.x, t2, d, t1) %>%
        cdm_select(t1, t6, all_connected = TRUE),
      "Not all tables in your 'dm'-object are connected. 'dm_select_table()' currently only works for connected tables.",
      fixed = TRUE
    )
  )
})
