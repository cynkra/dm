test_that("get_all_filtered_connected() calculates the paths correctly", {
  fc <-
    dm_more_complex %>%
    dm_filter(t2, TRUE) %>%
    dm_filter(t6, TRUE) %>%
    get_all_filtered_connected("t5")
  expect_pred_chain(fc, c("t2", "t3", "t4", "t5"))
  expect_pred_chain(fc, c("t6", "t5"))
  expect_not_pred(fc, c("t1", "t4_2"))

  # more complicated graph structure:
  fc <- dm_more_complex %>%
    dm_filter(t6, TRUE) %>%
    dm_filter(t6_2, TRUE) %>%
    get_all_filtered_connected("t4")
  expect_pred_chain(fc, c("t6", "t5", "t4"))
  expect_pred_chain(fc, c("t6_2", "t3", "t4"))

  # filter in an unconnected component:
  fc <- dm_more_complex %>%
    dm_filter(t6, TRUE) %>%
    get_all_filtered_connected("a")
  expect_identical(fc$node, "a")


  fc <- dm_more_complex %>%
    dm_filter(t5, TRUE) %>%
    get_all_filtered_connected("t3")
  expect_pred_chain(fc, c("t5", "t4", "t3"))

  f <-
    dm_more_complex %>%
    dm_filter(t4_2, TRUE) %>%
    dm_filter(t6, TRUE)

  fc_t4 <- get_all_filtered_connected(f, "t4")

  expect_pred_chain(fc_t4, c("t4_2", "t5", "t4"))
  expect_pred_chain(fc_t4, c("t6", "t5", "t4"))
  expect_not_pred(fc_t4, c("t6_2", "t3", "t2", "t1"))

  f <-
    dm_more_complex %>%
    dm_filter(t4_2, TRUE) %>%
    dm_filter(t6, TRUE, FALSE) %>%
    dm_filter(t5, TRUE)

  fc_t4 <- get_all_filtered_connected(f, "t4")

  expect_pred_chain(fc_t4, c("t4_2", "t5", "t4"))
  expect_pred_chain(fc_t4, c("t6", "t5", "t4"))
  expect_not_pred(fc_t4, c("t6_2", "t3", "t2", "t1"))

  # fails when cycle is present
  expect_dm_error(
    dm_for_filter_w_cycle %>% dm_filter(t1, a > 3) %>% dm_get_filtered_table("t3"),
    "no_cycles"
  )

  # FIXME: fails, when it could actually work (check diagram of `dm_for_filter_w_cycle`)
  # expect_identical(
  #   dm_for_filter_w_cycle %>% dm_filter(t1, a > 3) %>% dm_get_filtered_table("t2"),
  #   semi_join(t2, filter(t1, a > 3))
  # )
})

test_that("we get filtered/unfiltered tables with respective funs", {
  expect_identical(
    dm_filter(dm_for_filter, t1, a > 4) %>% tbl("t2"),
    t2
  )

  expect_identical(
    dm_filter(dm_for_filter, t1, a > 4) %>% dm_apply_filters_to_tbl(t2),
    t2 %>% semi_join(filter(t1, a > 4), by = c("d" = "a"))
  )

  expect_identical(
    dm_filter(dm_for_filter, t1, a > 4) %>% tbl("t1"),
    filter(t1, a > 4)
  )

  expect_equivalent_dm(
    dm_filter(dm_for_filter, t1, a > 3, a < 8) %>% dm_apply_filters(),
    as_dm(output_1) %>%
      dm_add_pk(t1, a) %>%
      dm_add_pk(t2, c) %>%
      dm_add_pk(t3, f) %>%
      dm_add_pk(t4, h) %>%
      dm_add_pk(t5, k) %>%
      dm_add_pk(t6, n) %>%
      dm_add_fk(t2, d, t1) %>%
      dm_add_fk(t2, e, t3) %>%
      dm_add_fk(t4, j, t3) %>%
      dm_add_fk(t5, l, t4) %>%
      dm_add_fk(t5, m, t6)
  )
})




test_that("dm_filter() works as intended for reversed dm", {
  map(
    dm_for_filter_rev_src,
    function(dm_for_filter_rev) {
      expect_identical(
        dm_filter(dm_for_filter_rev, t1, a < 8, a > 3) %>%
          collect() %>%
          dm_get_tables(),
        rev(output_1)
      )
    }
  )
})

test_that("dm_filter() works on different srcs", {
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      dm_filter(.x, t1, a < 8, a > 3) %>% collect() %>% dm_get_tables(),
      output_1
    )
  )
})

test_that("dm_filter() works as intended for inbetween table", {
  map(
    dm_for_filter_src,
    function(dm_for_filter) {
      expect_identical(
        dm_filter(dm_for_filter, t3, g == "five") %>% collect() %>% dm_get_tables(),
        output_3
      )
    }
  )
})

test_that("dm_filter() works without primary keys", {
  expect_silent(
    dm_for_filter %>%
      dm_rm_pk(t5, rm_referencing_fks = TRUE) %>%
      dm_filter(t5, l == "c") %>%
      compute()
  )
})

test_that("dm_filter() returns original `dm` object when ellipsis empty", {
  map(
    dm_for_filter_src,
    ~ expect_equivalent_dm(
      dm_filter(.x, t3),
      .x
    )
  )
})

test_that("dm_filter() fails when no table name is provided", {
  map(
    dm_for_filter_src,
    ~ expect_dm_error(
      dm_filter(.x),
      class = "table_not_in_dm"
    )
  )
})
