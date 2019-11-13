context("test-filter-dm")

test_that("get_all_filtered_connected() calculates the paths correctly", {
  fc <-
    dm_more_complex %>%
    cdm_filter(t2, TRUE) %>%
    cdm_filter(t6, TRUE) %>%
    get_all_filtered_connected("t5")
  expect_pred_chain(fc, c("t2", "t3", "t4", "t5"))
  expect_pred_chain(fc, c("t6", "t5"))
  expect_not_pred(fc, c("t1", "t4_2"))

  # more complicated graph structure:
  fc <- dm_more_complex %>%
    cdm_filter(t6, TRUE) %>%
    cdm_filter(t6_2, TRUE) %>%
    get_all_filtered_connected("t4")
  expect_pred_chain(fc, c("t6", "t5", "t4"))
  expect_pred_chain(fc, c("t6_2", "t3", "t4"))

  # filter in an unconnected component:
  fc <- dm_more_complex %>%
    cdm_filter(t6, TRUE) %>%
    get_all_filtered_connected("a")
  expect_identical(fc$node, "a")


  fc <- dm_more_complex %>%
    cdm_filter(t5, TRUE) %>%
    get_all_filtered_connected("t3")
  expect_pred_chain(fc, c("t5", "t4", "t3"))

  f <-
    dm_more_complex %>%
    cdm_filter(t4_2, TRUE) %>%
    cdm_filter(t6, TRUE)

  fc_t4 <- get_all_filtered_connected(f, "t4")

  expect_pred_chain(fc_t4, c("t4_2", "t5", "t4"))
  expect_pred_chain(fc_t4, c("t6", "t5", "t4"))
  expect_not_pred(fc_t4, c("t6_2", "t3", "t2", "t1"))

  f <-
    dm_more_complex %>%
    cdm_filter(t4_2, TRUE) %>%
    cdm_filter(t6, TRUE, FALSE) %>%
    cdm_filter(t5, TRUE)

  fc_t4 <- get_all_filtered_connected(f, "t4")

  expect_pred_chain(fc_t4, c("t4_2", "t5", "t4"))
  expect_pred_chain(fc_t4, c("t6", "t5", "t4"))
  expect_not_pred(fc_t4, c("t6_2", "t3", "t2", "t1"))
})





test_that("cdm_filter() works as intended for reversed dm", {
  map(
    dm_for_filter_rev_src,
    function(dm_for_filter_rev) {
      expect_identical(
        cdm_filter(dm_for_filter_rev, t1, a < 8, a > 3) %>%
          collect() %>%
          cdm_get_tables(),
        rev(output_1)
      )
    }
  )
})

test_that("cdm_filter() works as intended?", {
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      cdm_filter(.x, t1, a < 8, a > 3) %>% collect() %>% cdm_get_tables(),
      output_1
    )
  )
})

test_that("cdm_filter() works as intended for inbetween table", {
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      cdm_filter(.x, t3, g == "five") %>% collect() %>% cdm_get_tables(),
      output_3
    )
  )
})

test_that("cdm_filter() works without primary keys", {
  map(
    dm_for_filter_src,
    function(dm_for_filter) {
      expect_error(
        dm_for_filter %>%
          cdm_rm_pk(t5, rm_referencing_fks = TRUE) %>%
          cdm_filter(t5, l == "c") %>%
          compute(),
        NA
      )
    }
  )
})

test_that("cdm_filter() returns original `dm` object when ellipsis empty", {
  map(
    dm_for_filter_src,
    ~ expect_equivalent_dm(
      cdm_filter(.x, t3),
      .x
    )
  )
})

test_that("cdm_filter() fails when no table name is provided", {
  map(
    dm_for_filter_src,
    ~ expect_cdm_error(
      cdm_filter(.x),
      class = "table_not_in_dm"
    )
  )
})

test_that("'cdm_apply_filters()' works", {
  expect_identical(
    cdm_filter(dm_for_filter, t2, e %in% LETTERS[5:6]) %>% cdm_apply_filters() %>% cdm_get_tables(),
    output_4
  )

  # 'cdm_apply_filters()' only applies the filters only to specified tables"
  expect_identical(
    cdm_filter(dm_for_filter, t2, e %in% LETTERS[5:6]) %>% cdm_apply_filters(t3, t6) %>% cdm_get_tables(),
    output_5
  )

})

