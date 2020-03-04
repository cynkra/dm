test_that("check_key() checks primary key properly?", {
  map(
    .x = data_check_key_src,
    ~ expect_dm_error(
      check_key(.x, c1, c2),
      class = "not_unique_key"
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

  test_tbl <- tibble(nn = 1:5, n = 6:10)
  expect_silent(
    check_key(test_tbl, !!!c("n1" = sym("n"), "n2" = sym("nn")))
  )

  expect_silent(
    check_key(test_tbl, !!!c(sym("n"), sym("nn")))
  )

  expect_silent(
    check_key(test_tbl, everything())
  )

  expect_dm_error(
    check_key(test_tbl),
    "not_unique_key"
  )

  # if {tidyselect} selects nothing
  expect_dm_error(
    check_key(data, starts_with("d")),
    "not_unique_key"
  )

  skip("Need to think about it")
  expect_silent(
    dm_nycflights_small %>%
      dm_zoom_to(airlines) %>%
      check_key(carrier)
  )
})

test_that("check_subset() checks if t1$c1 column values are subset of t2$c2 properly?", {
  check_subset_2a_1a_names <- find_testthat_root_file(paste0("out/check-if-subset-2a-1a-", src_names, ".txt"))

  map2(
    .x = data_1_src,
    .y = data_2_src,
    ~ expect_silent(
      check_subset(.x, a, .y, a)
    )
  )

  pmap(
    list(
      data_2_src,
      data_1_src,
      check_subset_2a_1a_names
    ),
    ~ expect_known_output(
      expect_dm_error(
        check_subset(..1, a, ..2, a),
        class = "not_subset_of"
      ),
      ..3
    )
  )
})

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
      expect_dm_error(
        check_set_equality(..1, a, ..2, a),
        class = "sets_not_equal"
      ),
      ..3
    )
  )
})
