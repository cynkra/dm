dm_meta <- function(con, catalog = NA, schema = NULL, simple = FALSE, error_call = caller_env()) {
  if (is_sqlite(con)) {
    return(dm_meta_sqlite(
      con,
      catalog = catalog,
      schema = schema,
      simple = simple,
      error_call = error_call
    ))
  }

  need_collect <- FALSE

  if (is_mssql(con)) {
    if (is.null(catalog)) {
      # FIXME: Classed error message?
      cli::cli_abort("SQL server only supports learning from one database.")
    }

    if (!is.na(catalog)) {
      message("Temporarily switching to database ", tick(catalog), ".")
      old_dbname <- DBI::dbGetQuery(con, "SELECT DB_NAME()")[[1]]
      sql <- paste0("USE ", DBI::dbQuoteIdentifier(con, catalog))
      old_sql <- paste0("USE ", DBI::dbQuoteIdentifier(con, old_dbname))
      DBI::dbExecute(con, sql, immediate = TRUE)
      withr::defer({
        DBI::dbExecute(con, old_sql, immediate = TRUE)
      })
      need_collect <- TRUE
    }
  }

  if (simple) {
    out <-
      dm_meta_simple_raw(con) %>%
      filter_dm_meta_simple(catalog, schema)
  } else {
    out <-
      dm_meta_raw(con, catalog) %>%
      select_dm_meta() %>%
      filter_dm_meta(catalog, schema)
  }

  if (need_collect) {
    out <-
      out %>%
      collect()
  }

  out
}

