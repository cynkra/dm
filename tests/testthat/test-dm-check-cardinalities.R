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

  walk2(
    d8_src,
    d2_src,
    ~ expect_identical(
      examine_cardinality(.x, c, .y, a),
      "injective mapping ( child: 0 or 1 -> parent: 1)"
    )
  )

  walk2(
    d5_src,
    d4_src,
    ~ expect_identical(
      examine_cardinality(.x, a, .y, c),
      "surjective mapping (child: 1 to n -> parent: 1)"
    )
  )

  walk2(
    d8_src,
    d4_src,
    ~ expect_identical(
      examine_cardinality(.x, c, .y, c),
      "generic mapping (child: 0 to n -> parent: 1)"
    )
  )

  walk2(
    d1_src,
    d3_src,
    ~ expect_identical(
      examine_cardinality(.x, a, .y, c),
      "bijective mapping (child: 1 -> parent: 1)"
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
      expect_dm_error(
        check_cardinality_0_n(
          parent_table = ..1,
          pk_column = a,
          child_table = ..2,
          fk_column = a
        ),
        class = "not_subset_of"
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
      expect_dm_error(
        check_cardinality_0_1(
          parent_table = ..1,
          pk_column = a,
          child_table = ..2,
          fk_column = a
        ),
        class = "not_subset_of"
      ),
      ..3
    )
  )

  map2(
    .x = d5_src,
    .y = d4_src,
    ~ expect_dm_error(
      check_cardinality_1_1(.x, a, .y, c),
      class = "not_bijective"
    )
  )

  map2(
    .x = d4_src,
    .y = d5_src,
    ~ expect_dm_error(
      check_cardinality_1_1(.x, c, .y, a),
      class = "not_unique_key"
    )
  )

  map2(
    .x = d4_src,
    .y = d1_src,
    ~ expect_dm_error(
      check_cardinality_1_1(.x, c, .y, a),
      class = "not_unique_key"
    )
  )

  map2(
    .x = d1_src,
    .y = d4_src,
    ~ expect_dm_error(
      check_cardinality_0_1(.x, a, .y, c),
      class = "not_injective"
    )
  )

  map2(
    .x = d4_src,
    .y = d1_src,
    ~ expect_dm_error(
      check_cardinality_0_n(.x, c, .y, a),
      class = "not_unique_key"
    )
  )

  map2(
    .x = d4_src,
    .y = d1_src,
    ~ expect_dm_error(
      check_cardinality_1_1(.x, c, .y, a),
      class = "not_unique_key"
    )
  )

  map2(
    .x = d1_src,
    .y = d4_src,
    ~ expect_dm_error(
      check_cardinality_1_1(.x, a, .y, c),
      class = "not_bijective"
    )
  )
})
