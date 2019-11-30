#' Data model class
#'
#' @description
#' The `dm` class holds a list of tables and their relationships.
#' It is inspired by [datamodelr](https://github.com/bergant/datamodelr),
#' and extends the idea by offering operations to access the data in the tables.
#'
#' `dm()` creates a `dm` object from one or multiple [tbl] objects
#' (tibbles or lazy data objects).
#'
#' @param ... Tables to add to the `dm` object.
#'   If no names are provided, the tables
#'   are auto-named.
#' @param .name_repair Options for name repair.
#'   Forwarded as `repair` to [vctrs::vec_as_names()].
#' @param src A \pkg{dplyr} table source object.
#' @param table_names A character vector of the names of the tables to include.
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
#' dm(iris, mtcars)
#' dm_from_src(dplyr::src_df(pkg = "nycflights13"))
#' new_dm(list(iris = iris, mtcars = mtcars))
#' as_dm(list(iris = iris, mtcars = mtcars))
#'
#' cdm_nycflights13() %>% tbl("airports")
#' cdm_nycflights13() %>% src_tbls()
#' cdm_nycflights13() %>% cdm_get_src()
#' cdm_nycflights13() %>% cdm_get_tables()
#'
#' cdm_nycflights13() %>%
#'   cdm_rename_tbl(ap = airports)
#' cdm_nycflights13() %>%
#'   cdm_rename_tbl(ap = airports, fl = flights)
#' @export
dm <- function(..., .name_repair = c("check_unique", "unique", "universal", "minimal")) {
  quos <- enquos(...)

  tbls <- map(quos, eval_tidy)

  if (has_length(quos)) {
    src_index <- c(which(names(quos) == "src"), 1)[[1]]
    if (is.src(tbls[[src_index]])) {
      lifecycle::deprecate_soft("0.0.4.9001", "dm::dm(src = )", "dm_from_src()")
      return(invoke(dm_from_src, tbls))
    }
  }

  names(tbls) <- vctrs::vec_as_names(names(quos_auto_name(quos)), repair = .name_repair)
  dm <- new_dm(tbls)
  validate_dm(dm)
  dm
}

#' dm_from_src()
#'
#' `dm_from_src()` creates a `dm` from some or all tables in a [src]
#' (a database or an environment).
#'
#' @rdname dm
#' @export
dm_from_src <- nse_function(c(src, table_names = NULL), ~ {
  if (is_missing(src)) return(empty_dm())
  src_tbl_names <- src_tbls(src)

  if (is_null(table_names)) {
    table_names <- src_tbl_names
  } else if (!all(table_names %in% src_tbl_names)) {
    abort_req_tbl_not_avail(src_tbl_names, setdiff(table_names, src_tbl_names))
  }

  tbls <- map(set_names(table_names), tbl, src = src)

  new_dm(tbls)
})

#' A low-level constructor
#'
#' @description
#' `new_dm()` is a low-level constructor that creates a new `dm` object.
#'
#' If called without arguments, it will create an empty `dm`.
#'
#' If called with arguments, no validation checks will be made to ascertain that
#' the inputs are of the expected class and internally consistent;
#' use `validate_dm()` to double-check the returned object.
#'
#' @param tables A named list of the tables (tibble-objects, not names) .
#'   to be included in the `dm` object.
#'
#' @rdname dm
#' @export
new_dm <- function(tables = list()) {
  # Legacy
  data <- unname(tables)
  table <- names2(tables)
  zoom <- new_zoom()
  key_tracker_zoom <- new_key_tracker_zoom()

  pks <-
    tibble(
      table = table,
      pks = vctrs::list_of(new_pk())
    )

  fks <-
    tibble(
      table = table,
      fks = vctrs::list_of(new_fk())
    )

  filters <-
    tibble(
      table = table,
      filters = vctrs::list_of(new_filter())
    )

  def <-
    tibble(table, data, segment = NA_character_, display = NA_character_) %>%
    left_join(pks, by = "table") %>%
    left_join(fks, by = "table") %>%
    left_join(filters, by = "table") %>%
    left_join(zoom, by = "table") %>%
    left_join(key_tracker_zoom, by = "table")

  new_dm3(def)
}

new_dm3 <- function(def, zoomed = FALSE) {
  class <- c(
    if (zoomed) "zoomed_dm",
    "dm"
  )
  structure(list(def = def), class = class)
}

new_pk <- function(column = list()) {
  stopifnot(is.list(column))
  tibble(column = column)
}

new_fk <- function(table = character(), column = list()) {
  stopifnot(is.list(column))
  tibble(table = table, column = column)
}

new_filter <- function(quos = list(), zoomed = logical()) {
  tibble(filter_expr = unclass(quos), zoomed = zoomed)
}

# Legacy!
new_filters <- function() {
  tibble(table = character(), filter = list())
}

new_zoom <- function() {
  tibble(table = character(), zoom = list())
}

