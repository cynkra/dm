test_that("copy_dm_to() copies data frames to databases", {
  map(
    test_srcs,
    ~ expect_equivalent_dm(
      copy_dm_to(., dm_for_filter, unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

test_that("copy_dm_to() copies data frames from databases", {
  map(
    dm_for_filter_src,
    ~ expect_equivalent_dm(
      copy_dm_to(src_df(env = new_environment()), ., unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

test_that("copy_dm_to() copies between sources", {
  # speed things up on cran
  skip_on_cran()

  all_combos <- crossing(a = seq_along(test_srcs), b = seq_along(dm_for_filter_src))
  map2(
    all_combos$a,
    all_combos$b,
    ~ expect_equivalent_dm(
      copy_dm_to(test_srcs[[.x]], dm_for_filter_src[[.y]], unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

# FIXME: Add test that set_key_constraints = FALSE doesn't set key constraints,
# in combination with dm_learn_from_db

test_that("copy_dm_to() rejects overwrite and types arguments", {
  expect_dm_error(
    copy_dm_to(src_df(env = new_environment()), dm_for_filter, overwrite = TRUE),
    class = "no_overwrite"
  )

  expect_dm_error(
    copy_dm_to(src_df(env = new_environment()), dm_for_filter, types = character()),
    class = "no_types"
  )
})
