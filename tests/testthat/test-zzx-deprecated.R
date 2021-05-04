test_that("cdm_add_tbl() works", {
  skip_on_cran()
  skip_if_remote_src()
  local_options(lifecycle_verbosity = "quiet")

  mtcars_tbl <- test_src_frame(!!!mtcars)

  expect_equivalent_dm(
    cdm_add_tbl(dm_for_filter(), cars_table = mtcars_tbl),
    dm_add_tbl(dm_for_filter(), cars_table = mtcars_tbl)
  )
})

test_that("cdm_rm_tbl() works", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    cdm_rm_tbl(dm_for_flatten(), starts_with("dim")),
    dm_rm_tbl(dm_for_flatten(), starts_with("dim"))
  )
})

test_that("cdm_copy_to() behaves correctly", {
  skip_on_cran()
  skip_if_not_installed("dbplyr")
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    cdm_copy_to(sqlite(), dm_for_filter(), unique_table_names = TRUE),
    dm_for_filter()
  )
})

test_that("cdm_disambiguate_cols() works as intended", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    expect_message(cdm_disambiguate_cols(dm_for_disambiguate())),
    expect_message(dm_disambiguate_cols(dm_for_disambiguate()))
  )
})

test_that("cdm_get_colors() behaves as intended", {
  skip_on_cran()
  skip_if_not_installed("nycflights13")
  local_options(lifecycle_verbosity = "quiet")

  expect_equal(
    cdm_get_colors(cdm_nycflights13()),
    set_names(
      c("#ED7D31FF", "#ED7D31FF", "#5B9BD5FF", "#ED7D31FF", "#70AD47FF"),
      c("airlines", "airports", "flights", "planes", "weather")
    )
  )
})

test_that("cdm_filter() behaves correctly", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_tbl(
    cdm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_apply_filters_to_tbl(tf_2),
    filter(tf_2(), d > 4)
  )

  expect_equivalent_tbl(
    dm_filter(dm_for_filter(), tf_1, a > 4) %>% cdm_apply_filters_to_tbl(tf_2),
    filter(tf_2(), d > 4)
  )

  skip_if_remote_src()
  expect_snapshot({
    dm_filter(dm_for_filter(), tf_1, a > 3, a < 8) %>%
      cdm_apply_filters() %>%
      dm_get_tables()
  })
})

test_that("cdm_nrow() works?", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equal(
    sum(cdm_nrow(dm_test_obj())),
    rows_dm_obj
  )
})

test_that("`cdm_flatten_to_tbl()`, `cdm_join_to_tbl()` and `dm_squash_to_tbl()` work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_tbl(
    expect_message(cdm_flatten_to_tbl(dm_for_flatten(), fact)),
    result_from_flatten()
  )

  expect_equivalent_tbl(
    expect_message(cdm_join_to_tbl(dm_for_flatten(), fact, dim_3)),
    select(result_from_flatten(), fact:fact.something, dim_3.something)
  )

  expect_equivalent_tbl(
    cdm_squash_to_tbl(dm_more_complex(), tf_5, tf_4, tf_3),
    left_join(tf_5(), tf_4(), by = c("l" = "h")) %>%
      left_join(tf_3(), by = c("j" = "f"))
  )
})

test_that("cdm_get_src() works", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_dm_error(
    cdm_get_src(1),
    class = "is_not_dm"
  )

  skip_if_local_src()
  expect_identical(
    class(cdm_get_src(dm_for_filter())),
    class(my_test_src())
  )
})

test_that("cdm_get_con() works", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_dm_error(
    cdm_get_con(1),
    class = "is_not_dm"
  )

  if (is.null(my_test_src())) {
    expect_dm_error(
      cdm_get_con(dm_for_filter()),
      class = "con_only_for_dbi"
    )
  } else {
    expect_silent(cdm_get_con(dm_for_filter()))
  }
})


test_that("cdm_get_tables() works", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_tbl_lists(
    cdm_get_tables(dm_for_filter()),
    dm_get_tables(dm_for_filter())
  )
})

test_that("cdm_get_filter() works", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_identical(
    cdm_get_filter(dm_for_filter()),
    dm_get_filters(dm_for_filter())
  )

  expect_identical(
    cdm_get_filter(dm_filter(dm_for_filter(), tf_1, a > 3, a < 8)),
    dm_get_filters(dm_filter(dm_for_filter(), tf_1, a > 3, a < 8))
  )
})

test_that("cdm_add_pk() and cdm_add_fk() work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    cdm_add_pk(dm_test_obj(), dm_table_4, c),
    dm_add_pk(dm_test_obj(), dm_table_4, c)
  )

  expect_equivalent_dm(
    dm_add_pk(dm_test_obj(), dm_table_4, c) %>%
      cdm_add_fk(dm_table_1, a, dm_table_4),
    dm_add_pk(dm_test_obj(), dm_table_4, c) %>%
      dm_add_fk(dm_table_1, a, dm_table_4)
  )
})

test_that("other FK functions work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_true(cdm_has_fk(dm_for_filter(), tf_2, tf_1))

  expect_false(cdm_has_fk(dm_for_filter(), tf_1, tf_2))

  expect_identical(
    cdm_get_fk(dm_for_filter(), tf_2, tf_1),
    dm_get_fk(dm_for_filter(), tf_2, tf_1)
  )

  expect_identical(
    cdm_get_all_fks(dm_for_filter()) %>%
      mutate(child_fk_cols = new_keys(child_fk_cols), parent_pk_cols = new_keys(parent_pk_cols)),
    dm_get_all_fks(dm_for_filter())
  )

  expect_equivalent_dm(
    cdm_rm_fk(dm_for_filter(), tf_2, d, tf_1),
    dm_rm_fk(dm_for_filter(), tf_2, d, tf_1)
  )

  skip_if_remote_src()
  expect_identical(
    cdm_enum_fk_candidates(dm_for_filter(), tf_2, tf_1) %>%
      mutate(why = if_else(why != "", "<reason>", "")),
    dm_enum_fk_candidates(dm_for_filter(), tf_2, tf_1) %>%
      mutate(why = if_else(why != "", "<reason>", ""))
  )
})

