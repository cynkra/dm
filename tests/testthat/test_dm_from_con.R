# `remote_name_qual()` quotes through dbplyr, and from dbplyr 2.6.0 that means
# `[name]` on SQL Server where `DBI::dbQuoteIdentifier()` gives `"name"`.
# Both are valid there, so comparing the two routes tests whose quoting rules are whose,
# not anything about dm.
# Quoting the expectation the way dm quotes keeps the assertion on what it was always about:
# that a learned table carries a quoted identifier rather than a bare one.
quote_like_dm <- function(con, x) {
  as.character(dbplyr::escape(dbplyr::ident(x), collapse = NULL, con = con))
}

test_that("table identifiers are quoted", {
  con_db <- my_db_test_con()

  test_dm <- copy_dm_to(
    con_db,
    dm(
      test_table_123 = tibble(a = 1),
      test_table_321 = tibble(b = 2)
    ),
    temporary = FALSE,
    table_names = ~ unique_db_table_name(.x)
  )

  remote_tbl_names_copied <- map_chr(dm_get_tables(test_dm), dbplyr::remote_name)

  on.exit({
    walk(
      remote_tbl_names_copied,
      ~ try(DBI::dbExecute(con_db, paste0("DROP TABLE ", .x)))
    )
  })

  dm <-
    suppress_mssql_warning(dm_from_con(con_db, learn_keys = FALSE)) %>%
    dm_select_tbl(
      !!!map(
        DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)),
        ~ .x@name[[length(.x@name)]]
      )
    )

  remote_tbl_names_learned <-
    dm %>%
    dm_get_tables() %>%
    map_chr(remote_name_qual)

  # `gsub()`, cause schema names are part of the remote_names (also standard schemas "dbo" for MSSQL and "public" for Postgres).
  expect_setequal(
    gsub("^.*\\.", "", unname(remote_tbl_names_learned)),
    quote_like_dm(con_db, names(dm))
  )
})

test_that("table identifiers are quoted with learn_keys = FALSE", {
  con_db <- my_db_test_con()

  test_dm <- copy_dm_to(
    con_db,
    dm(
      test_table_123 = tibble(a = 1),
      test_table_321 = tibble(b = 2)
    ),
    temporary = FALSE,
    table_names = ~ unique_db_table_name(.x)
  )
  remote_tbl_names_copied <- map_chr(
    src_tbls_impl(test_dm),
    ~ remote_name_qual(test_dm[[.x]])
  )

  on.exit({
    walk(
      remote_tbl_names_copied,
      ~ try(DBI::dbExecute(con_db, paste0("DROP TABLE ", .x)))
    )
  })

  dm <- suppress_mssql_warning(dm_from_con(con_from_src_or_con(con_db), learn_keys = FALSE))
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(remote_name_qual)

  con <- dm_get_con(dm)
  expect_equal(
    gsub("^.*\\.", "", unname(remote_names)),
    quote_like_dm(con, names(dm))
  )
})


test_that("dm_from_src() deprecated", {
  con_db <- my_db_test_con()

  expect_deprecated(dm_from_src(src_from_src_or_con(con_db), learn_keys = FALSE))
})
