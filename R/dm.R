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
#' - [cdm_join_to_tbl()] for flattening
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
  if (is.null(data_model)) {
    tbl_names <- src_tbls(src)
    tbls <- map(set_names(tbl_names), tbl, src = src)
    tbl_heads <- map(tbls, head, 0)
    tbl_structures <- map(tbl_heads, collect)

    data_model <- datamodelr::dm_from_data_frames(tbl_structures)
  }

  table_names <- set_names(data_model$tables$table)
  tables <- map(table_names, tbl, src = src)

  new_dm(tables, data_model)
})

#' Low-level constructor
#'
#' `new_dm()` only checks if the inputs are of the correct class.
#' @param tables A list of the tables (tibble-objects, not names) to be included in the `dm` object
#'
#' @rdname dm
#' @export
new_dm <- function(tables, data_model) {
  if (!all_same_source(tables)) abort_not_same_src()
  stopifnot(datamodelr::is.data_model(data_model))

  columns <- as_tibble(data_model$columns)

  data_model_tables <- data_model$tables

  stopifnot(all(names(tables) %in% data_model_tables$table))
  stopifnot(all(data_model_tables$table %in% names(tables)))

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

  new_dm2(
    tables[data_model_tables$table],
    data_model_tables$table,
    data_model_tables$segment,
    data_model_tables$display,
    keys,
    references,
    filter = new_filters()
  )
}

new_dm2 <- function(data = cdm_get_def(base_dm)$data,
                    table = cdm_get_def(base_dm)$table,
                    segment = cdm_get_def(base_dm)$segment,
                    display = cdm_get_def(base_dm)$display,
                    pks = cdm_get_data_model_pks(base_dm),
                    fks = cdm_get_data_model_fks(base_dm),
                    filter = cdm_get_filter(base_dm),
                    base_dm) {
  stopifnot(!is.null(table))
  stopifnot(!is.null(pks))
  stopifnot(!is.null(fks))

  filters <-
    filter %>%
    rename(filter_quo = filter) %>%
    nest(filters = filter_quo)

  # Legacy
  data <- unname(data)

  # Legacy compatibility
  pks$column <- as.list(pks$column)

  pks <-
    pks %>%
    nest(pks = -table)

  pks <-
    tibble(
      table = setdiff(table, pks$table),
      pks = vctrs::list_of(tibble(column = list()))
    ) %>%
    vctrs::vec_rbind(pks)

  # Legacy compatibility
  fks$column <- as.list(fks$column)

  fks <-
    fks %>%
    select(-ref_col) %>%
    nest(fks = -ref) %>%
    rename(table = ref)

  fks <-
    tibble(
      table = setdiff(table, fks$table),
      fks = vctrs::list_of(tibble(table = character(), column = list()))
    ) %>%
    vctrs::vec_rbind(fks)

  def <-
    tibble(table, data, segment, display) %>%
    left_join(pks, by = "table") %>%
    left_join(fks, by = "table") %>%
    left_join(filters, by = "table")

  new_dm3(def)
}

new_dm3 <- function(def) {
  structure(
    list(def = def),
    class = "dm"
  )
}

new_filters <- function() {
  tibble(table = character(), filter = list())
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
  tables <- cdm_get_tables(x)
  tbl_src(tables[1][[1]])
}

#' Get tables component
#'
#' `cdm_get_tables()` returns a named list with \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#' The filter expressions are NOT evaluated at this stage.
#' To get the filtered tables, use `tbl.dm()`
#'
#' @rdname dm
#'
#' @export
cdm_get_tables <- function(x) {
  def <- cdm_get_def(x)
  set_names(def$data, def$table)
}

cdm_get_def <- function(x) {
  unclass(x)$def
}

cdm_get_data_model_pks <- function(x) {
  # FIXME: Obliterate

  pk_df <-
    cdm_get_def(x) %>%
    select(table, pks) %>%
    unnest(pks)

  # FIXME: Should work better with dplyr 0.9.0
  if (!("column" %in% names(pk_df))) {
    pk_df$column <- character()
  } else {
    # This is expected to break with compound keys
    pk_df$column <- flatten_chr(pk_df$column)
  }

  pk_df
}

