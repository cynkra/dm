

test_that("cdm_select_tbl() selects a part of a larger `dm` as a reduced `dm`?", {
  map2(
    dm_for_filter_src,
    dm_for_filter_smaller_src,
    ~ expect_equal(
      cdm_select_tbl(.x, t3, t5) %>% cdm_get_tables() %>% map(collect),
      cdm_get_tables(.y) %>% map(collect)
    )
  )

  map2(
    dm_for_filter_src,
    dm_for_filter_smaller_src,
    ~ expect_equivalent( # row indices differ after removal of references in data_model$references -> expect_equal() fails
      cdm_select_tbl(.x, t3, t5) %>% cdm_get_data_model(),
      cdm_get_data_model(.y)
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_select_tbl(.x),
      .x
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_select_tbl(.x, t1, t6),
      .x
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_error(
      cdm_rm_fk(.x, t2, d, t1) %>%
        cdm_select_tbl(t1, t6),
      class = cdm_error("vertices_not_connected"),
      error_txt_vertices_not_connected(),
      fixed = TRUE
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_select_tbl(.x, t1, t6, all_connected = FALSE),
      new_dm(
        src = cdm_get_src(.x),
        tables = list("t1" = tbl(.x, "t1"), "t6" = tbl(.x, "t6")),
        data_model = cdm_get_data_model(.x) %>%
          rm_table_from_data_model(c("t2", "t3", "t4", "t5"))
      )
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_rm_fk(.x, t2, d, t1) %>%
        cdm_select_tbl(t1, t6, all_connected = FALSE),
      new_dm(
        src = cdm_get_src(.x),
        tables = list("t1" = tbl(.x, "t1"), "t6" = tbl(.x, "t6")),
        data_model = cdm_get_data_model(.x) %>%
          rm_table_from_data_model(c("t2", "t3", "t4", "t5"))
      )
    )
  )
})

test_that("cdm_find_conn_tbls() finds the connected tables of a `dm`?", {
  map(
    dm_for_filter_src,
    ~ expect_identical(
      cdm_find_conn_tbls(.x, t2, t6),
      c("t2", "t3", "t4", "t5", "t6")
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_identical(
      cdm_find_conn_tbls(.x, t2, t4, t6),
      c("t2", "t3", "t4", "t5", "t6")
    )
  )

  map(
    dm_for_filter_src,
    ~ expect_error(
      cdm_rm_fk(.x, t4, j, t3) %>%
        cdm_find_conn_tbls(t2, t4, t6),
      class = cdm_error("vertices_not_connected"),
      error_txt_vertices_not_connected()
    )
  )
})
