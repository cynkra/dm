context("test-check-set-equality")

test_that("check_set_equality() checks properly if 2 sets of values are equal?", {
  check_set_equality_1a_2a_names <- find_testthat_root_file(paste0("out/check-set-equality-1a-2a-", src_names, ".txt"))

  map2(
    .x = data_1_src,
    .y = data_3_src,
    ~ expect_silent(
      check_set_equality(.x, a, .y, a)
    )
  )

  pmap(
    list(
      data_1_src,
      data_2_src,
      check_set_equality_1a_2a_names
    ),
    ~ expect_known_output(
      expect_error(
        check_set_equality(..1, a, ..2, a),
        class = cdm_error("sets_not_equal"),
        error_txt_not_subset_of("..2", "a", "..1", "a"),
        fixed = TRUE
      ),
      ..3
    )
  )
})
