context("test-foreign-key-functions")

test_that("cdm_add_fk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c),
      paste0("'c' needs to be primary key of 'cdm_table_4' but isn't. You can ",
             "set parameter 'set_ref_pk = TRUE', or use function cdm_add_pk() ",
             "to set it as primary key."),
      fixed = TRUE
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_has_pk(cdm_table_4)
      )
  )


})

test_that("cdm_has_fk() and cdm_get_fk() work as intended?", {

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_has_fk(cdm_table_1, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_get_fk(cdm_table_1, cdm_table_4),
      "a"
    )
  )


  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_get_fk(cdm_table_2, cdm_table_4),
      "c"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_has_fk(cdm_table_3, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_get_fk(cdm_table_3, cdm_table_4),
      character(0)
    )
  )

})

test_that("cdm_rm_fk() works as intended?", {

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_rm_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_1, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_rm_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_rm_fk(cdm_table_2, NULL, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_rm_fk(table = cdm_table_2, ref_table = cdm_table_4),
      "Parameter 'column' has to be set. 'NULL' for removing all references."
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4, c, set_ref_pk = TRUE) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4, c) %>%
        cdm_rm_fk(cdm_table_2, z, cdm_table_4),
      paste0("The given column 'z' is not a foreign key column of table ",
             "'cdm_table_2' with regards to ref_table 'cdm_table_4'. ",
             "Foreign key columns are: 'c'")
    )
  )
})
