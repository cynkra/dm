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
      character(0)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_identical(
      dm_add_pk(.x, dm_table_1, a) %>%
        dm_get_pk(dm_table_1),
      "a"
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
  candidates_table_1 <- tibble(column = c("a", "b"), candidate = c(TRUE, TRUE), why = c("", ""))
  candidates_table_2 <- tibble(column = c("c"), candidate = c(FALSE), why = "has duplicate values: 5")

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
