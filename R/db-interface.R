#' Copy data model to data source
#'
#' @description
#' `copy_dm_to()` takes a [`dbplyr::src_dbi`] object or a [`DBI::DBIConnection-class`] object as its first argument
#' and a [`dm`] object as its second argument.
#' The latter is copied to the former.
#' The default is to create temporary tables, set `temporary = FALSE` to create permanent tables.
#' Unless `set_key_constraints` is `FALSE`, primary key, foreign key, and unique constraints
#' are set, and indexes for foreign keys are created, on all databases.
#'
#' @inheritParams dm_examine_constraints
#'
#' @param dest An object of class `"src"` or `"DBIConnection"`.
#' @param dm A `dm` object.
#' @inheritParams rlang::args_dots_empty
#' @param set_key_constraints If `TRUE` will mirror
#'   the primary, foreign, and unique key constraints
#'   and create indexes for foreign key constraints
#'   for the primary and foreign keys in the `dm` object.
#'   Set to `FALSE` if your data model currently does not satisfy
#'   primary or foreign key constraints.
#' @param temporary If `TRUE`, only temporary tables will be created.
#'   These tables will vanish when disconnecting from the database.
#' @param schema Name of schema to copy the `dm` to.
#'   If `schema` is provided, an error will be thrown if `temporary = FALSE` or
#'   `table_names` is not `NULL`.
#'
#'   Not all DBMS are supported.
#' @param table_names Desired names for the tables on `dest`; the names within the `dm` remain unchanged.
#'   Can be `NULL`, a named character vector, or a vector of [`DBI::Id`] objects.
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
#' @param unique_table_names,copy_to Must be `NULL`.
#'
#' @family DB interaction functions
#'
#' @return A `dm` object on the given `src` with the same table names
#'   as the input `dm`.
#'
#' @examplesIf rlang::is_installed(c("RSQLite", "nycflights13", "dbplyr"))
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
copy_dm_to <- function(
  dest,
  dm,
  ...,
  set_key_constraints = TRUE,
  table_names = NULL,
  temporary = TRUE,
  schema = NULL,
  progress = NA,
  unique_table_names = NULL,
  copy_to = NULL
) {
  if (!is.null(unique_table_names)) {
    deprecate_stop(
      "0.1.4",
      "dm::copy_dm_to(unique_table_names = )",
      details = "Use `table_names = set_names(names(dm))` to use unchanged names for temporary tables."
    )
  }

  if (!is.null(copy_to)) {
    deprecate_stop(
      "1.0.0",
      "dm::copy_dm_to(copy_to = )",
      details = "Use `dm_sql()` for more control over the schema creation process."
    )
  }

  check_dots_empty()
  dm_local_error_call()

  check_not_zoomed(dm)

  check_suggested("dbplyr", "copy_dm_to")

  dest <- src_from_src_or_con(dest)

  if (!is_db(dest)) {
    deprecate_stop(
      "0.1.6",
      "dm::copy_dm_to(dest = 'must refer to a DBI connection')",
      "dm::collect.dm()"
    )
  }

  src_names <- src_tbls_impl(dm)
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
    if (!is.null(schema)) {
      abort_one_of_schema_table_names()
    }
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

    names(table_names_out) <- src_names
  }

  # Must be done here because table types may depend on string length, #2066
  dm <- collect(dm, progress = progress)

  if (isTRUE(set_key_constraints)) {
    dm_for_sql <- dm
  } else {
    def_no_keys <- dm_get_def(dm)
    # FIXME: Add test
    def_no_keys$pks[] <- list(new_pk())
    def_no_keys$uks[] <- list(new_uk())
    def_no_keys$fks[] <- list(new_fk())
    # Must keep primary keys
    dm_for_sql <- dm_from_def(def_no_keys)
  }

  sql <- dm_sql(dm_for_sql, dest_con, table_names_out, temporary)

  # FIXME: Extract function
  # FIXME: Make descriptions part of the dm_sql() output

  pre <- unlist(sql$pre)
  load <- unlist(sql$load)
  post <- unlist(sql$post)

  ticker_pre <- new_ticker(
    "creating tables",
    n = length(pre),
    progress = progress,
    top_level_fun = "copy_dm_to"
  )

  # create tables
  walk(
    pre,
    ticker_pre(
      ~ {
        DBI::dbExecute(dest_con, .x, immediate = TRUE)
      }
    )
  )

  ticker_load <- new_ticker(
    "populating tables",
    n = length(load),
    progress = progress,
    top_level_fun = "copy_dm_to"
  )

  # populate tables
  walk(
    load,
    ticker_load(
      ~ {
        DBI::dbExecute(dest_con, .x, immediate = TRUE)
      }
    )
  )

  ticker_post <- new_ticker(
    "creating indexes",
    n = length(post),
    progress = progress,
    top_level_fun = "copy_dm_to"
  )

  # create indexes
  walk(
    post,
    ticker_post(
      ~ {
        DBI::dbExecute(dest_con, .x, immediate = TRUE)
      }
    )
  )

  # remote dm is same as source dm with replaced data
  # FIXME: Extract function
  def <- dm_get_def(dm)

  remote_tables <- map2(
    table_names_out,
    map(def$data, colnames),
    ~ tbl(dest_con, .x, vars = .y)
  )

  def$data <- unname(remote_tables)
  remote_dm <- dm_from_def(def)

  invisible(debug_dm_validate(remote_dm))
}