new_key_tracker_zoom <- function() {
  tibble(table = character(), key_tracker_zoom = list())
}

#' Validator
#'
#' `validate_dm()` checks the internal consistency of a `dm` object.
#'
#' @param x An object.
#' @rdname dm
#' @export
validate_dm <- function(x) {
  check_dm(x)

  if (!identical(names(unclass(x)), "def")) abort_dm_invalid("A `dm` needs to be a list of one item named `def`.")
  def <- cdm_get_def(x)

  table_names <- def$table
  if (any(table_names == "")) abort_dm_invalid("Not all tables are named.")
  check_col_classes(def)

  if (!all(map_lgl(def$data, ~ {inherits(., "data.frame") || inherits(., "tbl_dbi")}))) abort_dm_invalid(
    "Not all entries in `def$data` are of class `data.frame` or `tbl_dbi`. Check `cdm_get_tables()`.")
  if (!all_same_source(def$data)) abort_dm_invalid(error_not_same_src())

  if (nrow(def) == 0) return(invisible(x))
  if (ncol(def) != 9) abort_dm_invalid(
    glue("Number of columns of tibble defining `dm` is wrong: {as.character(ncol(def))} ",
         "instead of 9.")
    )

  fks <- def$fks %>%
    map_dfr(I) %>%
    unnest(column)
  check_fk_child_tables(fks$table, table_names)
  dm_col_names <- set_names(map(def$data, colnames), table_names)
  check_colnames(fks, dm_col_names, "FK")
  pks <- select(def, table, pks) %>%
    unnest(pks) %>%
    unnest(column)
  check_colnames(pks, dm_col_names, "PK")
  check_one_zoom(def, is_zoomed(x))
  if (!all(map_lgl(def$zoom, ~ {inherits(., "data.frame") || inherits(., "tbl_dbi") || inherits(., "NULL")}))) abort_dm_invalid(
    "Not all entries in `def$zoom` are of class `data.frame`, `tbl_dbi` or `NULL`.")
  invisible(x)
}

#' Get source
#'
#' `cdm_get_src()` returns the \pkg{dplyr} source for a `dm` object.
#' All tables in a `dm` object must be from the same source,
#' i.e. either they are all data frames, or they all are stored on the same
#' database.
#'
#' @rdname dm
#'
#' @export
cdm_get_src <- function(x) {
  check_dm(x)
  tables <- cdm_get_tables(x)
  tbl_src(tables[1][[1]])
}

#' Get connection
#'
#' `cdm_get_con()` returns the [`DBI::DBIConnection-class`] for `dm` objects.
#' This works only if the tables are stored on a database, otherwise an error
#' is thrown.
#'
#' @rdname dm
#'
#' @export
cdm_get_con <- function(x) {
  src <- cdm_get_src(x)
  if (!inherits(src, "src_dbi")) abort_con_only_for_dbi()
  src$con
}

#' Get tables
#'
#' `cdm_get_tables()` returns a named list of \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#' Filtering expressions are NOT evaluated at this stage.
#' To get filtered tables, use `tbl.dm()`
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

#' Get filter expressions
#'
#' `cdm_get_filter()` returns the filter expressions that have been applied to a `dm` object.
#' These filter expressions are not intended for evaluation, only for
#' information.
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
  if (!("filter_expr" %in% names(filter_df))) {
    filter_df$filter_expr <- list()
  }

  filter_df  %>%
    rename(filter = filter_expr)
}

cdm_get_zoomed_tbl <- function(x) {
  cdm_get_def(x) %>%
    filter(!map_lgl(zoom, is_null)) %>%
    select(table, zoom)
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
  dm <- new_dm(x)
  validate_dm(dm)
  dm
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
  dm_from_src(src = x, table_names = NULL)
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

  cat_rule("Metadata", col = "violet")

  def <- cdm_get_def(x)
  cat_line("Tables: ", commas(tick(def$table)))
  cat_line("Columns: ", sum(map_int(map(def$data, colnames), length)))
  cat_line("Primary keys: ", sum(map_int(def$pks, vctrs::vec_size)))
  cat_line("Foreign keys: ", sum(map_int(def$fks, vctrs::vec_size)))

  filters <- cdm_get_filter(x)
  if (nrow(filters) > 0) {
    cat_rule("Filters", col = "orange")
    walk2(filters$table, filters$filter, ~ cat_line(paste0(.x, ": ", as_label(.y))))
  }

  invisible(x)
}

#' @export
print.zoomed_dm <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  format(x, ..., n = NULL, width = NULL, n_extra = NULL)
}

#' @export
format.zoomed_dm <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  df <- get_zoomed_tbl(x)
  zoomed_filters <- cdm_get_filter(x) %>%
    filter(zoomed == TRUE)
  filters <- if_else(nrow(zoomed_filters) > 0, TRUE, FALSE)
  # so far only 1 table can be zoomed on
  zoomed_df <- new_zoomed_df(
    df,
    name_df = orig_name_zoomed(x),
    filters = filters
  )
  cat_line(format(zoomed_df, ..., n = n, width = width, n_extra = n_extra))
  invisible(x)
}