#' @autoglobal
dm_meta_raw <- function(con, catalog) {
  src <- src_from_src_or_con(con)

  local_options(digits.secs = 6)

  schemata <- tbl_lc(
    src,
    "information_schema.schemata",
    vars = vec_c(
      "catalog_name",
      "schema_name",
      "default_character_set_name",
      # Optional, not MySQL:
      # "schema_owner", "default_character_set_catalog", "default_character_set_schema",
    )
  )
  tables <- tbl_lc(
    src,
    "information_schema.tables",
    vars = vec_c(
      "table_catalog",
      "table_schema",
      "table_name",
      "table_type",
    )
  )
  columns <- tbl_lc(
    src,
    "information_schema.columns",
    vars = vec_c(
      "table_catalog",
      "table_schema",
      "table_name",
      "column_name",
      "ordinal_position",
      "column_default",
      "is_nullable",
      "data_type",
      "character_maximum_length",
      "character_octet_length",
      "numeric_precision",
      "numeric_scale",
      "datetime_precision",
      "character_set_name",
      "collation_name",
      if (is_mariadb(src)) "extra" else NULL,

      # Optional, not RMySQL:
      # "numeric_precision_radix",
      # "character_set_catalog", "character_set_schema",
      # "collation_catalog", "collation_schema", "domain_catalog",
      # "domain_schema", "domain_name"
    )
  )

  # add is_autoincrement column to columns table
  if (is_mssql(src)) {
    columns <- columns %>%
      mutate(
        is_autoincrement = sql(
          "CAST(COLUMNPROPERTY(object_id(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') AS BIT)"
        )
      )
  } else if (is_postgres(src) || is_redshift(src)) {
    columns <- columns %>%
      mutate(
        is_autoincrement = sql(
          "CASE WHEN column_default IS NULL THEN FALSE ELSE column_default SIMILAR TO '%nextval%' END"
        )
      )
  } else if (is_mariadb(src)) {
    columns <- columns %>%
      mutate(is_autoincrement = sql("extra REGEXP 'auto_increment'")) %>%
      select(-extra)
  } else {
    cli::cli_alert_warning("unable to fetch autoincrement metadata for src '{class(src)[1]}'")
    columns <- columns %>%
      mutate(is_autoincrement = NA)
  }

  if (is_mariadb(src)) {
    table_constraints <- tbl_lc(
      src,
      "information_schema.table_constraints",
      vars = vec_c(
        "constraint_catalog",
        "constraint_schema",
        "constraint_name",
        "table_name",
        "constraint_type"
      )
    ) %>%
      mutate(
        table_catalog = constraint_catalog,
        table_schema = constraint_schema,
        .before = table_name
      ) %>%
      mutate(
        constraint_name = if_else(
          constraint_type == "PRIMARY KEY",
          paste0("pk_", table_name),
          constraint_name
        )
      ) %>%
      left_join(
        tbl_lc(
          src,
          "information_schema.referential_constraints",
          vars = vec_c(
            "constraint_catalog",
            "constraint_schema",
            "constraint_name",
            # "unique_constraint_catalog", "unique_constraint_schema",
            # "unique_constraint_name", "match_option", "update_rule",
            # "table_name", "referenced_table_name"
            "delete_rule"
          )
        ),
        by = c("constraint_catalog", "constraint_schema", "constraint_name")
      )
  } else {
    table_constraints <- tbl_lc(
      src,
      "information_schema.table_constraints",
      vars = vec_c(
        "constraint_catalog",
        "constraint_schema",
        "constraint_name",
        "table_catalog",
        "table_schema",
        "table_name",
        "constraint_type",
        "is_deferrable",
        "initially_deferred",
      )
    ) %>%
      left_join(
        tbl_lc(
          src,
          "information_schema.referential_constraints",
          vars = vec_c(
            "constraint_catalog",
            "constraint_schema",
            "constraint_name",
            # "unique_constraint_catalog", "unique_constraint_schema",
            # "unique_constraint_name", "match_option", "update_rule",
            "delete_rule"
          )
        ),
        by = c("constraint_catalog", "constraint_schema", "constraint_name")
      )
  }

  key_column_usage <- tbl_lc(
    src,
    "information_schema.key_column_usage",
    vars = vec_c(
      "constraint_catalog",
      "constraint_schema",
      "constraint_name",
      "table_catalog",
      "table_schema",
      "table_name",
      "column_name",
      "ordinal_position",
    )
  )

  if (is_postgres(src)) {
    # Need hand-crafted query for now
    constraint_column_usage <-
      tbl(
        src,
        sql(postgres_column_constraints),
        vars = c(
          "table_catalog",
          "table_schema",
          "table_name",
          "column_name",
          "constraint_catalog",
          "constraint_schema",
          "constraint_name",
          "ordinal_position"
        )
      )
  } else if (is_redshift(src)) {
    constraint_column_usage <-
      tbl_lc(
        src,
        "information_schema.key_column_usage",
        vars = c(
          "table_catalog",
          "table_schema",
          "table_name",
          "column_name",
          "constraint_catalog",
          "constraint_schema",
          "constraint_name",
          "ordinal_position"
        )
      ) %>%
      filter(!is.na(table_name))
  } else if (is_mssql(src)) {
    constraint_column_usage <- mssql_constraint_column_usage(src, table_constraints, catalog)
  } else {
    # Alternate constraint names for uniqueness
    key_column_usage <-
      key_column_usage %>%
      left_join(
        tbl_lc(
          src,
          "information_schema.table_constraints",
          vars = vec_c(
            "constraint_catalog",
            "constraint_schema",
            "constraint_name",
            "table_name",
            "constraint_type"
          )
        ),
        by = vec_c(
          "constraint_catalog",
          "constraint_schema",
          "constraint_name",
          "table_name",
        )
      ) %>%
      mutate(
        constraint_name = if_else(
          constraint_type == "PRIMARY KEY",
          paste0("pk_", table_name),
          constraint_name
        )
      ) %>%
      select(-constraint_type)

    constraint_column_usage <-
      tbl_lc(
        src,
        "information_schema.key_column_usage",
        vars = c(
          "table_catalog",
          "referenced_table_schema",
          "referenced_table_name",
          "referenced_column_name",
          "constraint_catalog",
          "constraint_schema",
          "constraint_name",
          "ordinal_position"
        )
      ) %>%
      filter(!is.na(referenced_table_name)) %>%
      rename(
        table_schema = referenced_table_schema,
        table_name = referenced_table_name,
        column_name = referenced_column_name,
      )
  }

  dm(schemata, tables, columns, table_constraints, key_column_usage, constraint_column_usage) %>%
    dm_meta_add_keys()
}

