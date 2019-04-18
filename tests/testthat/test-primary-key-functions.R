context("test-primary-key-functions")

candidates_table_1 <- tibble(column = c("a", "b"), candidate = c(TRUE, TRUE))
candidates_table_2 <- tibble(column = c("c"), candidate = c(FALSE))

test_that("cdm_add_pk() works as intentended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, "cdm_table_1", a)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_add_pk("cdm_table_1", b)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_add_pk("cdm_table_1", b, force = FALSE),
      "If you want to change the existing primary key for a table, set `force` == TRUE."
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_pk(.x, "cdm_table_2", c),
      "`c` is not a unique key of `table_from_dm`"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, "cdm_table_2", c, check = FALSE)
    )
  )
})


test_that("cdm_remove_pk() works as intentended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_silent(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_remove_pk("cdm_table_1")
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_remove_pk("cdm_table_2") %>% # still does its job, even if there was no key in the first place :)
        cdm_has_pk("cdm_table_1")
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_remove_pk("cdm_table_5"),
      "cdm_table_5 not in `dm`-object. Available table names are: cdm_table_1, cdm_table_2, cdm_table_3, cdm_table_4"
    )
  )
})

test_that("cdm_has_pk() works as intentended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      cdm_has_pk(.x, "cdm_table_2")
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_has_pk("cdm_table_1")
    )
  )
})

test_that("cdm_get_pk() works as intentended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_get_pk(.x, "cdm_table_1"),
      character(0)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_get_pk("cdm_table_1"),
      "a"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_pk(.x, "cdm_table_1", a) %>%
        cdm_add_pk_impl("cdm_table_1", "b") %>%
        cdm_get_pk("cdm_table_1"),
      "Please use cdm_remove_pk() on cdm_table_1, more than 1 primary key is currently set for it.",
      fixed = TRUE
    )
  )
})

test_that("cdm_check_for_pk_candidates() works properly?", {
  map(
    cdm_test_obj_src,
    ~ expect_identical(
      cdm_check_for_pk_candidates(.x, "cdm_table_1"),
      candidates_table_1
    )
  )

  map(
    cdm_test_obj_src,
    ~ expect_identical(
      cdm_check_for_pk_candidates(.x, "cdm_table_2"),
      candidates_table_2
    )
  )
})

