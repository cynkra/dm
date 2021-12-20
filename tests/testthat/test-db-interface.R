test_that("data source found", {
  expect_false(is_null(my_test_src_fun()))
  expect_silent(my_test_src_fun()())
})

skip_if_not_installed("dbplyr")

test_that("copy_dm_to() copies data frames to databases", {
  skip_if_ide()

  expect_equivalent_dm(
    copy_dm_to(my_db_test_src(), collect(dm_for_filter())),
    dm_for_filter()
  )

  expect_equivalent_dm(
    copy_dm_to(my_db_test_src(), dm_for_filter()),
    dm_for_filter()
  )

  # FIXME: How to test writing permanent tables without and be sure they are removed at the end independent what 'my_test_src()' is?
})

test_that("copy_dm_to() copies data frames from any source", {
  expect_equivalent_dm(
    expect_deprecated_obj(
      copy_dm_to(default_local_src(), dm_for_filter())
    ),
    dm_for_filter()
  )
})

# FIXME: Add test that set_key_constraints = FALSE doesn't set key constraints,
# in combination with dm_learn_from_db

test_that("copy_dm_to() rejects overwrite and types arguments", {
  expect_dm_error(
    copy_dm_to(my_test_src(), dm_for_filter(), overwrite = TRUE),
    class = "no_overwrite"
  )

  expect_dm_error(
    copy_dm_to(my_test_src(), dm_for_filter(), types = character()),
    class = "no_types"
  )
})

test_that("copy_dm_to() fails with duplicate table names", {
  bad_names <- set_names(names(dm_for_filter()))
  bad_names[[2]] <- bad_names[[1]]

  expect_dm_error(
    copy_dm_to(my_db_test_src(), dm_for_filter(), table_names = bad_names),
    class = "copy_dm_to_table_names_duplicated"
  )
})

test_that("default table repair works", {
  con <- con_from_src_or_con(my_db_test_src())

  table_names <- c("t1", "t2", "t3")

  calls <- 0

  my_unique_db_table_name <- function(table_name) {
    calls <<- calls + 1
    glue::glue("{table_name}_2020_05_15_10_45_29_0")
  }

  mockr::with_mock(
    unique_db_table_name = my_unique_db_table_name,
    {
      repair_table_names_for_db(table_names, temporary = FALSE, con)
      expect_equal(calls, 0)
      repair_table_names_for_db(table_names, temporary = TRUE, con)
      expect_gt(calls, 0)
    },
    .env = asNamespace("dm")
  )
})

test_that("table identifiers are quoted", {
  dm <- dm_for_filter_sqlite()
  remote_names <-
    dm %>%
    dm_get_tables() %>%
    map_chr(dbplyr::remote_name)

  con <- dm_get_con(dm)
  pattern <- paste0("^", unclass(DBI::dbQuoteIdentifier(con, "[a-z0-9_#]+")), "$")
  expect_true(all(grepl(pattern, remote_names)))
})

test_that("copy_dm_to() fails legibly if target schema missing for MSSQL & Postgres", {
  skip_if_src_not(c("mssql", "postgres"))

  src_db <- my_test_src()
  local_dm <- dm_for_filter() %>% collect()

  expect_deprecated(expect_false(db_schema_exists(src_db, "copy_dm_to_schema")))

  expect_error(
    copy_dm_to(src_db, local_dm, schema = "copy_dm_to_schema", temporary = FALSE)
  )
})

test_that("copy_dm_to() fails legibly with schema argument for MSSQL & Postgres", {
  skip_if_src_not(c("mssql", "postgres"))

  src_db <- my_test_src()
  local_dm <- dm_for_filter() %>% collect()

  expect_false(db_schema_exists(src_db$con, "copy_dm_to_schema"))

  db_schema_create(src_db$con, "copy_dm_to_schema")

  withr::defer({
    try(dbExecute(src_db$con, "DROP SCHEMA copy_dm_to_schema"))
  })

  expect_dm_error(
    copy_dm_to(src_db, local_dm, schema = "copy_dm_to_schema"),
    "temporary_not_in_schema"
  )

  expect_dm_error(
    copy_dm_to(
      src_db,
      local_dm,
      schema = "copy_dm_to_schema",
      temporary = FALSE,
      table_names = set_names(letters[1:6], src_tbls_impl(local_dm))
    ),
    "one_of_schema_table_names"
  )
})

