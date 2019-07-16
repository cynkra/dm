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
#' @seealso
#'
#' - [cdm_add_pk()] and [cdm_add_fk()] add primary and foreign keys
#' - [cdm_copy_to()] and [cdm_learn_from_db()] for DB interaction
#' - [cdm_draw()] for visualization
#' - [cdm_join_tbl()] for flattening
#' - [cdm_filter()] for filtering
#' - [cdm_select_tbl()] for creating a `dm` with only a subset of the tables
#' - [decompose_table()] as one example of the table surgery family
#' - [check_key()] and [check_if_subset()] for checking for key properties
#' - [check_cardinality()] for checking the cardinality of the relation between two tables
#' - [cdm_nycflights13()]  for creating an example `dm` object
#'
#' @examples
#' library(dplyr)
#' dm(dplyr::src_df(pkg = "nycflights13"))
#' as_dm(list(iris = iris, mtcars = mtcars))
#'
#' cdm_nycflights13() %>% tbl("airports")
#' cdm_nycflights13() %>% src_tbls()
#' cdm_nycflights13() %>% cdm_get_src()
#' cdm_nycflights13() %>% cdm_get_tables()
#' cdm_nycflights13() %>% cdm_get_data_model()
#'
#' cdm_nycflights13() %>%
#'   cdm_rename_table(airports, ap)
#' cdm_nycflights13() %>%
#'   cdm_rename_tables(c("airports", "flights"), c("ap", "fl"))
#'
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
#' @param tables A list of the tables (tibble-objects, not names) to be included in the `dm` object
#'
#' @rdname dm
#' @export
new_dm <- function(src, tables, data_model) {
  if (!is.src(src) && !is(src, "DBIConnection")) abort_no_src_or_con()
  stopifnot(datamodelr::is.data_model(data_model))
  src <- src_from_src_or_con(src)

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
#' This function is currently a no-op.
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
#'
#' @export
cdm_get_src <- function(x) {
  unclass(x)$src
}

#' Get tables component
#'
#' `cdm_get_tables()` returns a named list with \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#'
#' @rdname dm
#'
#' @export
cdm_get_tables <- function(x) {
  unclass(x)$tables
}

#' Get data_model component
#'
#' `cdm_get_data_model()` returns the \pkg{datamodelr} data model component of a `dm`
#' object.
#'
#' @rdname dm
#'
#' @export
cdm_get_data_model <- function(x) {
  unclass(x)$data_model
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

  db_info <- strsplit(format(cdm_get_src(x)), "\n")[[1]][[1]]

  cat_line(db_info)

  cat_rule("Data model", col = "violet")

  print(cdm_get_data_model(x))

  cat_rule("Rows", col = "orange")

  tbl_names <- src_tbls(x)
  nrows <- map_dbl(cdm_get_tables(x), ~ as_double(pull(count(.))))
  cat_line(paste0("Total: "), sum(nrows))
  cat_line(paste0(names(nrows), ": ", nrows, collapse = ", "))

  invisible(x)
}


#' @export
`$.dm` <- function(x, name) {
  table <- as_string(name)
  tbl(x, table)
}


#' @export
`$<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}


#' @export
`[[.dm` <- function(x, name) {
  table <- as_string(name)
  tbl(x, table)
}


#' @export
`[[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}


#' @export
`[.dm` <- function(x, name) {
  tables <- as_character(name)
  cdm_select_tbl(x, !!!tables)
}


#' @export
`[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}


#' @export
names.dm <- function(x) {
  src_tbls(x)
}


#' @export
`names<-.dm` <- function(x, value) {
  abort_update_not_supported()
}


#' @export
tbl.dm <- function(src, from, ...) {
  # The src argument here is a dm object
  dm <- src
  check_correct_input(dm, from)

  cdm_get_tables(dm)[[from]]
}


#' @export
src_tbls.dm <- function(src, ...) {
  # The src argument here is a dm object
  dm <- src
  names(cdm_get_tables(dm))
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
#' @param dm A `dm` object
#' @param old_name The original name of the table
#' @param new_name The new name of the table
#'
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
