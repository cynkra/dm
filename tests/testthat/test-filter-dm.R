context("test-filter-dm")

test_that("cdm_filter() works as intended for reversed dm", {
  map(.x = dm_for_filter_rev_src,
      ~ expect_identical(
        cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(collect),
        rev(output_1))
  )
})

test_that("cdm_filter() works as intended?", {
  map(.x = dm_for_filter_src,
      ~ expect_identical(
        cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(collect),
        output_1)
  )
})

test_that("cdm_filter() works as intended for inbetween table", {
  map(.x = dm_for_filter_src,
      ~ expect_identical(
        cdm_filter(.x, t3, g == "five") %>% cdm_get_tables() %>% map(collect),
        output_3)
  )
})
