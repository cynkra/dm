test_that("dm_add_pk() works as intended?", {
  expect_silent(dm_add_pk(dm_test_obj(), dm_table_1, a))
  expect_silent(
    dm_add_pk(dm_test_obj(), dm_table_1, a) %>%
      dm_add_pk(dm_table_1, b, force = TRUE)
  )
  expect_dm_error(
    dm_add_pk(dm_test_obj(), dm_table_1, qq),
    class = "wrong_col_names"
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
  expect_silent(
    dm_add_pk(dm_test_obj(), dm_table_2, c)
  )
})

test_that("dm_rm_pk() works as intended?", {
  expect_silent(
    dm_add_pk(dm_test_obj(), dm_table_1, a) %>%
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
    dm_rm_pk(dm_for_filter(), tf_4),
    "first_rm_fks"
  )

  # test logic if argument `rm_referencing_fks = TRUE`
  expect_equivalent_dm(
    dm_rm_pk(dm_for_filter(), tf_4, rm_referencing_fks = TRUE),
    dm_for_filter() %>%
      dm_rm_fk(tf_5, l, tf_4) %>%
      dm_rm_pk(tf_4)
  )

  expect_equivalent_dm(
    dm_rm_pk(dm_for_filter(), tf_3, rm_referencing_fks = TRUE),
    dm_for_filter() %>%
      dm_rm_fk(tf_4, j, tf_3) %>%
      dm_rm_fk(tf_2, e, tf_3) %>%
      dm_rm_pk(tf_3)
  )
})

test_that("dm_has_pk() works as intended?", {
  expect_false(
    dm_has_pk(dm_test_obj(), dm_table_2)
  )
  expect_true(
    dm_add_pk(dm_test_obj(), dm_table_1, a) %>%
      dm_has_pk(dm_table_1)
  )
})

test_that("dm_get_pk() works as intended?", {
  expect_identical(
    dm_get_pk(dm_test_obj(), dm_table_1),
    new_keys(character(0))
  )
  expect_identical(
    dm_add_pk(dm_test_obj(), dm_table_1, a) %>%
      dm_get_pk(dm_table_1),
    new_keys("a")
  )
  expect_equivalent_dm(
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, a) %>%
      dm_add_pk(dm_table_1, b, force = TRUE),
    dm_test_obj() %>%
      dm_add_pk(dm_table_1, b)
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
