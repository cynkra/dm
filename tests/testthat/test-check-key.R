context("test-check-key")

test_that("check_key() checks primary key properly?", {
  map(
    .x = data_check_key_src,
    ~ expect_error(
      check_key(.x, c1, c2),
      class = cdm_error("not_unique_key"),
      error_txt_not_unique_key(".x", c("c1", "c2"))
    )
  )

  map(
    .x = data_check_key_src,
    ~ expect_silent(
      check_key(.x, c1, c3)
    )
  )

  map(
    .x = data_check_key_src,
    ~ expect_silent(
      check_key(.x, c2, c3)
    )
  )
})
