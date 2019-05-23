context("test-check-cardinalities")

test_that("check_cardinality_...() functions are checking the cardinality correctly?", {
  card_0_n_d1_d2_names <- find_testthat_root_file(paste0("out/card-0-n-d1-d2-", src_names, ".txt"))
  card_0_1_d1_d2_names <- find_testthat_root_file(paste0("out/card-0-1-d1-d2-", src_names, ".txt"))

  #  expecting silent: ------------------------------------------------------

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_0_n(parent_table = .x, pk_column = a, child_table = .y, fk_column = c)
    )
  )

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_1_n(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_cardinality_1_1(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d1_src,
      .y = d3_src,
      ~ check_set_equality(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d5_src,
      .y = d4_src,
      ~ check_cardinality_0_n(.x, a, .y, c)
    )
  )

  expect_silent(
    map2(
      .x = d5_src,
      .y = d6_src,
      ~ check_cardinality_0_1(.x, a, .y, c)
    )
  )


  # expect specific errors and sometimes specific output due to errors ---------------

  pmap(
    list(
      d1_src,
      d2_src,
      card_0_n_d1_d2_names
    ),
    ~ expect_known_output(
      expect_error(
        check_cardinality_0_n(
          parent_table = ..1,
          pk_column = a,
          child_table = ..2,
          fk_column = a
        ),
        class = cdm_error("not_subset_of"),
        error_txt_not_subset_of("..2", "a", "..1", "a"),
        fixed = TRUE
      ),
      ..3
    )
  )


  pmap(
    list(
      d1_src,
      d2_src,
      card_0_1_d1_d2_names
    ),
    ~ expect_known_output(
      expect_error(
        check_cardinality_0_1(
          parent_table = ..1,
          pk_column = a,
          child_table = ..2,
          fk_column = a
        ),
        class = cdm_error("not_subset_of"),
        error_txt_not_subset_of("..2", "a", "..1", "a"),
        fixed = TRUE
      ),
      ..3
    )
  )

  map2(
    .x = d5_src,
    .y = d4_src,
    ~ expect_error(
      check_cardinality_1_1(.x, a, .y, c),
      class = cdm_error("not_bijective"),
      error_txt_not_bijective(".y", "c"),
      fixed = TRUE
    )
  )

  map2(
    .x = d4_src,
    .y = d5_src,
    ~ expect_error(
      check_cardinality_1_1(.x, c, .y, a),
      class = cdm_error("not_unique_key"),
      error_txt_not_unique_key(".x", "c")
    )
  )

  map2(
    .x = d4_src,
    .y = d1_src,
    ~ expect_error(
      check_cardinality_1_1(.x, c, .y, a),
      class = cdm_error("not_unique_key"),
      error_txt_not_unique_key(".x", "c")
    )
  )

  map2(
    .x = d1_src,
    .y = d4_src,
    ~ expect_error(
      check_cardinality_0_1(.x, a, .y, c),
      class = cdm_error("not_injective"),
      error_txt_not_injective(".y", "c"),
      fixed = TRUE
    )
  )

  map2(
    .x = d4_src,
    .y = d1_src,
    ~ expect_error(
      check_cardinality_0_n(.x, c, .y, a),
      class = cdm_error("not_unique_key"),
      error_txt_not_unique_key(".x", "c")
    )
  )

  map2(
    .x = d4_src,
    .y = d1_src,
    ~ expect_error(
      check_cardinality_1_1(.x, c, .y, a),
      class = cdm_error("not_unique_key"),
      error_txt_not_unique_key(".x", "c")
    )
  )

  map2(
    .x = d1_src,
    .y = d4_src,
    ~ expect_error(
      check_cardinality_1_1(.x, a, .y, c),
      class = cdm_error("not_bijective"),
      error_txt_not_bijective(".y", "c"),
      fixed = TRUE
    )
  )
})