test_that("copy_dm_to() works with schema argument for MSSQL & Postgres", {
  skip_if_src_not(c("mssql", "postgres"))

  src_db <- my_test_src()
  local_dm <- dm_for_filter() %>% collect()

  expect_false(db_schema_exists(src_db$con, "copy_dm_to_schema"))

  db_schema_create(src_db$con, "copy_dm_to_schema")

  withr::defer({
    order_of_deletion <- c("tf_2", "tf_1", "tf_5", "tf_6", "tf_4", "tf_3")
    walk(
      dm_get_tables_impl(remote_dm)[order_of_deletion],
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", dbplyr::remote_name(.x))))
    )
    try(dbExecute(src_db$con, "DROP SCHEMA copy_dm_to_schema"))
  })

  expect_silent(
    remote_dm <- copy_dm_to(
      src_db,
      local_dm,
      schema = "copy_dm_to_schema",
      temporary = FALSE
    )
  )

  if (is_postgres(src_db)) {
    table_tibble <- sql_schema_table_list_postgres(src_db, "copy_dm_to_schema")
  } else if (is_mssql(src_db)) {
    table_tibble <- sql_schema_table_list_mssql(src_db, "copy_dm_to_schema")
  }

  # compare names and remote names
  expect_identical(
    sort(deframe(table_tibble)),
    sort(
      remote_dm %>%
        dm_get_tables() %>%
        map(dbplyr::remote_name) %>%
        flatten_chr() %>%
        dbplyr::ident_q()
    )
  )
})

test_that("copy_dm_to() fails with schema argument for databases other than MSSQL & Postgres", {
  skip_if_src("mssql", "postgres")

  local_dm <- dm_for_filter() %>% collect()

  expect_dm_error(
    copy_dm_to(
      my_test_src(),
      local_dm,
      temporary = FALSE,
      schema = "test"
    ),
    "no_schemas_supported"
  )
})


test_that("build_copy_queries works", {
  skip_if_ide()

  src_db <- my_test_src()

  # build regular dm from `dm_pixarfilms()`
  pixar_dm <-
    # fetch sample dm
    dm_pixarfilms() %>%
    # make it regular
    dm_filter(pixar_films, !is.na(film)) %>%
    dm_apply_filters() %>%
    dm_select_tbl(-pixar_people)

  expect_snapshot(
    variant = if (packageVersion("testthat") > "3.1.0") "testthat-new" else "testthat-legacy",
    pixar_dm %>%
      build_copy_queries(
        src_db,
        .,
        table_names = names(.) %>%
          repair_table_names_for_db(temporary = FALSE, con = sqlite_db, schema = NULL) %>%
          map(dbplyr::ident_q)) %>%
      map(as.data.frame) # to print full queries
  )


  # build a dm whose index might be duplicated if naively build (child__a__key)
  ambiguous_dm <- dm(
    parent1 = tibble(key = 1),
    parent2 = tibble(a__key = 1),
    child = tibble(a__key = 1),
    child__a = tibble(key = 1)
  ) %>%
    dm_add_pk(parent1, key) %>%
    dm_add_pk(parent2, a__key) %>%
    dm_add_fk(child, a__key, parent2) %>%
    dm_add_fk(child__a, key, parent2)

  expect_equal(
    build_copy_queries(
      src_db,
      ambiguous_dm,
      table_names = names(ambiguous_dm) %>%
        repair_table_names_for_db(temporary = FALSE, con = src_db, schema = NULL) %>%
        map(dbplyr::ident_q)) %>%
      pluck("index_queries") %>%
      pull(index_name) %>%
      {
        anyDuplicated(.)
      },
    0
  )



})
