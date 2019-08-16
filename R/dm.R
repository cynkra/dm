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
#'   cdm_rename_tbl(ap = airports)
#' cdm_nycflights13() %>%
#'   cdm_rename_tbl(ap = airports, fl = flights)
#' @export
dm <- nse_function(c(src, data_model = NULL), ~ {
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

  columns <- as_tibble(data_model$columns)

  data_model_tables <- data_model$tables

  keys <- columns %>%
    select(column, table, key) %>%
    filter(key > 0) %>%
    select(-key)

  if (is.null(data_model$references)) {
    references <- tibble(
      table = character(),
      column = character(),
      ref = character(),
      ref_col = character()
    )
  } else {
    references <-
      data_model$references %>%
      select(table, column, ref, ref_col) %>%
      as_tibble()
  }

  new_dm2(src, tables, data_model_tables, keys, references)
}

new_dm2 <- function(src = cdm_get_src(base_dm),
                    tables = cdm_get_tables(base_dm),
                    data_model_tables = cdm_get_data_model_tables(base_dm),
                    pks = cdm_get_data_model_pks(base_dm),
                    fks = cdm_get_data_model_fks(base_dm),
                    base_dm) {

  stopifnot(!is.null(src))
  stopifnot(!is.null(tables))
  stopifnot(!is.null(data_model_tables))
  stopifnot(!is.null(pks))
  stopifnot(!is.null(fks))

  structure(
    list(
      src = src,
      tables = tables,
      data_model_tables = data_model_tables,
      data_model_pks = pks,
      data_model_fks = fks
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

cdm_get_data_model_tables <- function(x) {
  unclass(x)$data_model_tables
}

cdm_get_data_model_pks <- function(x) {
  unclass(x)$data_model_pks
}

cdm_get_data_model_fks <- function(x) {
  unclass(x)$data_model_fks
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
  references_for_columns <- cdm_get_data_model_fks(x)

  references <-
    references_for_columns %>%
    mutate(ref_id = row_number(), ref_col_num = 1L)

  keys <-
    cdm_get_data_model_pks(x) %>%
    mutate(key = 1L)

  columns <-
    cdm_get_tables(x) %>%
    map(colnames) %>%
    map(~ enframe(., "id", "column")) %>%
    enframe("table") %>%
    unnest() %>%
    mutate(type = "integer") %>%
    left_join(keys, by = c("table", "column")) %>%
    mutate(key = coalesce(key, 0L)) %>%
    left_join(references_for_columns, by = c("table", "column")) %>%
    # for compatibility with print method from {datamodelr}
    as.data.frame()

  new_data_model(
    cdm_get_data_model_tables(x),
    columns,
    references
  )
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

  # Automatic name repair
  names(x) <- vctrs::vec_as_names(names2(x), repair = "unique")

  src <- tbl_src(x[[1]])

  # FIXME: Check if all sources identical

  # Empty tibbles as proxy, we don't need to know the columns
  # and we don't have keys yet
  proxies <- map(x, ~ tibble(a = 0))
  data_model <- datamodelr::dm_from_data_frames(proxies)

  new_dm(src, x, data_model)
}

tbl_src <- function(x) {
  if (is.data.frame(x)) {
    src_df(env = new_environment(x))
  } else if (inherits(x, "tbl_sql"))  {
    x$src
  } else {
    # FIXME: Classed error code
    stop(
      "Don't know how to determine table source for object of class ",
      class(x)[[1]]
    )
  }
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
  if (is.numeric(name)) abort_no_numeric_subsetting()
  table <- as_string(name)
  tbl(x, table)
}


#' @export
`[[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}


#' @export
`[.dm` <- function(x, name) {
  if (is.numeric(name)) abort_no_numeric_subsetting()
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

#' @export
collect.dm <- function(x, ...) {
  if (!is_src_db(x)) return(x)

  tables <- map(cdm_get_tables(x), collect)

  new_dm(
    cdm_get_src(x),
    tables,
    cdm_get_data_model(x)
  )
}


rename_table_of_dm <- function(dm, old_name, new_name) {
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

#' Change names of tables in a `dm`
#'
#' @description `cdm_rename_tbl()` changes the names of one or more tables of a `dm`.
#'
#' @param dm A `dm` object
#' @param ... Named character vector (new_name = old_name)
#'
#' @export
cdm_rename_tbl <- function(dm, ...) {

  table_list <- tidyselect_dm(dm, ...)

  old_table_names <- table_list[[2]]
  new_table_names <- names(old_table_names)

  reduce2(
    old_table_names,
    new_table_names,
    rename_table_of_dm,
    .init = dm
  )
}
