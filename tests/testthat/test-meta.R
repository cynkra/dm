test_that("dummy", {
  # To avoid deletion of file
  expect_snapshot({
    TRUE
  })
})

test_that("dm_meta() data model", {
  skip_if_src_not(c("mssql", "postgres"))

  expect_snapshot({
    dm_meta(my_test_src()) %>%
      dm_paste(options = c("select", "keys", "color"))
  })
})

test_that("dm_meta(simple = TRUE) columns", {
  tryCatch(
    columns <-
      my_db_test_src() %>%
      dm_meta(simple = TRUE) %>%
      .$columns %>%
      filter(tolower(table_schema) == "information_schema") %>%
      arrange(table_name, ordinal_position) %>%
      select(-table_catalog) %>%
      collect(),
    error = function(e) {
      skip(conditionMessage(e))
    }
  )

  path <- tempfile(fileext = ".csv")
  write.csv(columns, path, na = "")

  expect_snapshot_file(path, name = "columns.csv", variant = my_test_src_name)
})

test_that("dm_meta() contents", {
  skip_if_src_not(c("mssql", "postgres", "maria"))

  # produces a randomized schema name with a length of 4-10 characters
  # consisting of the symbols in `reservoir`
  random_schema <- function() {
    reservoir <- c(letters, LETTERS, "'", "-", "_", as.character(0:9))
    how_long <- sample(4:10, 1)
    paste0(reservoir[sample(seq_len(length(reservoir)), how_long, replace = TRUE)], collapse = "")
  }

  schema_name <- random_schema()

  # dm_learn_from_mssql() --------------------------------------------------
  con_db <- my_test_con()

  schema_name_q <- DBI::dbQuoteIdentifier(con_db, schema_name)

  DBI::dbExecute(con_db, paste0("CREATE SCHEMA ", schema_name_q))

  # create an object on the MSSQL-DB that can be learned
  withr::defer({
    try(walk(
      order_of_deletion,
      ~ try(dbExecute(con_db, paste0("DROP TABLE ", schema_name_q, ".", .x, " CASCADE")))
    ))
    try(dbExecute(con_db, paste0("DROP SCHEMA ", schema_name_q)))
  })

  dm_for_filter_copied <- copy_dm_to(con_db, dm_for_filter(), temporary = FALSE, schema = schema_name)
  order_of_deletion <- c("tf_2", "tf_1", "tf_5", "tf_6", "tf_4", "tf_3")

  meta <- dm_meta(con_db, schema = schema_name)

  constraints <- dm_examine_constraints(meta, progress = FALSE)
  expect_true(all(constraints$is_key))

  expect_snapshot({
    meta %>%
      dm_select_tbl(-schemata) %>%
      dm_zoom_to(table_constraints) %>%
      filter(constraint_type %in% c("PRIMARY KEY", "FOREIGN KEY")) %>%
      dm_update_zoomed() %>%
      dm_get_tables() %>%
      map(select, -any_of("constraint_name"), -any_of("column_default"), -contains("catalog"), -contains("schema")) %>%
      map(arrange_all) %>%
      map(collect) %>%
      jsonlite::toJSON(pretty = TRUE) %>%
      gsub(schema_name, "schema_name", .) %>%
      gsub('(_catalog": ")[^"]*(")', "\\1catalog\\2", .) %>%
      writeLines()
  })
})
