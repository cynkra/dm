# FIXME: #313: learn only from current source

# produces a randomized schema name with a length of 4-10 characters
# consisting of the symbols in `reservoir`
random_schema <- function() {
  reservoir <- c(letters, LETTERS, "'", "-", "_", as.character(0:9))
  how_long <- sample(4:10, 1)
  paste0(reservoir[sample(seq_len(length(reservoir)), how_long, replace = TRUE)], collapse = "")
}

schema_name <- random_schema()

test_that("Standard learning from MSSQL (schema 'dbo') or Postgres (schema 'public') works?", {

  skip_if_src_not(c("mssql", "postgres"))
  # dm_learn_from_mssql() --------------------------------------------------
  src_db <- my_test_src()

  # create an object on the MSSQL-DB that can be learned
  dm_for_filter_copied <- copy_dm_to(src_db, dm_for_filter(), temporary = FALSE, table_names = ~ DBI::SQL(unique_db_table_name(.x)))
  order_of_deletion <- c("tf_2", "tf_1", "tf_5", "tf_6", "tf_4", "tf_3")
  remote_tbl_names <- map_chr(
    set_names(order_of_deletion),
    ~ dbplyr::remote_name(dm_for_filter_copied[[.x]])
  )

  withr::defer(
    walk(
      dm_get_tables_impl(dm_for_filter_copied)[order_of_deletion],
      ~ try(dbExecute(src_db$con, paste0("DROP TABLE ", dbplyr::remote_name(.x))))
    )
  )

  dm_db_learned_all <- expect_message(dm_from_src(src_db))

  # in case there happen to be other tables in schema "dbo" or "public"
  dm_db_learned <-
    dm_db_learned_all %>%
    dm_select_tbl(!!!remote_tbl_names)

  expect_equivalent_dm(
    dm_db_learned,
    dm_for_filter()[order_of_deletion]
  )

  # learning without keys:
  dm_db_learned_no_keys <- expect_silent(dm_from_src(src_db, learn_keys = FALSE))

  # for learning from DB without learning the key relations
  dm_for_filter_no_keys <- dm_for_filter()[order_of_deletion] %>%
    dm_get_def() %>%
    mutate(
      pks = vctrs::list_of(new_pk()),
      fks = vctrs::list_of(new_fk())) %>%
    new_dm3()

  # in case there happen to be other tables in schema "dbo" or "public"
  dm_db_learned_no_keys <-
    dm_db_learned_no_keys %>%
    dm_select_tbl(!!!remote_tbl_names)

  expect_equivalent_dm(
    dm_db_learned_no_keys,
    dm_for_filter_no_keys
  )
})


test_that("Learning from specific schema on MSSQL or Postgres works?", {

  skip_if_src_not(c("mssql", "postgres"))
  src_db <- my_test_src()
  con_db <- src_db$con

  schema_name_q <- DBI::dbQuoteIdentifier(con_db, schema_name)

  DBI::dbExecute(con_db, paste0("CREATE SCHEMA ", schema_name_q))

  dm_for_disambiguate_copied <- copy_dm_to(
    src_db,
    dm_for_disambiguate(),
    temporary = FALSE,
    table_names = ~ DBI::SQL(paste0(schema_name_q, ".", .x))
  )
  order_of_deletion <- c("iris_3", "iris_2", "iris_1")
  remote_tbl_names <- set_names(paste0(schema_name_q, ".", order_of_deletion), order_of_deletion)

  withr::defer(
    {
      walk(
        remote_tbl_names,
        ~ try(dbExecute(con_db, paste0("DROP TABLE ", .x)))
      )
      try(dbExecute(con_db, paste0("DROP SCHEMA ", schema_name_q)))
    }
  )

  dm_db_learned <-
    dm_from_src(src_db, schema = schema_name, learn_keys = TRUE) %>%
    dm_select_tbl(!!!order_of_deletion)

  expect_equivalent_dm(
    dm_db_learned,
    dm_for_disambiguate()[order_of_deletion]
  )

  # learning without keys:
  dm_db_learned_no_keys <- expect_silent(dm_from_src(src_db, schema = schema_name, learn_keys = FALSE)) %>%
    dm_select_tbl(!!!order_of_deletion)

  dm_for_disambiguate_no_keys <- dm_for_disambiguate()[order_of_deletion] %>%
    dm_get_def() %>%
    mutate(
      pks = vctrs::list_of(new_pk()),
      fks = vctrs::list_of(new_fk())) %>%
    new_dm3()

  expect_equivalent_dm(
    dm_db_learned_no_keys,
    dm_for_disambiguate_no_keys
  )
})

test_that("Learning from SQLite works (#288)?", {
  skip("FIXME")
  src_sqlite <- skip_if_error(src_sqlite()(":memory:", TRUE))

  copy_to(src_sqlite(), tibble(a = 1:3), name = "test")

  expect_equivalent_dm(
    dm_from_src(src_sqlite()) %>%
      dm_select_tbl(test) %>%
      collect(),
    dm(test = tibble(a = 1:3))
  )
})


# tests for compound keys -------------------------------------------------

# test is already done in test-dm-from-src.R
