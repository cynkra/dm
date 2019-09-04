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
  expect_pred_chain(fc, "a")
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
  expect_not_pred(fc, c("t6_2", "t3", "t2", "t1"))

  f <-
    dm_more_complex %>%
    cdm_filter(t4_2, TRUE) %>%
    cdm_filter(t6, TRUE, FALSE) %>%
    cdm_filter(t5, TRUE)

  fc_t4 <- get_all_filtered_connected(f, "t4")

  expect_pred_chain(fc_t4, c("t4_2", "t5", "t4"))
  expect_pred_chain(fc_t4, c("t6", "t5", "t4"))
  expect_not_pred(fc, c("t6_2", "t3", "t2", "t1"))

})





test_that("cdm_filter() works as intended for reversed dm", {
  skip("until further notice about filtering")
    map(.x = dm_for_filter_rev_src,
        ~ expect_identical(
          cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(collect),
          rev(output_1)
          )
        )
})

test_that("cdm_filter() works as intended?", {
skip("until further notice about filtering")
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(collect),
      output_1
      )
    )
})

test_that("cdm_filter() works as intended for inbetween table", {
skip("until further notice about filtering")
  map(
    .x = dm_for_filter_src,
    ~ expect_identical(
      cdm_filter(.x, t3, g == "five") %>% cdm_get_tables() %>% map(collect),
      output_3
      )
    )
})

test_that("cdm_filter() works without primary keys", {
skip("until further notice about filtering")
  map(
    .x = dm_for_filter_src,
    ~ expect_error(
      .x %>%
        cdm_rm_pk(t5) %>%
        cdm_filter(t5, l == "c"),
      NA
    )
  )
})

test_that("cdm_filter() returns original `dm` object when ellipsis empty", {
skip("until further notice about filtering")
  map(
    dm_for_filter_src,
    ~ expect_equal(
      cdm_filter(.x, t3),
      .x
    )
  )
})

test_that("cdm_filter() fails when no table name is provided", {
skip("until further notice about filtering")
  map(
    dm_for_filter_src,
    ~ expect_error(
      cdm_filter(.x),
      class = cdm_error("table_not_in_dm"),
      error_txt_table_not_in_dm("")
    )
  )
})
