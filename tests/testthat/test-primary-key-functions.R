context("test-primary-key-functions")

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
    ~ expect_error(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_add_pk(cdm_table_1, b),
      class = cdm_error("key_set_force_false"),
      error_txt_key_set_force_false()
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_pk(.x, cdm_table_2, c),
      class = cdm_error("not_unique_key"),
      error_txt_not_unique_key("table_from_dm", "c")
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, cdm_table_2, c, check = FALSE)
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
    ~ expect_error(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_rm_pk(cdm_table_5),
      class = cdm_error("table_not_in_dm"),
      error_txt_table_not_in_dm("cdm_table_5", c("cdm_table_1", "cdm_table_2", "cdm_table_3", "cdm_table_4"))
    )
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
    ~ expect_error(
      cdm_add_pk(.x, cdm_table_1, a) %>%
        cdm_add_pk_impl("cdm_table_1", "b") %>%
        cdm_get_pk(cdm_table_1),
      class = cdm_error("multiple_pks"),
      error_txt_multiple_pks("cdm_table_1"),
      fixed = TRUE
    )
  )
})

test_that("cdm_enum_pk_candidates() works properly?", {
  candidates_table_1 <- tibble(column = c("a", "b"), candidate = c(TRUE, TRUE))
  candidates_table_2 <- tibble(column = c("c"), candidate = c(FALSE))

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