#' @autoglobal
dm_meta_add_keys <- function(dm_meta) {
  dm_meta %>%
    dm_meta_simple_add_keys() %>%
    # dm_add_fk(table_constraints, table_schema, schemata) %>%
    dm_add_pk(table_constraints, c(constraint_catalog, constraint_schema, constraint_name)) %>%
    dm_add_fk(table_constraints, c(table_catalog, table_schema, table_name), tables) %>%
    # constraint_schema vs. table_schema?

    # not on mssql:
    # dm_add_fk(referential_constraints, c(constraint_schema, table_name), tables) %>%
    # dm_add_fk(referential_constraints, c(constraint_schema, referenced_table_name), tables) %>%

    dm_add_pk(
      key_column_usage,
      c(constraint_catalog, constraint_schema, constraint_name, ordinal_position)
    ) %>%
    dm_add_fk(
      key_column_usage,
      c(table_catalog, table_schema, table_name, column_name),
      columns
    ) %>%
    dm_add_fk(
      key_column_usage,
      c(constraint_catalog, constraint_schema, constraint_name),
      table_constraints
    ) %>%
    #
    # not on mariadb;
    dm_add_pk(
      constraint_column_usage,
      c(constraint_catalog, constraint_schema, constraint_name, ordinal_position)
    ) %>%
    dm_add_fk(
      constraint_column_usage,
      c(table_catalog, table_schema, table_name, column_name),
      columns
    ) %>%
    dm_add_fk(
      constraint_column_usage,
      c(constraint_catalog, constraint_schema, constraint_name),
      table_constraints
    ) %>%
    dm_add_fk(
      constraint_column_usage,
      c(constraint_catalog, constraint_schema, constraint_name, ordinal_position),
      key_column_usage
    ) %>%
    #
    dm_set_colors(green4 = ends_with("_constraints"), orange = ends_with("_usage"))
}

