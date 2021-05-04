#' Copy data model to data source
#'
#' `copy_dm_to()` takes a [dplyr::src_dbi] object or a [`DBI::DBIConnection-class`] object as its first argument
#' and a [`dm`] object as its second argument.
#' The latter is copied to the former.
#' The default is to create temporary tables, set `temporary = FALSE` to create permanent tables.
#' Unless `set_key_constraints` is `FALSE`, primary key constraints are set on all databases,
#' and in addition foreign key constraints are set on MSSQL and Postgres databases.
#'
#' No tables will be overwritten; passing `overwrite = TRUE` to the function will give an error.
#' Types are determined separately for each table, setting the `types` argument will
#' also throw an error.
#' The arguments are included in the signature to avoid passing them via the
#' `...` ellipsis.
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
#' @param ... Passed on to [dplyr::copy_to()], which is used on each table.
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
                       schema = NULL) {
  # for the time being, we will be focusing on MSSQL
  # we want to
  #   1. change `dm_get_src(dm)` to `dest`
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
  src_names <- src_tbls(dm)

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

      table_names_out <- unclass(DBI::dbQuoteIdentifier(dest_con, table_names_out[src_names]))
      # names(table_names_out) <- src_names
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

  # FIXME: if same_src(), can use compute() but need to set NOT NULL
  # constraints

  dm <- collect(dm)

  # Shortcut necessary to avoid copying into .GlobalEnv
  if (!is_db(dest)) {
    return(dm)
  }

  copy_data <- build_copy_data(dm, dest, table_names_out, set_key_constraints, dest_con)

  new_tables <- copy_list_of_tables_to(
    dest,
    copy_data = copy_data,
    temporary = temporary,
    overwrite = FALSE,
    ...
  )

  def <- dm_get_def(dm)
  def$data <- new_tables
  remote_dm <- new_dm3(def)

  if (set_key_constraints && is_src_db(remote_dm)) {
    dm_set_key_constraints(remote_dm)
  }

  invisible(debug_validate_dm(remote_dm))
}

#' Set key constraints on a DB for a `dm`-obj with keys
#'
#' @description `dm_set_key_constraints()` takes a `dm` object that is constructed from tables in a database,
#' and mirrors the foreign key constraints in the dm on the database.
#' This is currently only implemented for MSSQL and Postgres databases.
#'
#' @inheritParams copy_dm_to
#'
#' @family DB interaction functions
#'
#' @return Returns the `dm`, invisibly. Side effect: installing key constraints on DB.
#'
#' @examplesIf rlang::is_installed("RSQLite") && rlang::is_installed("nycflights13")
#' # Setting key constraints not yet supported on SQLite,
#' # try this with SQL Server or Postgres instead:
#' sqlite <- DBI::dbConnect(RSQLite::SQLite())
#'
#' flights_dm <- copy_dm_to(
#'   sqlite,
#'   dm_nycflights13(),
#'   set_key_constraints = FALSE
#' )
#'
#' dm_set_key_constraints(flights_dm)
#' DBI::dbDisconnect(sqlite)
#' @noRd
dm_set_key_constraints <- function(dm) {
  if (!is_src_db(dm) && !is_this_a_test()) abort_key_constraints_need_db()
  db_table_names <- get_db_table_names(dm)

  tables_w_pk <- dm_get_all_pks(dm)

  fk_info <-
    dm_get_all_fks(dm) %>%
    left_join(tables_w_pk, by = c("parent_table" = "table")) %>%
    left_join(db_table_names, by = c("child_table" = "table_name")) %>%
    rename(db_child_table = remote_name) %>%
    left_join(db_table_names, by = c("parent_table" = "table_name")) %>%
    rename(db_parent_table = remote_name)

  con <- con_from_src_or_con(dm_get_src(dm))
  queries <- create_queries(con, fk_info)
  walk(queries, ~ dbExecute(con, .))

  invisible(dm)
}

get_db_table_names <- function(dm) {
  if (!is_src_db(dm)) {
    return(tibble(table_name = src_tbls(dm), remote_name = src_tbls(dm)))
  }
  tibble(
    table_name = src_tbls(dm),
    remote_name = map_chr(dm_get_tables_impl(dm), dbplyr::remote_name)
  )
}

check_naming <- function(table_names, dm_table_names) {
  if (!identical(sort(table_names), sort(dm_table_names))) {
    abort_copy_dm_to_table_names()
  }
}


# Errors ------------------------------------------------------------------

abort_copy_dm_to_table_names <- function() {
  abort(error_txt_copy_dm_to_table_names(), .subclass = dm_error_full("copy_dm_to_table_names"))
}

error_txt_copy_dm_to_table_names <- function() {
  "`table_names` must have names that are the same as the table names in `dm`."
}

abort_copy_dm_to_table_names_duplicated <- function(problem) {
  abort(error_txt_copy_dm_to_table_names_duplicated(problem), .subclass = dm_error_full("copy_dm_to_table_names_duplicated"))
}

error_txt_copy_dm_to_table_names_duplicated <- function(problem) {
  c(
    "`table_names` must be unique.",
    i = paste0("Duplicate: ", tick(problem))
  )
}
