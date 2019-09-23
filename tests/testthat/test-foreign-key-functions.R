context("test-foreign-key-functions")

test_that("cdm_add_fk() works as intended?", {
  iwalk(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4),
      class = cdm_error("ref_tbl_has_no_pk"),
      error_txt_ref_tbl_has_no_pk("cdm_table_4"),
      fixed = TRUE,
      label = .y
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_has_pk(cdm_table_4)
    )
  )
})

test_that("cdm_has_fk() and cdm_get_fk() work as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_1, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_get_fk(cdm_table_1, cdm_table_4),
      "a"
    )
  )


  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_get_fk(cdm_table_2, cdm_table_4),
      "c"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_3, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_get_fk(cdm_table_3, cdm_table_4),
      character(0)
    )
  )
})

test_that("cdm_rm_fk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_1, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, NULL, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(table = cdm_table_2, ref_table = cdm_table_4),
      class = cdm_error("rm_fk_col_missing")
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, z, cdm_table_4),
      class = cdm_error("is_not_fkc")
    )
  )
})


test_that("cdm_enum_fk_candidates() works as intended?", {

  # `anti_join()` doesn't distinguish between `dbl` and `int`
  tbl_fk_candidates_t1_t4 <- tribble(
    ~column, ~candidate,  ~why,
    "a",     TRUE,       "",
  )

  map(
    cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_enum_fk_candidates(cdm_table_1, cdm_table_4) %>%
        filter(candidate) %>% collect(),
      tbl_fk_candidates_t1_t4
    )
  )

  tbl_t3_t4_df_sqlite <- tibble::tribble(
    ~column, ~candidate,  ~why,
    "c",      FALSE,      "values not in `cdm_table_4$c`: 5, 6"
  )
  # on PG the order of the found mismatches differs...
  # tbl_t3_t4_pg <- tibble::tribble(
  #   ~column, ~candidate,  ~why,
  #   "c",      FALSE,      "values not in `cdm_table_4$c`: 6, 5"
  # )
  tbl_list <- list(tbl_t3_t4_df_sqlite, tbl_t3_t4_df_sqlite)

  map2(
    cdm_test_obj_2_src[c("df", "sqlite")],
    tbl_list,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_enum_fk_candidates(cdm_table_3, cdm_table_4),
      .y
    )
  )

  tbl_t4_t3 <- tibble::tribble(
    ~column, ~candidate, ~why,
    "c",     TRUE,       ""
  )

  map(
    cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_3, c) %>%
        cdm_enum_fk_candidates(cdm_table_4, cdm_table_3),
      tbl_t4_t3
    )
  )

  nycflights_example <-     tibble::tribble(
    ~column,          ~candidate, ~why,
    "origin",         TRUE,       "",
    "carrier",        FALSE,      "values not in `airports$faa`: UA, UA, AA, B6, DL, UA, …",
    "dest",           FALSE,      "values not in `airports$faa`: BQN, SJU, SJU, SJU, SJU, SJU, …",
    "tailnum",        FALSE,      "values not in `airports$faa`: N14228, N24211, N619AA, N804JB, N668DN, N39463, …",
    "air_time",       FALSE,      "Can't join on 'air_time' x 'faa' because of incompatible types (numeric / character)",
    "arr_delay",      FALSE,      "Can't join on 'arr_delay' x 'faa' because of incompatible types (numeric / character)",
    "arr_time",       FALSE,      "Can't join on 'arr_time' x 'faa' because of incompatible types (integer / character)",
    "day",            FALSE,      "Can't join on 'day' x 'faa' because of incompatible types (integer / character)",
    "dep_delay",      FALSE,      "Can't join on 'dep_delay' x 'faa' because of incompatible types (numeric / character)",
    "dep_time",       FALSE,      "Can't join on 'dep_time' x 'faa' because of incompatible types (integer / character)",
    "distance",       FALSE,      "Can't join on 'distance' x 'faa' because of incompatible types (numeric / character)",
    "flight",         FALSE,      "Can't join on 'flight' x 'faa' because of incompatible types (integer / character)",
    "hour",           FALSE,      "Can't join on 'hour' x 'faa' because of incompatible types (numeric / character)",
    "minute",         FALSE,      "Can't join on 'minute' x 'faa' because of incompatible types (numeric / character)",
    "month",          FALSE,      "Can't join on 'month' x 'faa' because of incompatible types (integer / character)",
    "sched_arr_time", FALSE,      "Can't join on 'sched_arr_time' x 'faa' because of incompatible types (integer / character)",
    "sched_dep_time", FALSE,      "Can't join on 'sched_dep_time' x 'faa' because of incompatible types (integer / character)",
    "year",           FALSE,      "Can't join on 'year' x 'faa' because of incompatible types (integer / character)",
    "time_hour",      FALSE,      "cannot join a POSIXct object with an object that is not a POSIXct object"
  )

  expect_identical(
    cdm_enum_fk_candidates(cdm_nycflights13(), flights, airports),
    nycflights_example
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_enum_fk_candidates(.x, cdm_table_1, cdm_table_4),
      class = cdm_error("ref_tbl_has_no_pk")
    )
  )
})
