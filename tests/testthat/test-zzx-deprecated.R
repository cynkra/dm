rlang::local_options(lifecycle_verbosity = "quiet")

test_that("cdm_add_tbl() works", {
  skip_on_cran()
  expect_identical(
    cdm_add_tbl(dm_for_filter, cars_table = mtcars),
    dm_add_tbl(dm_for_filter, cars_table = mtcars)
  )
})

test_that("cdm_rm_tbl() works", {
  skip_on_cran()
  expect_identical(
    cdm_rm_tbl(dm_for_flatten, starts_with("dim")),
    dm_rm_tbl(dm_for_flatten, starts_with("dim"))
  )
})

test_that("cdm_copy_to() behaves correctly", {
  skip_on_cran()
  map(
    test_srcs,
    ~ expect_equivalent_dm(
      cdm_copy_to(.x, dm_for_filter, unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

test_that("cdm_disambiguate_cols() works as intended", {
  skip_on_cran()
  expect_equivalent_dm(
    cdm_disambiguate_cols(dm_for_disambiguate),
    dm_disambiguate_cols(dm_for_disambiguate)
  )
})

test_that("cdm_get_colors() behaves as intended", {
  skip_on_cran()
  expect_equal(
    cdm_get_colors(cdm_nycflights13()),
    set_names(
      c("#ED7D31", "#ED7D31", "#5B9BD5", "#ED7D31", "#70AD47"),
      c("airlines", "airports", "flights", "planes", "weather")
    )
  )
})

test_that("cdm_filter() behaves correctly", {
  skip_on_cran()
  expect_identical(
    cdm_filter(dm_for_filter, t1, a > 4) %>% dm_apply_filters_to_tbl(t2),
    filter(t2, d > 4)
  )

  expect_identical(
    dm_filter(dm_for_filter, t1, a > 4) %>% cdm_apply_filters_to_tbl(t2),
    filter(t2, d > 4)
  )

  expect_identical(
    dm_filter(dm_for_filter, t1, a > 3, a < 8) %>% cdm_apply_filters() %>% dm_get_tables(),
    output_1
  )
})

test_that("cdm_nrow() works?", {
  skip_on_cran()
  expect_equal(
    sum(cdm_nrow(dm_test_obj)),
    rows_dm_obj
  )
})

test_that("`cdm_flatten_to_tbl()`, `cdm_join_to_tbl()` and `dm_squash_to_tbl()` work", {
  skip_on_cran()
  expect_identical(
    cdm_flatten_to_tbl(dm_for_flatten, fact),
    result_from_flatten
  )

  expect_identical(
    cdm_join_to_tbl(dm_for_flatten, fact, dim_3),
    select(result_from_flatten, fact:fact.something, dim_3.something)
  )

  expect_identical(
    cdm_squash_to_tbl(dm_more_complex, t5, t4, t3),
    left_join(t5, t4, by = c("l" = "h")) %>%
      left_join(t3, by = c("j" = "f"))
  )
})

test_that("cdm_get_src() works", {
  skip_on_cran()

  expect_dm_error(
    cdm_get_src(1),
    class = "is_not_dm"
  )

  walk2(
    dm_for_filter_src,
    active_srcs_class,
    function(dm_for_filter, active_src) {
      expect_true(inherits(cdm_get_src(dm_for_filter), active_src))
    }
  )
})

test_that("cdm_get_con() works", {
  skip_on_cran()

  expect_dm_error(
    cdm_get_con(1),
    class = "is_not_dm"
  )

  expect_dm_error(
    cdm_get_con(dm_for_filter),
    class = "con_only_for_dbi"
  )

  active_con_class <- semi_join(lookup, filter(active_srcs, src != "df"), by = "src") %>% pull(class_con)
  dm_for_filter_src_red <- dm_for_filter_src[!(names(dm_for_filter_src) == "df")]

  walk2(
    dm_for_filter_src_red,
    active_con_class,
    ~ expect_true(inherits(cdm_get_con(.x), .y))
  )
})


test_that("cdm_get_tables() works", {
  skip_on_cran()

  expect_identical(
    cdm_get_tables(dm_for_filter),
    dm_get_tables(dm_for_filter)
  )
})

test_that("cdm_get_filter() works", {
  skip_on_cran()

  expect_identical(
    cdm_get_filter(dm_for_filter),
    dm_get_filters(dm_for_filter)
  )

  expect_identical(
    cdm_get_filter(dm_filter(dm_for_filter, t1, a > 3, a < 8)),
    dm_get_filters(dm_filter(dm_for_filter, t1, a > 3, a < 8))
  )
})

test_that("cdm_add_pk() and cdm_add_fk() work", {
  skip_on_cran()

  expect_equivalent_dm(
    cdm_add_pk(dm_test_obj, dm_table_4, c),
    dm_add_pk(dm_test_obj, dm_table_4, c)
  )

  expect_equivalent_dm(
    dm_add_pk(dm_test_obj, dm_table_4, c) %>%
      cdm_add_fk(dm_table_1, a, dm_table_4),
    dm_add_pk(dm_test_obj, dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4)
  )
})

test_that("other FK functions work", {
  skip_on_cran()

  expect_true(cdm_has_fk(dm_for_filter, t2, t1))

  expect_false(cdm_has_fk(dm_for_filter, t1, t2))

  expect_identical(
    cdm_get_fk(dm_for_filter, t2, t1),
    dm_get_fk(dm_for_filter, t2, t1)
  )

  expect_identical(
    cdm_get_all_fks(dm_for_filter) %>%
      mutate(child_fk_cols = new_keys(child_fk_cols)),
    dm_get_all_fks(dm_for_filter)
  )

  expect_equivalent_dm(
    cdm_rm_fk(dm_for_filter, t2, d, t1),
    dm_rm_fk(dm_for_filter, t2, d, t1)
  )

  expect_identical(
    cdm_enum_fk_candidates(dm_for_filter, t2, t1),
    dm_enum_fk_candidates(dm_for_filter, t2, t1)
  )
})

test_that("graph-functions work", {
  skip_on_cran()

  expect_identical(
    cdm_is_referenced(dm_for_filter, t3),
    dm_is_referenced(dm_for_filter, t3)
  )

  expect_identical(
    cdm_get_referencing_tables(dm_for_filter, t3),
    dm_get_referencing_tables(dm_for_filter, t3)
  )
})

test_that("cdm_learn_from_db() works from PG", {
  skip("not testing deprecated learning from DB: test too slow")

  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

  # create an object on the Postgres-DB that can be learned
  if (is_postgres_empty()) {
    copy_dm_to(con_postgres, dm_for_filter, unique_table_names = TRUE, temporary = FALSE)
  }

  expect_equivalent_dm(
    cdm_learn_from_db(con_postgres),
    dm_learn_from_db(con_postgres)
  )
  clear_postgres()
})

test_that("cdm_examine_constraints() works", {
  skip_on_cran()

  expect_identical(
    cdm_check_constraints(bad_dm),
    dm_examine_constraints_impl(bad_dm)
  )
})

test_that("cdm_nycflights13() works", {
  skip("not testing deprecated cdm_nycflights13(): test too slow")

  expect_equivalent_dm(
    cdm_nycflights13(),
    dm_nycflights13()
  )
})

test_that("cdm_paste() works", {
  skip_on_cran()

  expect_output(
    cdm_paste(dm_for_filter, FALSE, 4),
    paste0(
      "dm(t1, t2, t3, t4, t5, t6) %>%\n    dm_add_pk(t1, a) %>%\n    dm_add_pk(t2, c) %>%",
      "\n    dm_add_pk(t3, f) %>%\n    dm_add_pk(t4, h) %>%\n    dm_add_pk(t5, k) %>%\n    ",
      "dm_add_pk(t6, n) %>%\n    dm_add_fk(t2, d, t1) %>%\n    dm_add_fk(t2, e, t3) %>%\n    ",
      "dm_add_fk(t4, j, t3) %>%\n    dm_add_fk(t5, l, t4) %>%\n    dm_add_fk(t5, m, t6)"
    ),
    fixed = TRUE
  )
})

test_that("other PK functions work", {
  skip_on_cran()

  expect_identical(
    cdm_has_pk(dm_for_filter, t1),
    dm_has_pk(dm_for_filter, t1)
  )

  expect_identical(
    cdm_get_pk(dm_for_filter, t1),
    dm_get_pk(dm_for_filter, t1)
  )

  expect_identical(
    cdm_get_all_pks(dm_for_filter),
    dm_get_all_pks_impl(dm_for_filter)
  )

  expect_equivalent_dm(
    cdm_rm_pk(dm_for_filter, t2),
    dm_rm_pk(dm_for_filter, t2)
  )

  expect_identical(
    cdm_enum_pk_candidates(dm_for_disambiguate, iris_1) %>%
      rename(columns = column) %>%
      mutate(columns = new_keys(columns)),
    dm_enum_pk_candidates(dm_for_disambiguate, iris_1)
  )
})

test_that("dm_select_tbl() and dm_rename_tbl() work", {
  skip_on_cran()

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, t1_new = t1, t2, new_t6 = t6),
    dm_select_tbl(dm_for_filter, t1_new = t1, t2, new_t6 = t6)
  )

  expect_equivalent_dm(
    cdm_rename_tbl(dm_for_filter, t1_new = t1, new_t6 = t6),
    dm_rename_tbl(dm_for_filter, t1_new = t1, new_t6 = t6)
  )
})

test_that("dm_select() and dm_rename() work", {
  skip_on_cran()

  expect_identical(
    cdm_select(dm_for_filter, t1, a_new = a) %>% tbl("t1"),
    dm_select(dm_for_filter, t1, a_new = a) %>% tbl("t1")
  )

  expect_identical(
    cdm_rename(dm_for_filter, t1, a_new = a) %>% tbl("t1"),
    dm_rename(dm_for_filter, t1, a_new = a) %>% tbl("t1")
  )
})

test_that("dm_zoom_to() and related functions work", {
  skip_on_cran()

  expect_equivalent_dm(
    cdm_zoom_to_tbl(dm_for_filter, t1),
    dm_zoom_to(dm_for_filter, t1)
  )

  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter, t1) %>% cdm_insert_zoomed_tbl("another_name"),
    dm_zoom_to(dm_for_filter, t1) %>% dm_insert_zoomed("another_name")
  )

  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter, t1) %>% cdm_update_zoomed_tbl(),
    dm_zoom_to(dm_for_filter, t1) %>% dm_update_zoomed()
  )

  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter, t1) %>% cdm_zoom_out(),
    dm_zoom_to(dm_for_filter, t1) %>% dm_discard_zoomed()
  )
})
