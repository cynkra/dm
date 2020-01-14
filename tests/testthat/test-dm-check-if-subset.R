context("test-examine_if_subset")

test_that("examine_if_subset() checks if t1$c1 column values are subset of t2$c2 properly?", {
  examine_if_subset_2a_1a_names <- find_testthat_root_file(paste0("out/check-if-subset-2a-1a-", src_names, ".txt"))

  map2(
    .x = data_1_src,
    .y = data_2_src,
    ~ expect_silent(
      examine_if_subset(.x, a, .y, a)
    )
  )

  pmap(
    list(
      data_2_src,
      data_1_src,
      examine_if_subset_2a_1a_names
    ),
    ~ expect_known_output(
      expect_dm_error(
        examine_if_subset(..1, a, ..2, a),
        class = "not_subset_of"
      ),
      ..3
    )
  )
})
