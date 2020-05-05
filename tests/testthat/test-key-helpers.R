test_that("check_key() checks primary key properly?", {
  expect_dm_error(
    check_key(data_mcard(), c1, c2),
    class = "not_unique_key"
  )

  expect_silent(check_key(data_mcard(), c1, c3))

  expect_silent(check_key(data_mcard(), c2, c3))

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
  skip_if_remote_src()
  expect_dm_error(
    check_key(data_mcard(), starts_with("d")),
    "not_unique_key"
  )

  skip("Need to think about it")
  expect_silent(
    dm_nycflights_small() %>%
      dm_zoom_to(airlines) %>%
      check_key(carrier)
  )
})

test_that("check_subset() checks if tf_1$c1 column values are subset of tf_2$c2 properly?", {
  # FIXME: Message about temporary table
  skip_if_src("mssql")
  expect_silent(check_subset(data_mcard_1(), a, data_mcard_2(), a))
})

verify_output(
  "out/check-if-subset-2a-1a.txt",
  check_subset(data_mcard_2(), a, data_mcard_1(), a)
)

test_that("check_set_equality() checks properly if 2 sets of values are equal?", {
  expect_silent(check_set_equality(data_mcard_1(), a, data_mcard_3(), a))

  verify_output(
    "out/check-set-equality-1a-2a.txt",
    check_set_equality(data_mcard_1(), a, data_mcard_2(), a)
  )
})
