test_that("table identifiers are quoted", {
  src_db <- my_db_test_src()

  test_dm <- copy_dm_to(
    src_db,
    dm(
      test_table_123 = tibble(a = 1),
      test_table_321 = tibble(b = 2)
    ),
    temporary = FALSE,
    table_names = ~ DBI::SQL(unique_db_table_name(.x))
  )
  remote_tbl_names_copied <- map_chr(dm_get_tables(test_dm), dbplyr::remote_name)

  on.exit({
    walk(
      remote_tbl_names_copied,
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", .x)))
    )
  })

  remote_tbl_names_learned <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  # `gsub()`, cause schema names are part of the remote_names (also standard schemas "dbo" for MSSQL and "public" for Postgres).
  expect_setequal(gsub("^.*\\.", "", unname(remote_tbl_names_learned)), unclass(DBI::dbQuoteIdentifier(src_db$con, names(dm))))
})

test_that("table identifiers are quoted with learn_keys = FALSE", {
  src_db <- my_db_test_src()

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
    src_tbls_impl(test_dm),
    ~ dbplyr::remote_name(test_dm[[.x]])
  )

  on.exit({
    walk(
      remote_tbl_names_copied,
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", .x)))
    )
  })

  dm <- suppress_mssql_warning(dm_from_src(src_db, learn_keys = FALSE))
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  expect_equal(gsub("^.*\\.", "", unname(remote_names)), unclass(DBI::dbQuoteIdentifier(con, names(dm))))
})

test_that("copy_dm_to() and dm_from_src() output for compound keys", {
  # FIXME: COMPOUND:: both copy_dm_to() and dm_from_src() cannot deal with compound keys yet
  src_db <- my_db_test_src()
  skip("FIXME")

  nyc_comp_permanent <- copy_dm_to(src_db, dm_nycflights13(compound = TRUE), temporary = FALSE, table_names = ~ DBI::SQL(unique_db_table_name(.x)))
  on.exit({
    walk(
      dm_get_tables_impl(nyc_comp_permanent)[c("flights", "airlines", "planes", "airports", "weather")],
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", dbplyr::remote_name(.x))))
    )
  })

  expect_snapshot({
    learned_dm <- dm_from_src(src_db)[c("flights", "airlines", "planes", "airports", "weather")]
    learned_dm
    dm_get_all_pks(learned_dm)
    dm_get_all_fks(learned_dm)
  })
})
