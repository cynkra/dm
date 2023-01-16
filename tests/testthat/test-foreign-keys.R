test_that("dm_add_fk() works as intended?", {
  expect_dm_error(
    dm_test_obj() %>%
      dm_add_fk(dm_table_1, a, dm_table_4),
    class = "ref_tbl_has_no_pk"
  )

  expect_dm_error(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_1, a, dm_table_4),
    class = "fk_exists"
  )

  expect_snapshot({
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      get_all_keys()
  })
})

test_that("dm_has_fk() and dm_get_fk() work as intended?", {
  local_options(lifecycle_verbosity = "quiet")

  expect_identical(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_1, dm_table_4),
    new_keys("a")
  )

  expect_true(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_2, dm_table_4)
  )

  expect_identical(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_2, dm_table_4),
    new_keys("c")
  )

  expect_false(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk(dm_table_3, dm_table_4)
  )

  expect_identical(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_get_fk(dm_table_3, dm_table_4),
    new_keys(character(0))
  )
})

test_that("dm_rm_fk() works as intended?", {
  expect_silent(expect_true(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk_impl("dm_table_1", "dm_table_4")
  ))

  expect_silent(expect_false(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_has_fk_impl("dm_table_2", "dm_table_4")
  ))

  expect_message(expect_false(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, NULL, dm_table_4) %>%
      dm_has_fk_impl("dm_table_2", "dm_table_4")
  ))

  expect_dm_error(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, z, dm_table_4),
    class = "is_not_fkc"
  )

  expect_dm_error(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_add_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4) %>%
      dm_rm_fk(dm_table_2, c, dm_table_4),
    class = "is_not_fkc"
  )

  # Bad input
  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_fk(tf_x),
    class = "table_not_in_dm"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_fk(columns = x),
    class = "is_not_fkc"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_fk(ref_table = tf_x),
    class = "table_not_in_dm"
  )

  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_fk(ref_columns = x),
    class = "is_not_fkc"
  )
})


test_that("dm_rm_fk() works with partial matching", {
  expect_snapshot({
    # Only table
    dm_for_filter() %>%
      dm_rm_fk(tf_5) %>%
      get_all_keys()

    # Only columns
    dm_for_filter() %>%
      dm_rm_fk(columns = l) %>%
      get_all_keys()

    # Only columns, compound
    dm_for_filter() %>%
      dm_rm_fk(columns = c(e, e1)) %>%
      get_all_keys()

    # Only ref_table
    dm_for_filter() %>%
      dm_rm_fk(ref_table = tf_3) %>%
      get_all_keys()

    # Only ref_columns, compound
    dm_for_filter() %>%
      dm_rm_fk(ref_columns = c(f, f1)) %>%
      get_all_keys()

    # All foreign keys
    dm_for_filter() %>%
      dm_rm_fk() %>%
      get_all_keys()
  })
})


test_that("dm_enum_fk_candidates() works as intended?", {
  skip_if_ide()

  # `anti_join()` doesn't distinguish between `dbl` and `int`
  tbl_fk_candidates_tf_1_tf_4 <- tribble(
    ~column, ~candidate, ~why,
    "a", TRUE, "",
    "b", FALSE, "<reason>"
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  expect_identical(
    dm_test_obj() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_enum_fk_candidates(dm_table_1, dm_table_4) %>%
      mutate(why = if_else(why != "", "<reason>", "")) %>%
      collect(),
    tbl_fk_candidates_tf_1_tf_4
  )

  tbl_tf_3_tf_4 <- tibble::tribble(
    ~column, ~candidate, ~why,
    "c", FALSE, "<reason>"
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  expect_identical(
    dm_test_obj_2() %>%
      dm_add_pk(dm_table_4, c) %>%
      dm_enum_fk_candidates(dm_table_3, dm_table_4) %>%
      mutate(why = if_else(why != "", "<reason>", "")),
    tbl_tf_3_tf_4
  )

  tbl_tf_4_tf_3 <- tibble::tribble(
    ~column, ~candidate, ~why,
    "c", TRUE, ""
  ) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  expect_identical(
    dm_test_obj() %>%
      dm_add_pk(dm_table_3, c) %>%
      dm_enum_fk_candidates(dm_table_4, dm_table_3),
    tbl_tf_4_tf_3
  )

  expect_dm_error(
    dm_enum_fk_candidates(dm_test_obj(), dm_table_1, dm_table_4),
    class = "ref_tbl_has_no_pk"
  )

  skip_if_not_installed("nycflights13")

  expect_snapshot({
    dm_nycflights13() %>%
      dm_enum_fk_candidates(flights, airports) %>%
      mutate(why = if_else(why != "", "<reason>", ""))
  })
})

test_that("enum_fk_candidates() works properly", {
  # FIXME: COMPOUND: Test for tf_2 -> tf_3 and other combinations too
  expect_silent(
    expect_equivalent_why(
      enum_fk_candidates(dm_zoomed(), tf_1),
      dm_enum_fk_candidates(dm_for_filter(), tf_2, tf_1)
    )
  )
})

test_that("can add foreign key with cascade", {
  expect_snapshot({
    dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
      dm_add_fk(a, x, b, x, on_delete = "cascade") %>%
      dm_get_all_fks()
  })
})

test_that("bogus arguments are rejected", {
  expect_snapshot(error = TRUE, {
    dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
      dm_add_fk(a, x, b, x, on_delete = "bogus")
    dm(a = tibble(x = 1), b = tibble(x = 1)) %>%
      dm_add_fk(a, x, b, x, on_delete = letters)
  })
})


# all foreign keys --------------------------------------------------------------------

test_that("dm_get_all_fks() and order", {
  dm <- dm_for_filter()
  fks_all <- dm_get_all_fks(dm)
  fks_1 <- dm_get_all_fks(dm, "tf_1")
  fks_3 <- dm_get_all_fks(dm, tf_3)
  fks_4 <- dm_get_all_fks(dm, "tf_4")
  fks_6 <- dm_get_all_fks(dm, "tf_6")
  fks_34 <- dm_get_all_fks(dm, c(tf_3, tf_4))
  fks_43 <- dm_get_all_fks(dm, c(tf_4, tf_3))

  expect_equal(fks_all, bind_rows(fks_1, fks_3, fks_4, fks_6))
  expect_equal(fks_34, bind_rows(fks_3, fks_4))
  expect_equal(fks_43, bind_rows(fks_4, fks_3))
})

test_that("dm_get_all_fks() with parent_table arg", {
  expect_snapshot({
    nyc_comp() %>%
      dm_get_all_fks(weather)

    nyc_comp() %>%
      dm_get_all_fks(c("airlines", "weather"))
  })
})

test_that("dm_get_all_fks() with parent_table arg fails nicely", {
  expect_snapshot_error({
    nyc_comp() %>%
      dm_get_all_fks(c(airlines, weather, timetable, tabletime))
  })
})
