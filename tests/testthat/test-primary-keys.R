test_that("dm_add_pk() works as intended?", {
  expect_silent(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a))

  expect_silent(
    dm_test_obj() %>%
      dm_add_pk(dm_table_2, c)
  )

  expect_silent(expect_equivalent_dm(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_add_pk(dm_table_1, b, force = TRUE),
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, b)
  ))

  expect_error(
    dm_add_pk(dm_test_obj(), dm_table_1, qq),
    class = "vctrs_error_subscript_oob"
  )
  expect_dm_error(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_add_pk(dm_table_1, b),
    class = "key_set_force_false"
  )
  expect_dm_error(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_add_pk(dm_table_1, a),
    class = "key_set_force_false"
  )
  expect_dm_error(
    dm_add_pk(dm_test_obj(), dm_table_2, c, check = TRUE),
    class = "not_unique_key"
  )
})

test_that("dm_rm_pk() works as intended?", {
  expect_silent(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_rm_pk(dm_table_1)
  )
  expect_dm_error(
    dm_test_obj() %>%
      dm_rm_pk(dm_table_1),
    class = "pk_not_defined"
  )
  expect_dm_error(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_rm_pk(dm_table_bogus),
    class = "table_not_in_dm"
  )

  # test if error is thrown if FK points to PK that is about to be removed
  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_pk(tf_4),
    "first_rm_fks"
  )

  # test if error is thrown if col not found
  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_pk(tf_5, x),
    "pk_not_defined"
  )

  # test if error is thrown if any col not found
  expect_dm_error(
    dm_for_filter() %>%
      dm_rm_pk(columns = x),
    "pk_not_defined"
  )
})

test_that("dm_rm_pk() supports partial filters", {
  expect_snapshot({
    # test logic if argument `fail_fk = FALSE`
    dm_for_filter() %>%
      dm_rm_pk(tf_4, fail_fk = FALSE) %>%
      get_all_keys()

    dm_for_filter() %>%
      dm_rm_pk(tf_3, fail_fk = FALSE) %>%
      get_all_keys()

    # no failure if pk not used in relationship
    dm_for_filter() %>%
      dm_rm_pk(tf_6) %>%
      get_all_keys()

    # dprecated argument name
    dm_for_filter() %>%
      dm_rm_pk(tf_4, rm_referencing_fks = TRUE) %>%
      get_all_keys()

    # partial match for columns
    dm_for_filter() %>%
      dm_rm_pk(columns = c) %>%
      get_all_keys()

    # partial match for columns, with compound key
    dm_for_filter() %>%
      dm_rm_pk(columns = c(f, f1), fail_fk = FALSE) %>%
      get_all_keys()

    # partial match for all tables
    dm_for_filter() %>%
      dm_rm_pk(fail_fk = FALSE) %>%
      get_all_keys()
  })
})

test_that("dm_has_pk() works as intended?", {
  expect_false(
    dm_has_pk(dm_test_obj(), dm_table_2)
  )
  expect_true(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_has_pk(dm_table_1)
  )
})

test_that("dm_get_pk() works as intended?", {
  local_options(lifecycle_verbosity = "quiet")

  expect_identical(
    dm_get_pk(dm_test_obj(), dm_table_1),
    new_keys(character(0))
  )
  expect_identical(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_get_pk(dm_table_1),
    new_keys("a")
  )
})

test_that("dm_enum_pk_candidates() works properly?", {
  expect_snapshot({
    dm_enum_pk_candidates(dm_test_obj(), dm_table_1)
    dm_enum_pk_candidates(dm_test_obj(), dm_table_2)
    dm_enum_pk_candidates(dm_test_obj(), dm_table_5)
    dm_enum_pk_candidates(dm_test_obj(), dm_table_6)
  })
})

test_that("enum_pk_candidates() works properly", {
  expect_silent(
    expect_identical(
      enum_pk_candidates(zoomed_dm()),
      enum_pk_candidates(tf_2())
    )
  )
})

test_that("output", {
  expect_snapshot(error = TRUE, {
    dm(x = tibble(a = c(1, 1))) %>%
      dm_add_pk(x, a, check = TRUE)
  })
})


# tests for compound keys -------------------------------------------------

test_that("dm_get_all_pks() with compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  expect_snapshot({
    nyc_comp()

    nyc_comp() %>%
      dm_get_all_pks()
  })
})
