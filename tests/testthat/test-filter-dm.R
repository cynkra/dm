test_that("data structure", {
  expect_snapshot({
    dm_more_complex() %>%
      dm_paste(options = c("select", "keys"))
  })
})

test_that("get_all_filtered_connected() calculates the paths correctly", {
  # Only need to run for local sources
  skip_if_remote_src()

  fc <-
    dm_more_complex() %>%
    dm_filter(tf_2, TRUE) %>%
    dm_filter(tf_6, TRUE) %>%
    get_all_filtered_connected("tf_5")
  expect_pred_chain(fc, c("tf_2", "tf_3", "tf_4", "tf_5"))
  expect_pred_chain(fc, c("tf_6", "tf_5"))
  expect_not_pred(fc, c("tf_1", "tf_4_2"))

  # more complicated graph structure:
  fc <-
    dm_more_complex() %>%
    dm_filter(tf_6, TRUE) %>%
    dm_filter(tf_6_2, TRUE) %>%
    get_all_filtered_connected("tf_4")
  expect_pred_chain(fc, c("tf_6", "tf_5", "tf_4"))
  expect_pred_chain(fc, c("tf_6_2", "tf_3", "tf_4"))

  # filter in an unconnected component:
  fc <-
    dm_more_complex() %>%
    dm_filter(tf_6, TRUE) %>%
    get_all_filtered_connected("a")
  expect_identical(fc$node, "a")


  fc <-
    dm_more_complex() %>%
    dm_filter(tf_5, TRUE) %>%
    get_all_filtered_connected("tf_3")
  expect_pred_chain(fc, c("tf_5", "tf_4", "tf_3"))

  f <-
    dm_more_complex() %>%
    dm_filter(tf_4_2, TRUE) %>%
    dm_filter(tf_6, TRUE)

  fc_tf_4 <- get_all_filtered_connected(f, "tf_4")

  expect_pred_chain(fc_tf_4, c("tf_4_2", "tf_5", "tf_4"))
  expect_pred_chain(fc_tf_4, c("tf_6", "tf_5", "tf_4"))
  expect_not_pred(fc_tf_4, c("tf_6_2", "tf_3", "tf_2", "tf_1"))

  f <-
    dm_more_complex() %>%
    dm_filter(tf_4_2, TRUE) %>%
    dm_filter(tf_6, TRUE, FALSE) %>%
    dm_filter(tf_5, TRUE)

  fc_tf_4 <- get_all_filtered_connected(f, "tf_4")

  expect_pred_chain(fc_tf_4, c("tf_4_2", "tf_5", "tf_4"))
  expect_pred_chain(fc_tf_4, c("tf_6", "tf_5", "tf_4"))
  expect_not_pred(fc_tf_4, c("tf_6_2", "tf_3", "tf_2", "tf_1"))

  # fails when cycle is present
  expect_dm_error(
    dm_for_filter_w_cycle() %>% dm_filter(tf_1, a > 3) %>% dm_get_filtered_table("tf_3"),
    "no_cycles"
  )

  # Cycles in other components don't affect filtering
  expect_equivalent_dm(
    dm_for_filter_w_cycle() %>%
      dm_add_tbl(tf_8 = tibble(r = 1)) %>%
      dm_filter(tf_8, TRUE) %>%
      dm_apply_filters(),
    dm_for_filter_w_cycle() %>%
      dm_add_tbl(tf_8 = tibble(r = 1))
  )

  # FIXME: fails, when it could actually work (check diagram of `dm_for_filter_w_cycle()`)
  # expect_identical(
  #   dm_for_filter_w_cycle() %>% dm_filter(tf_1, a > 3) %>% dm_get_filtered_table("tf_2"),
  #   semi_join(tf_2, filter(tf_1, a > 3))
  # )
})

test_that("we get filtered/unfiltered tables with respective funs", {
  expect_equivalent_tbl(
    dm_filter(dm_for_filter(), tf_1, a > 4) %>% tbl_impl("tf_2"),
    tf_2()
  )

  expect_equivalent_tbl(
    dm_filter(dm_for_filter(), tf_1, a > 4) %>% dm_apply_filters_to_tbl(tf_2),
    tf_2() %>% semi_join(filter(tf_1(), a > 4), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    dm_filter(dm_for_filter(), tf_1, a > 4) %>% tbl_impl("tf_1"),
    filter(tf_1(), a > 4)
  )

  expect_snapshot({
    dm_for_filter() %>%
      dm_filter(tf_1, a > 3, a < 8) %>%
      dm_apply_filters() %>%
      dm_get_tables() %>%
      map(harmonize_tbl)
  })
})

test_that("dm_filter() works as intended for reversed dm", {
  expect_snapshot({
    dm_for_filter_rev() %>%
      dm_filter(tf_1, a < 8, a > 3) %>%
      dm_apply_filters() %>%
      dm_get_tables() %>%
      map(harmonize_tbl)
  })
})

test_that("dm_filter() works as intended for inbetween table", {
  expect_snapshot({
    dm_for_filter() %>%
      dm_filter(tf_3, g == "five") %>%
      dm_apply_filters() %>%
      dm_get_tables() %>%
      map(harmonize_tbl)
  })
})

test_that("dm_filter() works without primary keys", {
  expect_silent(
    dm_for_filter() %>%
      dm_rm_pk(tf_5, rm_referencing_fks = TRUE) %>%
      dm_filter(tf_5, l == "c") %>%
      collect()
  )
})

test_that("dm_filter() returns original `dm` object when ellipsis empty", {
  expect_equivalent_dm(
    dm_filter(dm_for_filter(), tf_3),
    dm_for_filter()
  )
})

test_that("dm_filter() fails when no table name is provided", {
  expect_dm_error(
    dm_filter(dm_for_filter()),
    class = "table_missing"
  )
})


# tests for compound keys -------------------------------------------------

test_that("dm_filter() output for compound keys", {
  expect_snapshot({
    nyc_comp() %>%
      dm_filter(flights, sched_dep_time <= 1200) %>%
      dm_apply_filters() %>%
      dm_nrow()
    nyc_comp() %>%
      dm_filter(weather, pressure < 1020) %>%
      dm_apply_filters() %>%
      dm_nrow()
  })
})
