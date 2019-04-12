context("test-primary-key-functions")

test_that("dm_add_primary_key() works as intentended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_1", a)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_add_primary_key("dm_table_1", b)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_error(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_add_primary_key("dm_table_1", b, replace_old_key = FALSE),
      "If you want to change the existing primary key for a table, set `replace_old_key` == TRUE."
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_error(
      dm_add_primary_key(.x, "dm_table_2", c),
      "`c` is not a unique key of `table_from_dm`"
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_2", c, check_if_unique_key = FALSE)
    )
  )

})



test_that("dm_remove_primary_key() works as intentended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_remove_primary_key("dm_table_1")
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_remove_primary_key("dm_table_2") # still does its job, even if there was no key in the first place :)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_error(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_remove_primary_key("dm_table_4"),
      "dm_table_4 not in `dm`-object. Available table names are: dm_table_1, dm_table_2, dm_table_3"
    )
  )
})



test_that("dm_remove_primary_key() works as intentended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_remove_primary_key("dm_table_1")
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_silent(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_remove_primary_key("dm_table_2") # still does its job, even if there was no key in the first place :)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_error(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_remove_primary_key("dm_table_4"),
      "dm_table_4 not in `dm`-object. Available table names are: dm_table_1, dm_table_2, dm_table_3"
    )
  )
})

test_that("dm_check_if_table_has_primary_key() works as intentended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_false(
      dm_check_if_table_has_primary_key(.x, "dm_table_2")
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_true(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_check_if_table_has_primary_key("dm_table_1")
    )
  )
})

test_that("dm_get_primary_key_column_from_table() works as intentended?", {
  map(
    .x = dm_test_obj_src,
    ~ expect_identical(
      dm_get_primary_key_column_from_table(.x, "dm_table_1"),
      character(0)
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_identical(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        dm_get_primary_key_column_from_table("dm_table_1"),
      "a"
    )
  )

  map(
    .x = dm_test_obj_src,
    ~ expect_error(
      dm_add_primary_key(.x, "dm_table_1", a) %>%
        cdm_add_key("dm_table_1", "b") %>%
        dm_get_primary_key_column_from_table("dm_table_1"),
      "Please use dm_remove_primary_key() on dm_table_1, more than 1 primary key is currently set for it.",
      fixed = TRUE
    )
  )
})


