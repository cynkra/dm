test_that("table identifiers are quoted", {
  skip_if_local_src()

  dm <- dm_from_src(my_test_src())
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  expect_equal(unname(remote_names), unclass(DBI::dbQuoteIdentifier(con, names(dm))))
})

test_that("table identifiers are quoted with learn_keys = FALSE", {
  skip_if_local_src()

  dm <- dm_from_src(my_test_src(), learn_keys = FALSE)
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  expect_equal(unname(remote_names), unclass(DBI::dbQuoteIdentifier(con, names(dm))))
})