check_naming <- function(table_names, dm_table_names) {
  if (!identical(sort(table_names), sort(dm_table_names))) {
    abort_copy_dm_to_table_names()
  }
}

db_append_table <- function(
  con,
  remote_table,
  table,
  progress,
  top_level_fun = "copy_dm_to",
  autoinc = logical(0)
) {
  stopifnot(is.data.frame(table))
  if (nrow(table) == 0 || ncol(table) == 0) {
    return(invisible())
  }

  remote_table_name <- DBI::dbQuoteIdentifier(con, remote_table)

  if (is_mssql(con)) {
    # FIXME: Make adaptive
    chunk_size <- 1000L
    n_chunks <- ceiling(nrow(table) / chunk_size)

    remote_table_id <- DBI::dbQuoteIdentifier(con, remote_table)

    ticker <- new_ticker(
      paste0("inserting into ", remote_table_id),
      n = n_chunks,
      progress = progress,
      top_level_fun = top_level_fun
    )

    walk(
      seq_len(n_chunks),
      ticker(
        ~ {
          end <- .x * chunk_size
          idx <- seq2(end - (chunk_size - 1), min(end, nrow(table)))
          values <- map(table[idx, , drop = FALSE], mssql_escape, con = con)
          # Can't use dbAppendTable(): https://github.com/r-dbi/odbc/issues/480
          sql <- DBI::sqlAppendTable(con, remote_table_id, values, row.names = FALSE)
          if (length(autoinc) > 1L) {
            abort("more than one autoincrement key in one table")
          }
          if (!is_empty(autoinc) && autoinc) {
            sql <- DBI::SQL(paste0(
              "SET IDENTITY_INSERT ",
              remote_table_name,
              " ON\n",
              sql,
              "\n",
              "SET IDENTITY_INSERT ",
              remote_table_name,
              " OFF"
            ))
          }
          DBI::dbExecute(con, sql, immediate = TRUE)
        }
      )
    )
  } else if (is_postgres(con) || is_redshift(con)) {
    # https://github.com/r-dbi/RPostgres/issues/384
    table <- as.data.frame(table)
    # https://github.com/r-dbi/RPostgres/issues/382
    DBI::dbAppendTable(con, remote_table, table, copy = FALSE)
  } else {
    DBI::dbAppendTable(con, remote_table, table)
  }

  invisible()
}


# Errors ------------------------------------------------------------------

abort_copy_dm_to_table_names <- function() {
  cli::cli_abort(
    "{.arg table_names} must have names that are the same as the table names in {.arg dm}.",
    class = dm_error_full("copy_dm_to_table_names"),
    call = dm_error_call()
  )
}

abort_copy_dm_to_table_names_duplicated <- function(problem) {
  cli::cli_abort(
    c(
      "{.arg table_names} must be unique.",
      i = "Duplicate: {.code {problem}}"
    ),
    class = dm_error_full("copy_dm_to_table_names_duplicated"),
    call = dm_error_call()
  )
}
