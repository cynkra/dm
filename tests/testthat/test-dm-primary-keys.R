test_that("dm_add_pk() works as intended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_pk(.x, dm_table_1, a)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_add_pk(dm_table_1, b, force = TRUE)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_dm_error(
      dm_add_pk(.x, dm_table_1, qq),
      class = "wrong_col_names"
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_dm_error(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_add_pk(dm_table_1, b),
      class = "key_set_force_false"
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_dm_error(
      dm_add_pk(.x, dm_table_2, c, check = TRUE),
      class = "not_unique_key"
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_pk(.x, dm_table_2, c)
    )
  )
})


test_that("dm_rm_pk() works as intended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_rm_pk(dm_table_1)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_true(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_rm_pk(dm_table_2) %>% # still does its job, even if there was no key in the first place :)
        dm_has_pk(dm_table_1)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_dm_error(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_rm_pk(dm_table_5),
      class = "table_not_in_dm"
    )
  )

  # test if error is thrown if FK points to PK that is about to be removed
  expect_dm_error(
    dm_rm_pk(dm_for_filter, t4),
    "first_rm_fks"
  )

  # test logic if argument `rm_referencing_fks = TRUE`
  expect_equivalent_dm(
    dm_rm_pk(dm_for_filter, t4, rm_referencing_fks = TRUE),
    dm_rm_fk(dm_for_filter, t5, l, t4) %>%
      dm_rm_pk(t4)
  )

  expect_equivalent_dm(
    dm_rm_pk(dm_for_filter, t3, rm_referencing_fks = TRUE),
    dm_rm_fk(dm_for_filter, t4, j, t3) %>%
      dm_rm_fk(t2, e, t3) %>%
      dm_rm_pk(t3)
  )
})

test_that("dm_has_pk() works as intended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_false(
      dm_has_pk(.x, dm_table_2)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_true(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_has_pk(dm_table_1)
    )
  )
})

test_that("dm_get_pk() works as intended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_identical(
      dm_get_pk(.x, dm_table_1),
      new_keys(character(0))
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_identical(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_get_pk(dm_table_1),
      new_keys("a")
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_dm_error(
      .x %>%
        dm_add_pk(dm_table_1, a) %>%
        dm_add_pk(dm_table_1, b),
      class = "key_set_force_false"
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_equivalent_dm(
      .x %>%
        dm_add_pk(dm_table_1, a) %>%
        dm_add_pk(dm_table_1, b, force = TRUE),
      .x %>%
        dm_add_pk(dm_table_1, b)
    )
  )
})

test_that("dm_enum_pk_candidates() works properly?", {
  candidates_table_1 <- tibble(column = c("a", "b"), candidate = c(TRUE, TRUE), why = c("", "")) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
  candidates_table_2 <- tibble(column = c("c"), candidate = c(FALSE), why = "has duplicate values: 5") %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))

  iwalk(
    dm_test_obj_src,
    ~ expect_identical(
      dm_enum_pk_candidates(.x, dm_table_1),
      candidates_table_1,
      label = .y
    )
  )

  iwalk(
    dm_test_obj_src,
    ~ expect_identical(
      dm_enum_pk_candidates(.x, dm_table_2),
      candidates_table_2,
      label = .y
    )
  )
})

test_that("enum_pk_candidates() works properly", {
  expect_silent(
    expect_identical(
      enum_pk_candidates(zoomed_dm),
      enum_pk_candidates(t2)
    )
  )
})
