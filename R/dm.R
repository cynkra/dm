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
dm <- function(src, data_model = NULL) {
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
}

#' Low-level constructor
#'
#' `new_dm()` only checks if the inputs are of the correct class.
#'
#' @rdname dm
#' @export
new_dm <- function(src, tables, data_model) {
  stopifnot(dplyr::is.src(src))
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

  db_info <- strsplit(format(x$src), "\n")[[1]][[1]]
  cat_line(db_info)

  cat_rule("Data model", col = "violet")

  print(x$data_model)
  invisible(x)
}

#' @export
tbl.dm <- function(src, from, ...) {
  src$tables[[from]]
}

#' @export
src_tbls.dm <- function(src, ...) {
  names(src$tables)
}

#' @export
copy_to.dm <- function(dest, df, name = deparse(substitute(df))) {
  # TODO: How to add a table to a dm?
  abort("`dm` objects are immutable, please use ...")
}
