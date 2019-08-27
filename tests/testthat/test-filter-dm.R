context("test-filter-dm")

test_that("get_all_filtered_connected() calculates the paths correctly", {
  fc <-
    dm_for_filter %>%
    cdm_filter(t2, TRUE) %>%
    cdm_filter(t6, TRUE) %>%
    get_all_filtered_connected("t5")
  expect_pred_chain(fc, c("t2", "t5"))
  expect_pred_chain(fc, c("t6", "t5"))

  # more complicated graph structure:
  fc <- dm_more_complex %>%
    cdm_filter(t6, TRUE) %>%
    cdm_filter(t6_2, TRUE) %>%
    get_all_filtered_connected("t4")
  expect_pred_chain(fc, c("t6", "t5", "t4"))
  expect_pred_chain(fc, c("t6_2", "t5", "t4"))

  # filter in an unconnected component:
  fc <- dm_more_complex %>%
    cdm_filter(t6, TRUE) %>%
    get_all_filtered_connected("a")
  expect_equal(fc$node, "a")

  # cycle: "t5" connected to "t4" & "t4_2"; "t4" & "t4_2" connected to "t3"
  # both ways should be considered and when "t5" is filtered and "t3" requested,
  # the result should/could(?) be the intersect of the effect of "t4" on "t3"
  # and of "t4_2" on "t3"
  # FIXME: currently only one path is considered; since this is random behaviour,
  # it can not be the correct solution
  # fc <- dm_more_complex %>%
  #   cdm_filter(t5, TRUE) %>%
  #   get_all_filtered_connected("t3")
  # expect_pred_chain(fc, c("t5", "t4", "t3"))
  # expect_pred_chain(fc, c("t5", "t4_2", "t3"))

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