test_that("graph-functions work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_identical(
    cdm_is_referenced(dm_for_filter(), tf_3),
    dm_is_referenced(dm_for_filter(), tf_3)
  )

  expect_identical(
    cdm_get_referencing_tables(dm_for_filter(), tf_3),
    dm_get_referencing_tables(dm_for_filter(), tf_3)
  )
})

test_that("cdm_learn_from_db() works from PG", {
  skip("not testing deprecated learning from DB: test too slow")
  local_options(lifecycle_verbosity = "quiet")

  src_postgres <- skip_if_error(src_test("postgres"))
  con_postgres <- src_postgres$con

  # create an object on the Postgres-DB that can be learned
  if (is_postgres_empty()) {
    copy_dm_to(con_postgres, dm_for_filter(), unique_table_names = TRUE, temporary = FALSE)
  }

  expect_equivalent_dm(
    cdm_learn_from_db(con_postgres),
    dm_learn_from_db(con_postgres)
  )
  clear_postgres()
})

test_that("cdm_examine_constraints() works", {
  skip_on_cran()
  skip_if_remote_src()
  local_options(lifecycle_verbosity = "quiet")

  expect_identical(
    cdm_check_constraints(bad_dm()),
    dm_examine_constraints_impl(bad_dm())
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
  local_options(lifecycle_verbosity = "quiet")

  expect_output(
    cdm_paste(dm_for_filter(), FALSE, 4),
    paste0(
      "dm::dm(tf_1, tf_2, tf_3, tf_4, tf_5, tf_6) %>%\n    dm::dm_add_pk(tf_1, a) %>%\n    dm::dm_add_pk(tf_2, c) %>%",
      "\n    dm::dm_add_pk(tf_3, f) %>%\n    dm::dm_add_pk(tf_4, h) %>%\n    dm::dm_add_pk(tf_5, k) %>%\n    ",
      "dm::dm_add_pk(tf_6, n) %>%\n    dm::dm_add_fk(tf_2, d, tf_1) %>%\n    dm::dm_add_fk(tf_2, e, tf_3) %>%\n    ",
      "dm::dm_add_fk(tf_4, j, tf_3) %>%\n    dm::dm_add_fk(tf_5, l, tf_4) %>%\n    dm::dm_add_fk(tf_5, m, tf_6)"
    ),
    fixed = TRUE
  )
})

test_that("other PK functions work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_identical(
    cdm_has_pk(dm_for_filter(), tf_1),
    dm_has_pk(dm_for_filter(), tf_1)
  )

  expect_identical(
    cdm_get_pk(dm_for_filter(), tf_1),
    dm_get_pk(dm_for_filter(), tf_1)
  )

  expect_identical(
    cdm_get_all_pks(dm_for_filter()) %>%
      mutate(pk_col = new_keys(pk_col)),
    dm_get_all_pks(dm_for_filter())
  )

  expect_equivalent_dm(
    cdm_rm_pk(dm_for_filter(), tf_2),
    dm_rm_pk(dm_for_filter(), tf_2)
  )

  expect_identical(
    cdm_enum_pk_candidates(dm_for_disambiguate(), iris_1) %>%
      rename(columns = column) %>%
      mutate(columns = new_keys(columns)),
    dm_enum_pk_candidates(dm_for_disambiguate(), iris_1)
  )
})

test_that("dm_select_tbl() and dm_rename_tbl() work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter(), tf_1_new = tf_1, tf_2, new_tf_6 = tf_6),
    dm_select_tbl(dm_for_filter(), tf_1_new = tf_1, tf_2, new_tf_6 = tf_6)
  )

  expect_equivalent_dm(
    cdm_rename_tbl(dm_for_filter(), tf_1_new = tf_1, new_tf_6 = tf_6),
    dm_rename_tbl(dm_for_filter(), tf_1_new = tf_1, new_tf_6 = tf_6)
  )
})

test_that("dm_select() and dm_rename() work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_tbl(
    cdm_select(dm_for_filter(), tf_1, a_new = a) %>% tbl_impl("tf_1"),
    dm_select(dm_for_filter(), tf_1, a_new = a) %>% tbl_impl("tf_1")
  )

  expect_equivalent_tbl(
    cdm_rename(dm_for_filter(), tf_1, a_new = a) %>% tbl_impl("tf_1"),
    dm_rename(dm_for_filter(), tf_1, a_new = a) %>% tbl_impl("tf_1")
  )
})

test_that("dm_zoom_to() and related functions work", {
  skip_on_cran()
  local_options(lifecycle_verbosity = "quiet")

  expect_equivalent_dm(
    cdm_zoom_to_tbl(dm_for_filter(), tf_1),
    dm_zoom_to(dm_for_filter(), tf_1)
  )

  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter(), tf_1) %>% cdm_insert_zoomed_tbl("another_name"),
    dm_zoom_to(dm_for_filter(), tf_1) %>% dm_insert_zoomed("another_name")
  )

  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter(), tf_1) %>% cdm_update_zoomed_tbl(),
    dm_zoom_to(dm_for_filter(), tf_1) %>% dm_update_zoomed()
  )

  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter(), tf_1) %>% cdm_zoom_out(),
    dm_zoom_to(dm_for_filter(), tf_1) %>% dm_discard_zoomed()
  )
})

test_that("default_local_src() works", {
  expect_s3_class(default_local_src(), "src")
})
