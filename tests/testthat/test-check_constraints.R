test_that("`cdm_check_constraints()` works", {
  expect_equal(
    suppressWarnings(cdm_check_constraints(cdm_nycflights13())),
    list(pk = list(`airlines$carrier` = TRUE, `airports$faa` = TRUE, `planes$tailnum` = TRUE),
         fk = list(`flights$tailnum` = FALSE, `flights$carrier` = TRUE, `flights$origin` = TRUE))
  )

  expect_equal(
    cdm_check_constraints(dm_for_disambiguate),
    list(pk = list(`iris_1$key` = TRUE),
         fk = list(`iris_2$key` = TRUE))
  )
})
