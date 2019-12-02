test_that("cdm_copy_to() behaves correctly", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  map(
    test_srcs,
    ~ expect_equivalent_dm(
      cdm_copy_to(., dm_for_filter, unique_table_names = TRUE),
      dm_copy_to(., dm_for_filter, unique_table_names = TRUE)
    )
  )
})
