context("test-check_if_subset")

test_that("check_if_subset() checks if t1$c1 column values are subset of t2$c2 properly?", {
  check_if_subset_2a_1a_names <- find_testthat_root_file(paste0("out/check-if-subset-2a-1a-", src_names, ".txt"))

  map2(
    .x = data_1_src,
    .y = data_2_src,
    ~ expect_silent(
      check_if_subset(.x, a, .y, a)
    )
  )

  pmap(
    list(
      data_2_src,
      data_1_src,
      check_if_subset_2a_1a_names
    ),
    ~ expect_known_output(
      expect_error(
        check_if_subset(..1, a, ..2, a),
        "Column `a` in table `..1` contains values (see above) that are not present in column `a` in table `..2`",
        fixed = TRUE
      ),
      ..3
    )
  )
})
