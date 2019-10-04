test_that("`cdm_check_constraints()` works", {
  expect_equal(
    suppressWarnings(cdm_check_constraints(cdm_nycflights13())),
    list(pk = c(`airlines$carrier` = TRUE, `airports$faa` = TRUE, `planes$tailnum` = TRUE),
         fk = c(`flights$tailnum` = FALSE, `flights$carrier` = TRUE, `flights$origin` = TRUE))
  )

  expect_equal(
    cdm_check_constraints(dm_for_disambiguate),
    list(pk = c(`iris_1$key` = TRUE),
         fk = c(`iris_2$key` = TRUE))
  )
})
