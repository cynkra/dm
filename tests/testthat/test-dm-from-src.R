test_that("table identifiers are quoted", {
  skip_if_local_src()

  src_db <- my_test_src()

  test_dm <- copy_dm_to(
    src_db,
    dm(
      test_table_123 = tibble(a = 1),
      test_table_321 = tibble(b = 2)
    ),
    temporary = FALSE,
    table_names = ~ DBI::SQL(unique_db_table_name(.x))
  )
  remote_tbl_names_copied <- map_chr(
    src_tbls(test_dm),
    ~ dbplyr::remote_name(test_dm[[.x]])
  )

  withr::defer(
    walk(
      remote_tbl_names_copied,
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", .x)))
    )
  )

  dm <- suppress_mssql_warning(dm_from_src(src_db, learn_keys = FALSE)) %>%
    dm_select_tbl(!!!remote_tbl_names_copied)

  remote_tbl_names_learned <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  # `gsub()`, cause schema names are part of the remote_names (also standard schemas "dbo" for MSSQL and "public" for Postgres).
  expect_equal(gsub("^.*\\.", "", unname(remote_tbl_names_learned)), unclass(DBI::dbQuoteIdentifier(con, names(dm))))
})

test_that("table identifiers are quoted with learn_keys = FALSE", {
  skip_if_local_src()
  src_db <- my_test_src()

  test_dm <- copy_dm_to(
    src_db,
    dm(
      test_table_123 = tibble(a = 1),
      test_table_321 = tibble(b = 2)
    ),
    temporary = FALSE,
    table_names = ~ DBI::SQL(unique_db_table_name(.x))
  )
  remote_tbl_names_copied <- map_chr(
    src_tbls(test_dm),
    ~ dbplyr::remote_name(test_dm[[.x]])
  )

  withr::defer(
    walk(
      remote_tbl_names_copied,
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", .x)))
    )
  )

  dm <- suppress_mssql_warning(dm_from_src(src_db, learn_keys = FALSE))
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  expect_equal(gsub("^.*\\.", "", unname(remote_names)), unclass(DBI::dbQuoteIdentifier(con, names(dm))))
})
