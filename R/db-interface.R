#' Copy data model to data source
#'
#' @description
#' `copy_dm_to()` takes a [dplyr::src_dbi] object or a [`DBI::DBIConnection-class`] object as its first argument
#' and a [`dm`] object as its second argument.
#' The latter is copied to the former.
#' The default is to create temporary tables, set `temporary = FALSE` to create permanent tables.
#' Unless `set_key_constraints` is `FALSE`, primary key constraints are set on all databases,
#' and in addition foreign key constraints are set on MSSQL and Postgres databases.
#'
#' @details
#' No tables will be overwritten; passing `overwrite = TRUE` to the function will give an error.
#' Types are determined separately for each table, setting the `types` argument will
#' also throw an error.
#' The arguments are included in the signature to avoid passing them via the
#' `...` ellipsis.
#'
#' @inheritParams dm_examine_constraints
#'
#' @param dest An object of class `"src"` or `"DBIConnection"`.
#' @param dm A `dm` object.
#' @param overwrite,types,indexes,unique_indexes Must remain `NULL`.
#' @param set_key_constraints If `TRUE` will mirror `dm` primary and foreign key constraints on a database
#'   and create unique indexes.
#'   Set to `FALSE` if your data model currently does not satisfy primary or foreign key constraints.
#' @param unique_table_names Deprecated.
#' @param temporary If `TRUE`, only temporary tables will be created.
#'   These tables will vanish when disconnecting from the database.
#' @param schema Name of schema to copy the `dm` to.
#' If `schema` is provided, an error will be thrown if `temporary = FALSE` or
#' `table_names` is not `NULL`.
#'
#' Not all DBMS are supported.
#' @param table_names Desired names for the tables on `dest`; the names within the `dm` remain unchanged.
#'   Can be `NULL`, a named character vector, a function or a one-sided formula.
#'
#'   If left `NULL` (default), the names will be determined automatically depending on the `temporary` argument:
#'
#'   1. `temporary = TRUE` (default): unique table names based on the names of the tables in the `dm` are created.
#'   1. `temporary = FALSE`: the table names in the `dm` are used as names for the tables on `dest`.
#'
#'   If a function or one-sided formula, `table_names` is converted to a function
#'   using [rlang::as_function()].
#'   This function is called with the unquoted table names of the `dm` object
#'   as the only argument.
#'   The output of this function is processed by [DBI::dbQuoteIdentifier()],
#'   that result should be a vector of identifiers of the same length
#'   as the original table names.
#'
#'   Use a variant of
#'   `table_names = ~ DBI::SQL(paste0("schema_name", ".", .x))`
#'   to specify the same schema for all tables.
#'   Use `table_names = identity` with `temporary = TRUE`
#'   to avoid giving temporary tables unique names.
#'
#'   If a named character vector,
#'   the names of this vector need to correspond to the table names in the `dm`,
#'   and its values are the desired names on `dest`.
#'   The value is processed by [DBI::dbQuoteIdentifier()],
#'   that result should be a vector of identifiers of the same length
#'   as the original table names.
#'
#'   Use qualified names corresponding to your database's syntax
#'   to specify e.g. database and schema for your tables.
#' @param copy_to By default, [dplyr::copy_to()] is called to upload the
#'   individual tables to the target data source.
#'   This argument allows overriding the standard behavior in cases
#'   when the default does not work as expected, such as spatial data frames
#'   or other tables with special data types.
#'   If not `NULL`, this argument is processed with [rlang::as_function()].
#' @param ... Passed on to [dplyr::copy_to()] or to the function specified
#'   by the `copy_to` argument.
#'
#' @family DB interaction functions
#'
#' @return A `dm` object on the given `src` with the same table names
#'   as the input `dm`.
#'
#' @examplesIf rlang::is_installed("RSQLite") && rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")
#' con <- DBI::dbConnect(RSQLite::SQLite())
#'
#' # Copy to temporary tables, unique table names by default:
#' temp_dm <- copy_dm_to(
#'   con,
#'   dm_nycflights13(),
#'   set_key_constraints = FALSE
#' )
#'
#' # Persist, explicitly specify table names:
#' persistent_dm <- copy_dm_to(
#'   con,
#'   dm_nycflights13(),
#'   temporary = FALSE,
#'   table_names = ~ paste0("flights_", .x)
#' )
#' dbplyr::remote_name(persistent_dm$planes)
#'
#' DBI::dbDisconnect(con)
#' @export
copy_dm_to <- function(dest, dm, ...,
                       types = NULL, overwrite = NULL,
                       indexes = NULL, unique_indexes = NULL,
                       set_key_constraints = TRUE, unique_table_names = NULL,
                       table_names = NULL,
                       temporary = TRUE,
                       schema = NULL,
                       progress = NA,
                       copy_to = NULL) {
  # for the time being, we will be focusing on MSSQL
  # we want to
  #   1. change `dm_get_src_impl(dm)` to `dest`
  #   2. copy the tables to `dest`
  #   3. implement the key situation within our `dm` on the DB

  if (!is_null(overwrite)) {
    abort_no_overwrite()
  }

  if (!is_null(types)) {
    abort_no_types()
  }

  if (!is_null(indexes)) {
    abort_no_indexes()
  }

  if (!is_null(unique_indexes)) {
    abort_no_unique_indexes()
  }

  if (!is.null(unique_table_names)) {
    deprecate_soft(
      "0.1.4", "dm::copy_dm_to(unique_table_names = )",
      details = "Use `table_names = identity` to use unchanged names for temporary tables."
    )

    if (is.null(table_names) && temporary && !unique_table_names) {
      table_names <- identity
    }
  }

  dest <- src_from_src_or_con(dest)
  src_names <- src_tbls_impl(dm)

  if (is_db(dest)) {
    dest_con <- con_from_src_or_con(dest)

    # in case `table_names` was chosen by the user, check if the input makes sense:
    # 1. is there one name per dm-table?
    # 2. are there any duplicated table names?
    # 3. is it a named character or ident_q vector with the correct names?
    if (is.null(table_names)) {
      table_names_out <- repair_table_names_for_db(src_names, temporary, dest_con, schema)
      # https://github.com/tidyverse/dbplyr/issues/487
      if (is_mssql(dest)) {
        temporary <- FALSE
      }
    } else {
      if (!is.null(schema)) abort_one_of_schema_table_names()
      if (is_function(table_names) || is_bare_formula(table_names)) {
        table_name_fun <- as_function(table_names)
        table_names_out <- set_names(table_name_fun(src_names), src_names)
      } else {
        table_names_out <- table_names
      }
      check_naming(names(table_names_out), src_names)

      if (anyDuplicated(table_names_out)) {
        problem <- table_names_out[duplicated(table_names_out)][[1]]
        abort_copy_dm_to_table_names_duplicated(problem)
      }

      table_names_out <- unclass(DBI::dbQuoteIdentifier(dest_con, unclass(table_names_out[src_names])))
      names(table_names_out) <- src_names
    }

    # create `ident`-class objects from the table names
    table_names_out <- map(table_names_out, dbplyr::ident_q)
  } else {
    # FIXME: Other data sources than local and database possible
    deprecate_soft(
      "0.1.6", "dm::copy_dm_to(dest = 'must refer to a remote data source')",
      "dm::collect.dm()"
    )
    table_names_out <- set_names(src_names)
  }

  check_not_zoomed(dm)

  # FIXME: if same_src(), can use compute() but need to set NOT NULL and other
  # constraints

  dm <- collect(dm, progress = progress)

  # Shortcut necessary to avoid copying into .GlobalEnv
  if (!is_db(dest)) {
    return(dm)
  }
  # get autoincrement PK cols, since they need to be removed from the dm tables before transferring them to the DB
  autoinc_pks <- if (is_db(dest)) {
    dm_get_all_pks(dm) %>%
      filter(autoincrement) %>%
      select(-autoincrement, autoinc_col = pk_col) %>%
      mutate(autoinc_col = map_chr(autoinc_col, ~ get_key_cols(.x)))
  } else {
    tibble(table = character(), autoinc_col = new_keys())
  }

  # needed later to check for FKs that point to autoincrement PKs
  fks <- dm_get_all_fks_impl(dm) %>%
    select(name = parent_table, parent_key_cols, child_table, child_fk_cols)

  queries <- build_copy_queries(dest_con, dm, set_key_constraints, temporary, table_names_out) %>%
    left_join(autoinc_pks, by = c("name" = "table"))

  ticker_create <- new_ticker(
    "creating tables",
    n = length(queries$sql_table),
    progress = progress,
    top_level_fun = "copy_dm_to"
  )

  # create tables
  walk(queries$sql_table, ticker_create(~ {
    DBI::dbExecute(dest_con, .x, immediate = TRUE)
  }))

  ticker_populate <- new_ticker(
    "populating tables",
    n = length(queries$name),
    progress = progress,
    top_level_fun = "copy_dm_to"
  )


  # populate tables
  for (i in seq_along(queries$name)) {
    res <- db_append_table(
      con = dest_con,
      remote_table = queries$remote_name[[i]],
      table = dm[[queries$name[i]]],
      autoinc_col = queries$autoinc_col[[i]],
      progress = progress
    )
    # in case queries$autoinc_col[[i]] is NA, there is the possibility that fks$parent_key_cols contains
    # more than 1 column, which makes `get_key_cols()` fail
    fks_ai <- if (!is_na(queries$autoinc_col[[i]])) {
      filter(fks, name == queries$name[i], map_lgl(parent_key_cols, ~ get_key_cols(.x) == queries$autoinc_col[[i]]))
    } else {
      filter(fks, 1 == 0)
    }
    dm <- upd_dm_w_autoinc(dm, fks_ai, res)
  }

  ticker_index <- new_ticker(
    "creating indexes",
    n = sum(lengths(queries$sql_index)),
    progress = progress,
    top_level_fun = "copy_dm_to"
  )

  # create indexes
  walk(unlist(queries$sql_index), ticker_index(~ {
    DBI::dbExecute(dest_con, .x, immediate = TRUE)
  }))

  # build remote dm
  remote_tables <-
    queries$remote_name %>%
    set_names(queries$name) %>%
    map(tbl, src = dest_con)
  # remote dm is same as source dm with replaced data
  def <- dm_get_def(dm)
  def$data <- unname(remote_tables[names(dm)])
  remote_dm <- new_dm3(def)

  invisible(debug_dm_validate(remote_dm))
}

