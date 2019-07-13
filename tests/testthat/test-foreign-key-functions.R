context("test-foreign-key-functions")

test_that("cdm_add_fk() works as intended?", {
  iwalk(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_add_fk(.x, cdm_table_1, a, cdm_table_4),
      class = cdm_error("ref_tbl_has_no_pk"),
      error_txt_ref_tbl_has_no_pk("cdm_table_4", "c"),
      fixed = TRUE,
      label = .y
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_has_pk(cdm_table_4)
    )
  )
})

test_that("cdm_has_fk() and cdm_get_fk() work as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_1, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_get_fk(cdm_table_1, cdm_table_4),
      "a"
    )
  )


  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_get_fk(cdm_table_2, cdm_table_4),
      "c"
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_3, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_get_fk(cdm_table_3, cdm_table_4),
      character(0)
    )
  )
})

test_that("cdm_rm_fk() works as intended?", {
  map(
    .x = cdm_test_obj_src,
    ~ expect_true(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_1, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_false(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, NULL, cdm_table_4) %>%
        cdm_has_fk(cdm_table_2, cdm_table_4)
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(table = cdm_table_2, ref_table = cdm_table_4),
      class = cdm_error("rm_fk_col_missing")
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_add_fk(cdm_table_1, a, cdm_table_4) %>%
        cdm_add_fk(cdm_table_2, c, cdm_table_4) %>%
        cdm_rm_fk(cdm_table_2, z, cdm_table_4),
      class = cdm_error("is_not_fkc")
    )
  )
})


test_that("cdm_enum_fk_candidates() works as intended?", {

  tbl_fk_candidates_t1_t4 <- tribble(
    ~candidate, ~column, ~table,        ~ref_table,    ~ref_table_pk,
    TRUE,       "a",     "cdm_table_1", "cdm_table_4", "c",
    FALSE,      "b",     "cdm_table_1", "cdm_table_4", "c"
  ) %>%
    select(ref_table, ref_table_pk, table, column, candidate)

  map(
    .x = cdm_test_obj_src,
    ~ expect_identical(
      .x %>%
        cdm_add_pk(cdm_table_4, c) %>%
        cdm_enum_fk_candidates(cdm_table_1, cdm_table_4),
      tbl_fk_candidates_t1_t4
    )
  )

  map(
    .x = cdm_test_obj_src,
    ~ expect_error(
      cdm_enum_fk_candidates(.x, cdm_table_1, cdm_table_4),
      class = cdm_error("ref_tbl_has_no_pk")
    )
  )
})