cdm_get_data_model_fks <- function(x) {
  # FIXME: Obliterate

  fk_df <-
    cdm_get_def(x) %>%
    select(ref = table, fks, pks) %>%
    filter(map_lgl(fks, has_length)) %>%
    unnest(pks)

  if (nrow(fk_df) == 0) {
    return(tibble(
      table = character(), column = character(),
      ref = character(), ref_col = character()
    ))
  }

  fk_df %>%
    # This is expected to break with compound keys
    mutate(ref_col = flatten_chr(column)) %>%
    select(-column) %>%
    unnest(fks) %>%
    mutate(column = flatten_chr(column)) %>%
    select(ref, column, table, ref_col)
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
  def <- cdm_get_def(x)

  tables <- data.frame(
    table = def$table,
    segment = def$segment,
    display = def$display,
    stringsAsFactors = FALSE
  )

  references_for_columns <- cdm_get_data_model_fks(x)

  references <-
    references_for_columns %>%
    mutate(ref_id = row_number(), ref_col_num = 1L)

  keys <-
    cdm_get_data_model_pks(x) %>%
    mutate(key = 1L)

  columns <-
    cdm_get_all_columns(x) %>%
    # Hack: datamodelr requires `type` column
    mutate(type = "integer") %>%
    left_join(keys, by = c("table", "column")) %>%
    mutate(key = coalesce(key, 0L)) %>%
    left_join(references_for_columns, by = c("table", "column")) %>%
    # for compatibility with print method from {datamodelr}
    as.data.frame()

  new_data_model(
    tables,
    columns,
    references
  )
}

cdm_get_all_columns <- function(x) {
  cdm_get_tables(x) %>%
    map(colnames) %>%
    map(~ enframe(., "id", "column")) %>%
    enframe("table") %>%
    unnest(value)
}

#' Get filter expressions
#'
#' `cdm_get_filter()` returns the filter component of a `dm`
#' object, the set filter expressions.
#'
#' @rdname dm
#'
#' @export
cdm_get_filter <- function(x) {
  # FIXME: Obliterate

  filter_df <-
    cdm_get_def(x) %>%
    select(table, filters) %>%
    unnest(filters)

  # FIXME: Should work better with dplyr 0.9.0
  if (!("filter_quo" %in% names(filter_df))) {
    filter_df$filter_quo <- list()
  }

  filter_df  %>%
    rename(filter = filter_quo)
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

  # Check if all sources are identical
  if (!all_same_source(x)) abort_not_same_src()

  # Empty tibbles as proxy, we don't need to know the columns
  # and we don't have keys yet
  proxies <- map(x, ~ tibble(a = 0))
  data_model <- datamodelr::dm_from_data_frames(proxies)

  new_dm(x, data_model)
}

tbl_src <- function(x) {
  if (is_empty(x) || is.data.frame(x)) {
    default_local_src()
  } else if (inherits(x, "tbl_sql")) {
    x$src
  } else {
    abort_what_a_weird_object(class(x)[[1]])
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
  src <- cdm_get_src(x)

  db_info <- strsplit(format(src), "\n")[[1]][[1]]

  cat_line(db_info)

  cat_rule("Data model", col = "violet")

  print(cdm_get_data_model(x))

  cat_rule("Filters", col = "orange")

  filters <- cdm_get_filter(x)

  if (nrow(filters) > 0) {
    names <- pull(filters, table)
    filter_exprs <- pull(filters, filter) %>%
      as.character() %>%
      str_replace("^~", "")

    walk2(names, filter_exprs, ~ cat_line(paste0(.x, ": ", .y)))
  } else {
    cat_line("None")
  }

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
`[[.dm` <- function(x, id) {
  if (is.numeric(id)) id <- src_tbls(x)[id] else id <- as_string(id)
  tbl(x, id)
}


#' @export
`[[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}


#' @export
`[.dm` <- function(x, id) {
  if (is.numeric(id)) id <- src_tbls(x)[id]
  id <- as.character(id)
  cdm_select_tbl(x, !!!id)
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
length.dm <- function(x) {
  length(src_tbls(x))
}

#' @export
`length<-.dm` <- function(x, value) {
  abort_update_not_supported()
}

#' @export
str.dm <- function(object, ...) {
  object <- unclass(object)
  NextMethod()
}


#' @export
tbl.dm <- function(src, from, ...) {
  # The src argument here is a dm object
  dm <- src
  check_correct_input(dm, from)

  cdm_get_filtered_table(dm, from)
}

#' @export
compute.dm <- function(x) {
  cdm_apply_filters(x)
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
  list_of_rem_tbls <- cdm_apply_filters(x) %>% cdm_get_tables()
  tables <- map(list_of_rem_tbls, collect)

  new_dm(
    tables,
    cdm_get_data_model(x)
  )
}


cdm_reset_all_filters <- function(dm) {
  new_dm2(
    filter = tibble(table = character(0), filter = list(0)),
    base_dm = dm
  )
}

all_same_source <- function(tables) {
  # Use `NULL` if `tables` is empty
  first_table <- tables[1][[1]]
  is.null(detect(tables[-1], ~ !same_src(., first_table)))
}
