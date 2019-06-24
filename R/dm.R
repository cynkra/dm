#' Data model class
#'
#' @description
#' The `dm` class wraps [dplyr::src] and adds a description of table relationships
#' based on [datamodelr::datamodelr-package].
#'
#' `dm()` coerces its inputs.
#'
#' @param src A \pkg{dplyr} table source object.
#' @param data_model A \pkg{datamodelr} data model object, or `NULL`.
#'
#' @export
dm <- function(src, data_model = NULL) h(~ {
    # TODO: add keys argument, if both data_model and keys are missing,
    # create surrogate keys
    if (is.null(data_model)) {
      tbl_names <- src_tbls(src)
      tbls <- map(set_names(tbl_names), tbl, src = src)
      tbl_heads <- map(tbls, head, 0)
      tbl_structures <- map(tbl_heads, collect)

      data_model <- datamodelr::dm_from_data_frames(tbl_structures)
    }

    table_names <- set_names(data_model$tables$table)
    tables <- map(table_names, tbl, src = src)

    new_dm(src, tables, data_model)
  })

#' Low-level constructor
#'
#' `new_dm()` only checks if the inputs are of the correct class.
#' @param tables A list of the tables (tibble-objects, not names) to be included in the `dm`-object
#'
#' @rdname dm
#' @export
new_dm <- function(src, tables, data_model) {
  stopifnot(dplyr::is.src(src) || inherits(src, "DBIConnection"))
  stopifnot(datamodelr::is.data_model(data_model))

  structure(
    list(
      src = src,
      tables = tables,
      data_model = data_model
    ),
    class = "dm"
  )
}

#' Validator
#'
#' `validate_dm()` checks consistency between the \pkg{dplyr} source
#' and the \pkg{datamodelr} based specification of table relationships.
#'
#' @param x An object.
#' @rdname dm
#' @export
validate_dm <- function(x) {
  # TODO: check consistency
  # - tables in data_model must be a subset of tables in src
  # - all tables in src must exist in data model
  # - class membership
  # - DO NOT check primary and foreign key constraints here by default,
  #   perhaps optionally or in a different verb
  #
  #
  invisible(x)
}

#' Get source component
#'
#' `cdm_get_src()` returns the \pkg{dplyr} source component of a `dm`
#' object.
#'
#' @rdname dm
#' @export
cdm_get_src <- function(x) {
  x$src
}

#' Get tables component
#'
#' `cdm_get_tables()` returns a named list with \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#'
#' @rdname dm
#' @export
cdm_get_tables <- function(x) {
  x$tables
}

#' Get data_model component
#'
#' `cdm_get_data_model()` returns the \pkg{datamodelr} data model component of a `dm`
#' object.
#'
#' @rdname dm
#' @export
cdm_get_data_model <- function(x) {
  x$data_model
}

#' Check class
#'
#' `is_dm()` returns `TRUE` if the input is of class `dm`.
#'
#' @rdname dm
#' @export
is_dm <- function(x) {
  inherits(x, "dm")
}


#' Coerce
#'
#' `as_dm()` coerces objects to the `dm` class
#'
#' @rdname dm
#' @export
as_dm <- function(x) {
  UseMethod("as_dm")
}

#' @export
as_dm.default <- function(x) {
  if (!is.list(x) || is.object(x)) {
    abort(paste0("Can't coerce <", class(x)[[1]], "> to <dm>."))
  }

  xl <- map(x, list)
  names(xl)[names2(xl) == ""] <- ""

  # Automatic name repair
  names(x) <- names(as_tibble(xl, .name_repair = ~ make.names(., unique = TRUE)))

  src <- src_df(env = new_environment(x))
  dm(src = src)
}

#' @export
as_dm.src <- function(x) {
  dm(src = x, data_model = NULL)
}

#' @export
format.dm <- function(x, ...) {
  abort("NYI")
}

#' @export
#' @import cli
print.dm <- function(x, ...) {
  cat_rule("Table source", col = "green")

  if (is.src(cdm_get_src(x))) {
    db_info <- strsplit(format(cdm_get_src(x)), "\n")[[1]][[1]]
  } else if (inherits(cdm_get_src(x), "DBIConnection")) {
    db_complete_info <- dbGetInfo(cdm_get_src(x))
    db_info <- paste0(
      if_else(is_empty(db_complete_info$dbms.name),
        paste0("DB-name: ", db_complete_info$dbname),
        paste0("DBMS-name: ", db_complete_info$dbms.name)
      ),
      if_else(is_empty(db_complete_info$servername),
        paste0(", Server version: ", db_complete_info$serverVersion),
        paste0(", Server name: ", db_complete_info$servername)
      )
    )
  }

  cat_line(db_info)

  cat_rule("Data model", col = "violet")

  print(cdm_get_data_model(x))

  cat_rule("Rows", col = "orange")

  tbl_names <- src_tbls(x)
  nrows <- map(tbl_names, ~ cdm_nrow(x, !!.)) %>% flatten_int()
  cat_line(paste0("Total: "), sum(nrows))
  cat_line(paste0(names(nrows), ": ", nrows, collapse = ", "))

  invisible(x)
}

#' @export
tbl.dm <- function(src, from, ...) {
  # The src argument here is a dm object
  dm <- src
  dm$tables[[from]]
}

#' @export
src_tbls.dm <- function(src, ...) {
  # The src argument here is a dm object
  dm <- src
  names(dm$tables)
}

#' @export
copy_to.dm <- function(dest, df, name = deparse(substitute(df))) {
  # TODO: How to add a table to a dm?
  abort("`dm` objects are immutable, please use ...")
}

#' Rename tables of a `dm`
#'
#' @description `cdm_rename_table()` changes the name of one of a `dm`'s tables.
#'
#' @param dm A `dm`-object
#' @param old_name The original name of the table
#' @param new_name The new name of the table
#'
#' @export
cdm_rename_table <- function(dm, old_name, new_name) {
  old_name_q <- as_name(enexpr(old_name))
  check_correct_input(dm, old_name_q)

  new_name_q <- as_name(enexpr(new_name))
  tables <- cdm_get_tables(dm)
  table_names <- names(tables)
  table_names[table_names == old_name_q] <- new_name_q
  new_tables <- set_names(tables, table_names)

  new_dm(
    src = cdm_get_src(dm),
    tables = new_tables,
    data_model = datamodel_rename_table(
      cdm_get_data_model(dm), old_name_q, new_name_q
    )
  )
}

#' @description `cdm_rename_tables()` changes the names one or more tables of a `dm`.
#'
#' @rdname cdm_rename_table
#'
#' @inheritParams cdm_rename_table
#' @param old_table_names Character vector or list of the original names of the tables which are to change
#' @param new_table_names Character vector or list of the new names of the tables
#'
#' @export
cdm_rename_tables <- function(dm, old_table_names, new_table_names) {
  if (length(old_table_names) != length(new_table_names)) {
    abort("Length of 'new_table_names' does not match that of 'old_table_names'")
  }
  # abort_rename_table_fail(old_names, new_names)
  reduce2(
    old_table_names,
    new_table_names,
    cdm_rename_table,
    .init = dm
  )
}
