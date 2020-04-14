test_that("dm_add_fk() works as intended?", {
  expect_dm_error(
    dm_add_fk(dm_test_obj, dm_table_1, a, dm_table_4),
    class = "ref_tbl_has_no_pk"
  )

  expect_dm_error(
    dm_add_fk(dm_test_obj_sqlite, dm_table_1, a, dm_table_4),
    class = "ref_tbl_has_no_pk"
  )

  expect_true(
    dm_add_pk(dm_test_obj, dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_has_fk(dm_table_1, dm_table_4)
  )

  expect_true(
    dm_add_pk(dm_test_obj_sqlite, dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_has_fk(dm_table_1, dm_table_4)
  )
})

test_that("dm_has_fk() and dm_get_fk() work as intended?", {
  expect_identical(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_1, dm_table_4),
    new_keys("a")
  )

  expect_identical(
    dm_test_obj_sqlite %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_1, dm_table_4),
    new_keys("a")
  )

  expect_true(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_2, dm_table_4)
  )

  expect_true(
    dm_test_obj_sqlite %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_2, dm_table_4)
  )

  expect_identical(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_2, dm_table_4),
    new_keys("c")
  )

  expect_false(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_3, dm_table_4)
  )

  expect_identical(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_3, dm_table_4),
    new_keys(character(0))
  )
})

test_that("dm_rm_fk() works as intended?", {
  expect_true(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_1, dm_table_4)
  )

  expect_true(
    dm_test_obj_sqlite %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_1, dm_table_4)
  )

  expect_false(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_2, dm_table_4)
  )

  expect_false(
    dm_test_obj_sqlite %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_2, dm_table_4)
  )

  expect_false(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, NULL, dm_table_4) %>%
      dm_has_fk(dm_table_2, dm_table_4)
  )

  expect_dm_error(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(table = dm_table_2, ref_table = dm_table_4),
    class = "rm_fk_col_missing"
  )

  expect_dm_error(
    dm_test_obj %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, z, dm_table_4),
    class = "is_not_fkc"
  )
})


test_that("dm_enum_fk_candidates() works as intended?", {

  # `anti_join()` doesn't distinguish between `dbl` and `int`
  tbl_fk_candidates_t1_t4 <- tribble(
    ~column, ~candidate, ~why,
    "a", TRUE, "",
    "b", FALSE, "<reason>"
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  map(
    dm_test_obj_src,
    ~ expect_identical(
      .x %>%
        dm_add_pk(dm_table_4, c) %>%
        dm_enum_fk_candidates(dm_table_1, dm_table_4) %>%
        mutate(why = if_else(why != "", "<reason>", "")) %>%
        collect(),
      tbl_fk_candidates_t1_t4
    )
  )

  tbl_t3_t4 <- tibble::tribble(
    ~column, ~candidate, ~why,
    "c", FALSE, "<reason>"
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  map(
    dm_test_obj_2_src,
    ~ expect_identical(
      dm_add_pk(.x, dm_table_4, c) %>%
        dm_enum_fk_candidates(dm_table_3, dm_table_4) %>%
        mutate(why = if_else(why != "", "<reason>", "")),
      tbl_t3_t4
    )
  )

  tbl_t4_t3 <- tibble::tribble(
    ~column, ~candidate, ~why,
    "c", TRUE, ""
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  map(
    dm_test_obj_src,
    ~ expect_identical(
      .x %>%
        dm_add_pk(dm_table_3, c) %>%
        dm_enum_fk_candidates(dm_table_4, dm_table_3),
      tbl_t4_t3
    )
  )

  nycflights_example <- tibble::tribble(
    ~column,     ~candidate,       ~why,
    "origin",          TRUE,         "",
    "dest",           FALSE, "<reason>",
    "tailnum",        FALSE, "<reason>",
    "carrier",        FALSE, "<reason>",
    "air_time",       FALSE, "<reason>",
    "arr_delay",      FALSE, "<reason>",
    "arr_time",       FALSE, "<reason>",
    "day",            FALSE, "<reason>",
    "dep_delay",      FALSE, "<reason>",
    "dep_time",       FALSE, "<reason>",
    "distance",       FALSE, "<reason>",
    "flight",         FALSE, "<reason>",
    "hour",           FALSE, "<reason>",
    "minute",         FALSE, "<reason>",
    "month",          FALSE, "<reason>",
    "sched_arr_time", FALSE, "<reason>",
    "sched_dep_time", FALSE, "<reason>",
    "time_hour",      FALSE, "<reason>",
    "year",           FALSE, "<reason>"
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))


  expect_identical(
    dm_enum_fk_candidates(dm_nycflights13(), flights, airports) %>%
      mutate(why = if_else(why != "", "<reason>", "")),
    nycflights_example
  )

  map(
    dm_test_obj_src,
    function(dm_test_obj) {
      expect_dm_error(
        dm_enum_fk_candidates(dm_test_obj, dm_table_1, dm_table_4),
        class = "ref_tbl_has_no_pk"
      )
    }
  )
})

test_that("enum_fk_candidates() works properly", {
  expect_silent(
    expect_identical(
      enum_fk_candidates(zoomed_dm, t3),
      dm_enum_fk_candidates(dm_for_filter, t2, t3)
    )
  )
})