get_db_table_names <- function(dm) {
  if (!is_src_db(dm)) {
    return(tibble(table_name = src_tbls_impl(dm), remote_name = src_tbls_impl(dm)))
  }
  tibble(
    table_name = src_tbls_impl(dm),
    remote_name = map_chr(dm_get_tables_impl(dm), dbplyr::remote_name)
  )
}

check_naming <- function(table_names, dm_table_names) {
  if (!identical(sort(table_names), sort(dm_table_names))) {
    abort_copy_dm_to_table_names()
  }
}

db_append_table <- function(con, remote_table, table, autoinc_col, progress, top_level_fun = "copy_dm_to") {
  if (nrow(table) == 0 || ncol(table) == 0) {
    return(invisible())
  }

  cols <- colnames(table)
  table_wo_aic <- select(table, !!!setdiff(cols, autoinc_col))

  if (is_mssql(con)) {
    # FIXME: Make adaptive
    chunk_size <- 1000L
    n_chunks <- ceiling(nrow(table) / chunk_size)

    ticker <- new_ticker(
      paste0("inserting into ", remote_table),
      n = n_chunks,
      progress = progress,
      top_level_fun = top_level_fun
    )

    walk(seq_len(n_chunks), ticker(~ {
      end <- .x * chunk_size
      idx <- seq2(end - (chunk_size - 1), min(end, nrow(table)))
      values <- map(table[idx, ], mssql_escape, con = con)
      # Can't use dbAppendTable(): https://github.com/r-dbi/odbc/issues/480
      sql <- DBI::sqlAppendTable(con, DBI::SQL(remote_table), values, row.names = FALSE)
      DBI::dbExecute(con, sql, immediate = TRUE)
    }))
  } else if (is_postgres(con)) {
    # https://github.com/r-dbi/RPostgres/issues/384
    if (!is_na(autoinc_col)) {
      x <- tbl(con, remote_table)
      returned <- rows_append(x, table_wo_aic, returning = !!sym(autoinc_col), copy = TRUE, in_place = TRUE)
      returned_rows <- dbplyr::get_returned_rows(returned) %>%
        rename(remote = 1) %>%
        bind_cols(select(table, original = !!sym(autoinc_col)))
    } else {
      table_wo_aic <- as.data.frame(table_wo_aic)
      # https://github.com/r-dbi/RPostgres/issues/382
      DBI::dbAppendTable(con, DBI::SQL(remote_table), table_wo_aic, copy = FALSE)
      returned_rows <- tibble(remote = character(), original = character())
    }
  } else {
    DBI::dbAppendTable(con, DBI::SQL(remote_table), table)
  }
  returned_rows
}

# Errors ------------------------------------------------------------------

abort_copy_dm_to_table_names <- function() {
  abort(error_txt_copy_dm_to_table_names(), class = dm_error_full("copy_dm_to_table_names"))
}

error_txt_copy_dm_to_table_names <- function() {
  "`table_names` must have names that are the same as the table names in `dm`."
}

abort_copy_dm_to_table_names_duplicated <- function(problem) {
  abort(error_txt_copy_dm_to_table_names_duplicated(problem), class = dm_error_full("copy_dm_to_table_names_duplicated"))
}

error_txt_copy_dm_to_table_names_duplicated <- function(problem) {
  c(
    "`table_names` must be unique.",
    i = paste0("Duplicate: ", tick(problem))
  )
}