new_zoomed_df <- function(x, ...) {
  if (!is.data.frame(x)) return(structure(x, class = c("zoomed_df", class(x)), ...))
  # need this in order to avoid star (from rownames, automatic from `structure(...)`)
  # in print method for local tibbles
  new_tibble(
    x,
    # need setdiff(...), because we want to keep everything "special" (like groups etc.) but drop
    # all classes, that a `tbl` has anyway
    # FIXME: Remove setdiff() when tibble >= 3.0.0 is on CRAN
    class = c("zoomed_df", setdiff(class(x), c("tbl_df", "tbl", "data.frame"))),
    nrow = nrow(x),
    ...)
}

# this is called from `tibble:::trunc_mat()`, which is called from `tibble::format.tbl()`
# therefore, we need to have our own subclass but the main class needs to be `tbl`
#' @export
tbl_sum.zoomed_df <- function(x) {
  c(structure(attr(x, "name_df"), names = "Zoomed table"),
    NextMethod())
}

#' @export
format.zoomed_df <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  NextMethod()
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
  object <- cdm_get_def(object) %>%
    select(table, pks, fks, filters)
  str(object)
}

#' @export
str.zoomed_dm <- function(object, ...) {
  object <- cdm_get_def(object) %>%
    mutate(zoom = if_else(map_lgl(zoom, is_null), NA_character_, table)) %>%
    select(zoom, table, pks, fks, filters)
  str(object)
}

#' @export
tbl.dm <- function(src, from, ...) {
  # The src argument here is a dm object
  dm <- src
  check_not_zoomed(dm)
  check_correct_input(dm, from, 1L)

  cdm_get_filtered_table(dm, from)
}

#' @export
compute.dm <- function(x, ...) {
  cdm_apply_filters(x) %>%
    cdm_get_def() %>%
    mutate(data = map(data, compute, ...)) %>%
    new_dm3()
}

#' @export
compute.zoomed_dm <- function(x, ...) {
  zoomed_df <- get_zoomed_tbl(x) %>%
    compute(zoomed_df, ...)
  replace_zoomed_tbl(x, zoomed_df)
}


#' @export
src_tbls.dm <- function(x) {
  # The x argument here is a dm object
  dm <- x
  names(cdm_get_tables(dm))
}

#' @export
copy_to.dm <- function(dest, df, name = deparse(substitute(df)), overwrite = FALSE, temporary = TRUE, repair = "unique", quiet = FALSE, ...) {
  if (!(inherits(df, "data.frame") || inherits(df, "tbl_dbi"))) abort_only_data_frames_supported()
  if (overwrite) abort_no_overwrite()
  if (length(name) != 1) abort_one_name_for_copy_to(name)
  # src: if `df` on a different src:
  # if `df_list` is on DB and `dest` is local, collect `df_list`
  # if `df_list` is local and `dest` is on DB, copy `df_list` to respective DB
  df <- copy_to(cdm_get_src(dest), df, unique_db_table_name(name), temporary = temporary, ...)
  # FIXME: should we allow `overwrite` argument?
  names_list <- repair_table_names(src_tbls(dest), name, repair, quiet)
  # rename old tables with potentially new names
  dest <- cdm_rename_tbl(dest, !!!names_list$new_old_names)
  # `repair` argument is `unique` by default
  cdm_add_tbl_impl(dest, list(df), names_list$new_names)
}

#' @export
collect.dm <- function(x, ...) {
  x <-
    x %>%
    cdm_apply_filters()

  def <- cdm_get_def(x)
  def$data <- map(def$data, collect, ...)
  new_dm3(def)
}

# FIXME: what about 'dim.dm()'?
#' @export
dim.zoomed_dm <- function(x) {
  dim(get_zoomed_tbl(x))
}

#' @export
dimnames.zoomed_dm <- function(x) {
  dimnames(get_zoomed_tbl(x))
}

cdm_reset_all_filters <- function(dm) {
  def <- cdm_get_def(dm)
  def$filters <- vctrs::list_of(new_filter())
  new_dm3(def)
}

all_same_source <- function(tables) {
  # Use `NULL` if `tables` is empty
  first_table <- tables[1][[1]]
  is.null(detect(tables[-1], ~ !same_src(., first_table)))
}

# creates an empty `dm`-object, `src` is defined by implementation of `cdm_get_src()`.
empty_dm <- function() {
  new_dm3(
    tibble(
      table = character(),
      data = list(),
      segment = character(),
      display = character(),
      pks =vctrs::list_of(new_pk()),
      fks = vctrs::list_of(new_fk()),
      filters = vctrs::list_of(new_filter()),
      zoom = list(),
      key_tracker_zoom = list()
    )
  )
}