#' @autoglobal
dm_meta_sqlite <- function(
  con,
  catalog = NA,
  schema = NULL,
  simple = FALSE,
  error_call = caller_env()
) {
  if (!is.na(catalog)) {
    cli::cli_abort("{.arg catalog} must be {.code NA} for SQLite connections.", call = error_call)
  }

  catalog <- NA_character_
  if (is.null(schema)) {
    schema <- "main"
  }

  # FIXME: Use dbListObjects() when it works, https://github.com/r-dbi/RSQLite/issues/689
  schema_q <- DBI::dbQuoteIdentifier(con, schema)
  table_names_df <- DBI::dbGetQuery(
    con,
    paste0(
      "SELECT name FROM ",
      schema_q,
      ".sqlite_master",
      " WHERE type = 'table' AND name NOT LIKE 'sqlite_%'"
    )
  )
  table_names <- table_names_df$name

  schemata <- tibble(catalog_name = catalog, schema_name = schema)

  tables <- tibble(
    table_catalog = catalog,
    table_schema = schema,
    table_name = table_names,
    table_type = "BASE TABLE",
  )

  pragma_table_info <- map(set_names(table_names), function(t) {
    t_quoted <- DBI::dbQuoteIdentifier(con, t)
    DBI::dbGetQuery(con, paste0("PRAGMA ", schema_q, ".table_info(", t_quoted, ")"))
  })

  pragma_fk_list <- map(set_names(table_names), function(t) {
    t_quoted <- DBI::dbQuoteIdentifier(con, t)
    DBI::dbGetQuery(con, paste0("PRAGMA ", schema_q, ".foreign_key_list(", t_quoted, ")"))
  })

  columns <- imap_dfr(pragma_table_info, function(info, tbl) {
    if (nrow(info) == 0) {
      return(NULL)
    }
    tibble(
      table_catalog = catalog,
      table_schema = schema,
      table_name = tbl,
      column_name = info$name,
      ordinal_position = as.integer(info$cid + 1L),
      column_default = as.character(info$dflt_value),
      is_nullable = ifelse(info$notnull == 0L, "YES", "NO"),
      data_type = tolower(info$type),
      is_autoincrement = FALSE,
    )
  })

  if (simple) {
    return(
      dm(schemata, tables, columns) %>%
        dm_meta_simple_add_keys()
    )
  }

  # PK constraints: one row per table that has PK columns

  pk_constraints <- imap_dfr(pragma_table_info, function(info, tbl) {
    pk_cols <- info[info$pk > 0, , drop = FALSE]
    if (nrow(pk_cols) == 0) {
      return(NULL)
    }
    tibble(
      constraint_catalog = catalog,
      constraint_schema = schema,
      constraint_name = paste0("pk_", tbl),
      table_catalog = catalog,
      table_schema = schema,
      table_name = tbl,
      constraint_type = "PRIMARY KEY",
      delete_rule = NA_character_,
    )
  })

  # FK constraints: one row per FK relationship
  fk_constraints <- imap_dfr(pragma_fk_list, function(fks, tbl) {
    if (nrow(fks) == 0) {
      return(NULL)
    }
    fks %>%
      distinct(.data$id, .keep_all = TRUE) %>%
      transmute(
        constraint_catalog = catalog,
        constraint_schema = schema,
        constraint_name = paste0("fk_", tbl, "_", .data$id),
        table_catalog = catalog,
        table_schema = schema,
        table_name = tbl,
        constraint_type = "FOREIGN KEY",
        delete_rule = .data$on_delete,
      )
  })

  empty_constraints <- tibble(
    constraint_catalog = character(),
    constraint_schema = character(),
    constraint_name = character(),
    table_catalog = character(),
    table_schema = character(),
    table_name = character(),
    constraint_type = character(),
    delete_rule = character(),
  )
  table_constraints <- vec_rbind(empty_constraints, pk_constraints, fk_constraints)

  # key_column_usage: PK columns
  pk_key_usage <- imap_dfr(pragma_table_info, function(info, tbl) {
    pk_cols <- info[info$pk > 0, , drop = FALSE]
    if (nrow(pk_cols) == 0) {
      return(NULL)
    }
    tibble(
      constraint_catalog = catalog,
      constraint_schema = schema,
      constraint_name = paste0("pk_", tbl),
      table_catalog = catalog,
      table_schema = schema,
      table_name = tbl,
      column_name = pk_cols$name,
      ordinal_position = as.integer(pk_cols$pk)
    )
  })

  # key_column_usage: FK child columns
  fk_key_usage <- imap_dfr(pragma_fk_list, function(fks, tbl) {
    if (nrow(fks) == 0) {
      return(NULL)
    }
    tibble(
      constraint_catalog = catalog,
      constraint_schema = schema,
      constraint_name = paste0("fk_", tbl, "_", fks$id),
      table_catalog = catalog,
      table_schema = schema,
      table_name = tbl,
      column_name = fks$from,
      ordinal_position = as.integer(fks$seq + 1L),
    )
  })

  empty_key_usage <- tibble(
    constraint_catalog = character(),
    constraint_schema = character(),
    constraint_name = character(),
    table_catalog = character(),
    table_schema = character(),
    table_name = character(),
    column_name = character(),
    ordinal_position = integer(),
  )
  key_column_usage <- vec_rbind(empty_key_usage, pk_key_usage, fk_key_usage)

  # constraint_column_usage: FK parent (referenced) columns
  empty_ccu <- tibble(
    table_catalog = character(),
    table_schema = character(),
    table_name = character(),
    column_name = character(),
    constraint_catalog = character(),
    constraint_schema = character(),
    constraint_name = character(),
    ordinal_position = integer(),
  )
  constraint_column_usage <- imap_dfr(pragma_fk_list, function(fks, tbl) {
    if (nrow(fks) == 0) {
      return(NULL)
    }
    tibble(
      table_catalog = catalog,
      table_schema = schema,
      table_name = fks$table,
      column_name = fks$to,
      constraint_catalog = catalog,
      constraint_schema = schema,
      constraint_name = paste0("fk_", tbl, "_", fks$id),
      ordinal_position = as.integer(fks$seq + 1L),
    )
  })
  constraint_column_usage <- vec_rbind(empty_ccu, constraint_column_usage)

  dm(schemata, tables, columns, table_constraints, key_column_usage, constraint_column_usage) %>%
    dm_meta_add_keys()
}

