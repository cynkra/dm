test_that("cdm_copy_to() copies data frames to databases", {
  map(
    dbplyr:::test_srcs$get(),
    ~ expect_equivalent_dm(
      cdm_copy_to(., dm_for_filter, unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

test_that("cdm_copy_to() copies data frames from databases", {
  map(
    dm_for_filter_src,
    ~ expect_equivalent_dm(
      cdm_copy_to(src_df(env = new_environment()), ., unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

test_that("cdm_copy_to() copies between sources", {
  map2(
    dbplyr:::test_srcs$get(),
    dm_for_filter_src,
    ~ expect_equivalent_dm(
      cdm_copy_to(.x, .y, unique_table_names = TRUE),
      dm_for_filter
    )
  )
})

# FIXME: Add test that set_key_constraints = FALSE doesn't set key constraints,
# in combination with cdm_learn_from_db

test_that("cdm_copy_to() rejects overwrite and types arguments", {
  expect_error(
    cdm_copy_to(src_df(env = new_environment()), dm_for_filter, overwrite = TRUE),
    class = cdm_error("no_overwrite")
  )

  expect_error(
    cdm_copy_to(src_df(env = new_environment()), dm_for_filter, types = character()),
    class = cdm_error("no_types")
  )
})
