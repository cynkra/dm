test_that("cdm_copy_to() works as it is intended?", {
  # test copying `dm` w/o keys
  map(
    dbplyr:::test_srcs$get(),
    ~ expect_error(
      cdm_copy_to(., cdm_test_obj),
      NA
    )
  )

  # test copying `dm` with keys but no setting of key constraints
  map(
    dbplyr:::test_srcs$get(),
    ~ expect_error(
      cdm_copy_to(., dm_for_filter, set_key_constraints = FALSE),
      NA
    )
  )

  # test copying `dm` with keys including setting of key constraints
  map(
    dbplyr:::test_srcs$get(),
    ~ expect_error(
      cdm_copy_to(., dm_for_filter),
      NA
    )
  )

})