dm_meta_simple_raw <- function(con) {
  src <- src_from_src_or_con(con)

  local_options(digits.secs = 6)

  schemata <- tbl_lc(
    src,
    "information_schema.schemata",
    vars = c(
      "catalog_name",
      "schema_name"
    )
  )
  tables <- tbl_lc(
    src,
    "information_schema.tables",
    vars = c(
      "table_catalog",
      "table_schema",
      "table_name",
      "table_type"
    )
  )
  columns <- tbl_lc(
    src,
    "information_schema.columns",
    vars = c(
      "table_catalog",
      "table_schema",
      "table_name",
      "column_name",
      "ordinal_position",
      "column_default",
      "is_nullable",
      "data_type"
    )
  )

  dm(schemata, tables, columns) %>%
    dm_meta_simple_add_keys()
}

#' @autoglobal
dm_meta_simple_add_keys <- function(dm_meta) {
  dm_meta %>%
    dm_add_pk(schemata, c(catalog_name, schema_name)) %>%
    dm_add_pk(tables, c(table_catalog, table_schema, table_name)) %>%
    dm_add_fk(tables, c(table_catalog, table_schema), schemata) %>%
    dm_add_pk(columns, c(table_catalog, table_schema, table_name, column_name)) %>%
    dm_add_fk(columns, c(table_catalog, table_schema, table_name), tables) %>%
    #
    dm_set_colors(brown = c(tables, columns), blue = schemata)
}

tbl_lc <- function(con, name, vars) {
  # For discovery only!
  if (is.null(vars)) {
    from <- name
  } else {
    quoted_vars <- DBI::dbQuoteIdentifier(con_from_src_or_con(con), vars)
    from <- sql(paste0(
      "SELECT ",
      # Be especially persuasive for MySQL
      paste0(quoted_vars, " AS ", quoted_vars, collapse = ", "),
      "\nFROM ",
      name
    ))
  }

  out <- tbl(con, from, vars = vars)
  if (is.null(vars)) {
    out <-
      out %>%
      rename(!!!set_names(colnames(out), tolower(colnames(out))))
  }
  out
}

#' @autoglobal
select_dm_meta <- function(dm_meta) {
  dm_meta %>%
    dm_select(schemata, catalog_name, schema_name) %>%
    dm_select(tables, table_catalog, table_schema, table_name, table_type) %>%
    dm_select(
      columns,
      table_catalog,
      table_schema,
      table_name,
      column_name,
      ordinal_position,
      column_default,
      is_nullable,
      is_autoincrement
    ) %>%
    dm_select(
      table_constraints,
      constraint_catalog,
      constraint_schema,
      constraint_name,
      table_catalog,
      table_schema,
      table_name,
      constraint_type,
      delete_rule
    ) %>%
    dm_select(
      key_column_usage,
      constraint_catalog,
      constraint_schema,
      constraint_name,
      table_catalog,
      table_schema,
      table_name,
      column_name,
      ordinal_position
    ) %>%
    dm_select(
      constraint_column_usage,
      table_catalog,
      table_schema,
      table_name,
      column_name,
      constraint_catalog,
      constraint_schema,
      constraint_name,
      ordinal_position
    )
}

