test_that("cdm_add_pk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, cdm_table_1, a)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_add_pk(cdm_table_1, b, force = TRUE)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_cdm_error(
      cdm_add_pk(.x, cdm_table_1, qq),
      class = "wrong_col_names"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_cdm_error(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_add_pk(cdm_table_1, b),
      class = "key_set_force_false"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_cdm_error(
      cdm_add_pk(.x, cdm_table_2, c, check = TRUE),
      class = "not_unique_key"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, cdm_table_2, c)
    )
  )
})


test_that("cdm_rm_pk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_rm_pk(cdm_table_1)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_rm_pk(cdm_table_2) %>% # still does its job, even if there was no key in the first place :)
        cdm_has_pk(cdm_table_1)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_cdm_error(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_rm_pk(cdm_table_5),
      class = "table_not_in_dm"
    )
  )

  # test if error is thrown if FK points to PK that is about to be removed
  expect_cdm_error(
    cdm_rm_pk(dm_for_filter, t4),
    "first_rm_fks"
  )

  # test logic if argument `rm_referencing_fks = TRUE`
  expect_equivalent_dm(
    cdm_rm_pk(dm_for_filter, t4, rm_referencing_fks = TRUE),
    cdm_rm_fk(dm_for_filter, t5, l, t4) %>%
      cdm_rm_pk(t4)
  )
})

test_that("cdm_has_pk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      cdm_has_pk(.x, cdm_table_2)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_has_pk(cdm_table_1)
    )
  )
})

test_that("cdm_get_pk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_get_pk(.x, cdm_table_1),
      character(0)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_get_pk(cdm_table_1),
      "a"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_cdm_error(
      .x %>%
        cdm_add_pk(cdm_table_1, a) %>%
        cdm_add_pk(cdm_table_1, b),
      class = "key_set_force_false"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_equivalent_dm(
      .x %>%
        cdm_add_pk(cdm_table_1, a) %>%
        cdm_add_pk(cdm_table_1, b, force = TRUE),
      .x %>%
        cdm_add_pk(cdm_table_1, b)
    )
  )
})

test_that("cdm_enum_pk_candidates() works properly?", {
  candidates_table_1 <- tibble(column = c("a", "b"), candidate = c(TRUE, TRUE), why = c("", ""))
  candidates_table_2 <- tibble(column = c("c"), candidate = c(FALSE), why = "has duplicate values: 5")

  iwalk(
    cdm_test_obj_src,
    ~ expect_identical(
      cdm_enum_pk_candidates(.x, cdm_table_1),
      candidates_table_1,
      label = .y
    )
  )

  iwalk(
    cdm_test_obj_src,
    ~ expect_identical(
      cdm_enum_pk_candidates(.x, cdm_table_2),
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