#' @autoglobal
#' @global DATABASE
filter_dm_meta <- function(dm_meta, catalog = NULL, schema = NULL) {
  force(catalog)
  force(schema)

  if (length(schema) > 1 && anyNA(schema)) {
    cli::cli_abort("{.arg schema} must not contain NA if it has more than one element.")
  }

  schemata <- dm_meta$schemata
  tables <- dm_meta$tables
  columns <- dm_meta$columns
  table_constraints <- dm_meta$table_constraints
  key_column_usage <- dm_meta$key_column_usage
  constraint_column_usage <- dm_meta$constraint_column_usage

  if (!is.null(catalog) && !is.na(catalog)) {
    schemata <- schemata %>% filter(catalog_name %in% !!catalog)
    tables <- tables %>% filter(table_catalog %in% !!catalog)
    columns <- columns %>% filter(table_catalog %in% !!catalog)
    table_constraints <- table_constraints %>% filter(table_catalog %in% !!catalog)
    key_column_usage <- key_column_usage %>% filter(table_catalog %in% !!catalog)
    constraint_column_usage <- constraint_column_usage %>% filter(table_catalog %in% !!catalog)
  }

  if (!is.null(schema) && !anyNA(schema)) {
    schemata <- schemata %>% filter(schema_name %in% !!schema)
    tables <- tables %>% filter(table_schema %in% !!schema)
    columns <- columns %>% filter(table_schema %in% !!schema)
    table_constraints <- table_constraints %>% filter(table_schema %in% !!schema)
    key_column_usage <- key_column_usage %>% filter(table_schema %in% !!schema)
    constraint_column_usage <- constraint_column_usage %>% filter(table_schema %in% !!schema)
  } else if (!isTRUE(is.na(schema)) && is_mariadb(dm_get_con(dm_meta))) {
    schemata <- schemata %>% filter(schema_name == DATABASE() | is.na(DATABASE()))
    tables <- tables %>% filter(table_schema == DATABASE() | is.na(DATABASE()))
    columns <- columns %>% filter(table_schema == DATABASE() | is.na(DATABASE()))
    table_constraints <- table_constraints %>%
      filter(table_schema == DATABASE() | is.na(DATABASE()))
    key_column_usage <- key_column_usage %>% filter(table_schema == DATABASE() | is.na(DATABASE()))
    constraint_column_usage <- constraint_column_usage %>%
      filter(table_schema == DATABASE() | is.na(DATABASE()))
  }

  dm(
    schemata,
    tables,
    columns,
    table_constraints,
    key_column_usage,
    constraint_column_usage
  ) %>%
    dm_meta_add_keys()
}

#' @autoglobal
filter_dm_meta_simple <- function(dm_meta, catalog = NULL, schema = NULL) {
  force(catalog)
  force(schema)

  schemata <- dm_meta$schemata
  tables <- dm_meta$tables
  columns <- dm_meta$columns

  if (!is.null(catalog) && !is.na(catalog)) {
    schemata <- schemata %>% filter(catalog_name %in% !!catalog)
    tables <- tables %>% filter(table_catalog %in% !!catalog)
    columns <- columns %>% filter(table_catalog %in% !!catalog)
  }

  if (!is.null(schema)) {
    schemata <- schemata %>% filter(schema_name %in% !!schema)
    tables <- tables %>% filter(table_schema %in% !!schema)
    columns <- columns %>% filter(table_schema %in% !!schema)
  } else if (!is.null(schema) && !is.na(schema) && is_mariadb(dm_get_con(dm_meta))) {
    schemata <- schemata %>% filter(schema_name == DATABASE() | is.na(DATABASE()))
    tables <- tables %>% filter(table_schema == DATABASE() | is.na(DATABASE()))
    columns <- columns %>% filter(table_schema == DATABASE() | is.na(DATABASE()))
  }

  dm(schemata, tables, columns) %>%
    dm_meta_simple_add_keys()
}
