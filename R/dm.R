#' Data model class
#'
#' @description
#' The `dm` class holds a list of tables and their relationships.
#' It is inspired by [datamodelr](https://github.com/bergant/datamodelr),
#' and extends the idea by offering operations to access the data in the tables.
#'
#' `dm()` creates a `dm` object from [tbl] objects
#' (tibbles or lazy data objects).
#'
#' @param ... Tables to add to the `dm` object.
#'   If no names are provided, the tables
#'   are auto-named.
#' @param .name_repair Options for name repair.
#'   Forwarded as `repair` to [vctrs::vec_as_names()].
#'
#' @return For `dm()`, `new_dm()`, `as_dm()`: A `dm` object.
#'
#' @seealso
#'
#' - [dm_from_src()] for connecting to all tables in a database
#'   and importing the primary and foreign keys
#' - [dm_add_pk()] and [dm_add_fk()] for adding primary and foreign keys
#' - [copy_dm_to()] for DB interaction
#' - [dm_draw()] for visualization
#' - [dm_join_to_tbl()] for flattening
#' - [dm_filter()] for filtering
#' - [dm_select_tbl()] for creating a `dm` with only a subset of the tables
#' - [dm_nycflights13()]  for creating an example `dm` object
#' - [decompose_table()] for table surgery
#' - [check_key()] and [check_subset()] for checking for key properties
#' - [examine_cardinality()] for checking the cardinality of the relation between two tables
#'
#' @export
#' @examples
#' dm(trees, mtcars)
#' new_dm(list(trees = trees, mtcars = mtcars))
#' as_dm(list(trees = trees, mtcars = mtcars))
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")
#'
#' dm_nycflights13() %>% tbl("airports")
#' dm_nycflights13() %>% src_tbls()
#' dm_nycflights13() %>% dm_get_src()
#'
#' copy_dm_to(
#'   dbplyr::src_memdb(),
#'   dm_nycflights13(),
#'   unique_table_names = TRUE
#' ) %>%
#'   dm_get_con()
#'
#' dm_nycflights13() %>% dm_get_tables()
#' dm_nycflights13() %>% dm_get_filters()
#' dm_nycflights13() %>% validate_dm()
#' is_dm(dm_nycflights13())
#' dm_nycflights13()["airports"]
#' dm_nycflights13()[["airports"]]
#' dm_nycflights13()$airports
dm <- function(..., .name_repair = c("check_unique", "unique", "universal", "minimal")) {
  quos <- enquos(...)

  tbls <- map(quos, eval_tidy)

  if (has_length(quos)) {
    src_index <- c(which(names(quos) == "src"), 1)[[1]]
    if (is.src(tbls[[src_index]])) {
      deprecate_soft("0.0.4.9001", "dm::dm(src = )", "dm_from_src()")
      return(invoke(dm_from_src, tbls))
    }
  }

  names(tbls) <- vctrs::vec_as_names(names(quos_auto_name(quos)), repair = .name_repair)
  dm <- new_dm(tbls)
  validate_dm(dm)
  dm
}

#' A low-level constructor
#'
#' @description
#' `new_dm()` is a low-level constructor that creates a new `dm` object.
#'
#' - If called without arguments, it will create an empty `dm`.
#'
#' - If called with arguments, no validation checks will be made to ascertain that
#'   the inputs are of the expected class and internally consistent;
#'   use `validate_dm()` to double-check the returned object.
#'
#' @param tables A named list of the tables (tibble-objects, not names),
#'   to be included in the `dm` object.
#'
#' @rdname dm
#' @export
new_dm <- function(tables = list()) {
  # Legacy
  data <- unname(tables)
  table <- names2(tables)
  zoom <- new_zoom()
  col_tracker_zoom <- new_col_tracker_zoom()

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
    left_join(col_tracker_zoom, by = "table")

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

new_col_tracker_zoom <- function() {
  tibble(table = character(), col_tracker_zoom = list())
}

#' Validator
#'
#' `validate_dm()` checks the internal consistency of a `dm` object.
#'
#' @param x An object.
#'
#' @return For `validate_dm()`: Returns the `dm`, invisibly, after finishing all checks.
#'
#' @rdname dm
#' @export
validate_dm <- function(x) {
  check_dm(x)

  if (!identical(names(unclass(x)), "def")) abort_dm_invalid("A `dm` needs to be a list of one item named `def`.")
  def <- dm_get_def(x)

  table_names <- def$table
  if (any(table_names == "")) abort_dm_invalid("Not all tables are named.")
  check_col_classes(def)

  if (!all(map_lgl(def$data, ~ {
    inherits(., "data.frame") || inherits(., "tbl_dbi")
  }))) {
    abort_dm_invalid(
      "Not all entries in `def$data` are of class `data.frame` or `tbl_dbi`. Check `dm_get_tables()`."
    )
  }
  if (!all_same_source(def$data)) abort_dm_invalid(error_txt_not_same_src())

  if (nrow(def) == 0) {
    return(invisible(x))
  }
  if (ncol(def) != 9) {
    abort_dm_invalid(
      glue(
        "Number of columns of tibble defining `dm` is wrong: {as.character(ncol(def))} ",
        "instead of 9."
      )
    )
  }

  inner_names <- map(def, names)
  if (!all(map_lgl(inner_names, is.null))) {
    abort_dm_invalid("`def` must not have inner names.")
  }

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
  if (!all(map_lgl(def$zoom, ~ {
    inherits(., "data.frame") || inherits(., "tbl_dbi") || inherits(., "NULL")
  }))) {
    abort_dm_invalid(
      "Not all entries in `def$zoom` are of class `data.frame`, `tbl_dbi` or `NULL`."
    )
  }
  invisible(x)
}

debug_validate_dm <- function(dm) {
  # Uncomment to enable validation for troubleshooting
  # validate_dm(dm)
  dm
}

#' Get source
#'
#' `dm_get_src()` returns the \pkg{dplyr} source for a `dm` object.
#' All tables in a `dm` object must be from the same source,
#' i.e. either they are all data frames, or they all are stored on the same
#' database.
#'
#' @rdname dm
#'
#' @return For `dm_get_src()`: the \pkg{dplyr} source for a `dm` object,
#'   or `NULL` if the `dm` objcet contains data frames.
#'
#' @export
dm_get_src <- function(x) {
  check_not_zoomed(x)
  dm_get_src_impl(x)
}

dm_get_src_impl <- function(x) {
  tables <- dm_get_tables_impl(x)
  tbl_src(tables[1][[1]])
}

#' Get connection
#'
#' `dm_get_con()` returns the [`DBI::DBIConnection-class`] for `dm` objects.
#' This works only if the tables are stored on a database, otherwise an error
#' is thrown.
#'
#' @rdname dm
#'
#' @return For `dm_get_con()`: The [`DBI::DBIConnection-class`] for `dm` objects.
#'
#' @export
dm_get_con <- function(x) {
  src <- dm_get_src(x)
  if (!inherits(src, "src_dbi")) abort_con_only_for_dbi()
  src$con
}

#' Get tables
#'
#' `dm_get_tables()` returns a named list of \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#' Filtering expressions are NOT evaluated at this stage.
#' To get a filtered table, use `dm_apply_filters_to_tbl()`, to apply filters to all tables use `dm_apply_filters()`
#'
#' @rdname dm
#'
#' @return For `dm_get_tables()`: A named list with the tables constituting the `dm`.
#'
#' @export
dm_get_tables <- function(x) {
  check_not_zoomed(x)
  dm_get_tables_impl(x)
}

dm_get_tables_impl <- function(x) {
  def <- dm_get_def(x)
  set_names(def$data, def$table)
}

dm_get_def <- function(x) {
  unclass(x)$def
}

dm_get_data_model_pks <- function(x) {
  # FIXME: Obliterate

  dm_get_def(x) %>%
    select(table, pks) %>%
    unnest_pks()
}

unnest_pks <- function(def) {
  # Optimized
  pk_df <- tibble(
    table = rep(def$table, map_int(def$pks, nrow))
  )

  pk_df <- vctrs::vec_cbind(pk_df, vctrs::vec_rbind(!!!def$pks))

  # FIXME: Should work better with dplyr 0.9.0
  if (!("column" %in% names(pk_df))) {
    pk_df$column <- character()
  } else {
    # This is expected to break with compound keys
    pk_df$column <- flatten_chr(pk_df$column)
  }

  pk_df
}

dm_get_data_model_fks <- function(x) {
  # FIXME: Obliterate

  fk_df <-
    dm_get_def(x) %>%
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
#' `dm_get_filters()` returns the filter expressions that have been applied to a `dm` object.
#' These filter expressions are not intended for evaluation, only for
#' information.
#'
#' @inheritParams dm
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table`}{table that was filtered,}
#'     \item{`filter`}{the filter expression,}
#'     \item{`zoomed`}{logical, does the filter condition relate to the zoomed table.}
#'   }
#'
#' @export
dm_get_filters <- function(x) {
  check_not_zoomed(x)

  filter_df <-
    dm_get_def(x) %>%
    select(table, filters) %>%
    unnest(filters)

  # FIXME: Should work better with dplyr 0.9.0
  if (!("filter_expr" %in% names(filter_df))) {
    filter_df$filter_expr <- list()
  }

  filter_df %>%
    rename(filter = filter_expr) %>%
    mutate(filter = unname(filter))
}

dm_get_zoomed_tbl <- function(x) {
  dm_get_def(x) %>%
    filter(!map_lgl(zoom, is_null)) %>%
    select(table, zoom)
}

#' Check class
#'
#' `is_dm()` returns `TRUE` if the input is of class `dm`.
#'
#' @rdname dm
#'
#' @return For `is_dm()`: Boolean, is this object a `dm`.
#'
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
    NULL
  } else if (inherits(x, "tbl_sql")) {
    dbplyr::remote_src(x)
  } else {
    abort_what_a_weird_object(class(x)[[1]])
  }
}

#' @export
as_dm.src <- function(x) {
  dm_from_src(src = x, table_names = NULL)
}

#' @export
print.dm <- function(x, ...) { # for both dm and zoomed_dm
  show_dm(x)
  invisible(x)
}

#' @export
print.zoomed_dm <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  format(x, ..., n = NULL, width = NULL, n_extra = NULL)
}

show_dm <- function(x) {
  def <- dm_get_def(x)
  if (nrow(def) == 0) {
    cat_line("dm()")
    return()
  }

  src <- dm_get_src(x)
  if (!is.null(src)) {
    cat_rule("Table source", col = "green")
    db_info <- NULL

    # FIXME: change to pillar::tbl_sum() once it's there
    tbl_str <- tibble::tbl_sum(def$data[[1]])
    if ("Database" %in% names(tbl_str)) {
      db_info <- paste0("src:  ", tbl_str[["Database"]])
    }
    if (is.null(db_info)) {
      db_info <- strsplit(format(src), "\n")[[1]][[1]]
    }

    cat_line(db_info)
  }

  cat_rule("Metadata", col = "violet")

  cat_line("Tables: ", commas(tick(def$table)))
  cat_line("Columns: ", def_get_n_columns(def))
  cat_line("Primary keys: ", def_get_n_pks(def))
  cat_line("Foreign keys: ", def_get_n_fks(def))

  filters <- dm_get_filters(x)
  if (nrow(filters) > 0) {
    cat_rule("Filters", col = "orange")
    walk2(filters$table, filters$filter, ~ cat_line(paste0(.x, ": ", as_label(.y))))
  }
}

#' @export
format.dm <- function(x, ...) { # for both dm and zoomed_dm
  def <- dm_get_def(x)
  glue("dm: {def_get_n_tables(def)} tables, {def_get_n_columns(def)} columns, {def_get_n_pks(def)} primary keys, {def_get_n_fks(def)} foreign keys")
}

#' @export
format.zoomed_dm <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  # so far only 1 table can be zoomed on
  zoomed_df <- as_zoomed_df(x)
  cat_line(format(zoomed_df, ..., n = n, width = width, n_extra = n_extra))
  invisible(x)
}

def_get_n_tables <- function(def) {
  nrow(def)
}

def_get_n_columns <- function(def) {
  sum(map_int(map(def$data, colnames), length))
}

def_get_n_pks <- function(def) {
  sum(map_int(def$pks, vctrs::vec_size))
}

def_get_n_fks <- function(def) {
  sum(map_int(def$fks, vctrs::vec_size))
}

as_zoomed_df <- function(x) {
  # for tests
  new_zoomed_df(
    get_zoomed_tbl(x),
    name_df = orig_name_zoomed(x)
  )
}

new_zoomed_df <- function(x, ...) {
  if (!is.data.frame(x)) {
    return(structure(x, class = c("zoomed_df", class(x)), ...))
  }
  # need this in order to avoid star (from rownames, automatic from `structure(...)`)
  # in print method for local tibbles
  new_tibble(
    x,
    # need setdiff(...), because we want to keep everything "special" (like groups etc.) but drop
    # all classes, that a `tbl` has anyway
    # FIXME: Remove setdiff() when tibble >= 3.0.0 is on CRAN
    class = c("zoomed_df", setdiff(class(x), c("tbl_df", "tbl", "data.frame"))),
    nrow = nrow(x),
    ...
  )
}

# this is called from `tibble:::trunc_mat()`, which is called from `tibble::format.tbl()`
# therefore, we need to have our own subclass but the main class needs to be `tbl`
#' @export
tbl_sum.zoomed_df <- function(x) {
  c(
    structure(attr(x, "name_df"), names = "Zoomed table"),
    NextMethod()
  )
}

#' @export
format.zoomed_df <- function(x, ..., n = NULL, width = NULL, n_extra = NULL) {
  NextMethod()
}

#' @export
`$.dm` <- function(x, name) { # for both dm and zoomed_dm
  table <- dm_tbl_name(x, {{ name }})
  tbl(x, table)
}

#' @export
`$.zoomed_dm` <- function(x, name) {
  name <- ensym(name)
  eval_tidy(quo(`$`(get_zoomed_tbl(x), !!name)))
}

#' @export
`$<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}

#' @export
`[[.dm` <- function(x, id) { # for both dm and zoomed_dm
  if (is.numeric(id)) id <- src_tbls(x)[id] else id <- as_string(id)
  tbl(x, id)
}

#' @export
`[[.zoomed_dm` <- function(x, id) {
  `[[`(get_zoomed_tbl(x), id)
}

#' @export
`[[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}

#' @export
`[.dm` <- function(x, id) {
  if (is.numeric(id)) id <- src_tbls(x)[id]
  id <- as.character(id)
  dm_select_tbl(x, !!!id)
}

#' @export
`[.zoomed_dm` <- function(x, id) { # for both dm and zoomed_dm
  `[`(get_zoomed_tbl(x), id)
}


#' @export
`[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}

#' @export
names.dm <- function(x) { # for both dm and zoomed_dm
  src_tbls(x)
}

#' @export
names.zoomed_dm <- function(x) {
  names(get_zoomed_tbl(x))
}


#' @export
`names<-.dm` <- function(x, value) {
  abort_update_not_supported()
}

#' @export
length.dm <- function(x) { # for both dm and zoomed_dm
  length(src_tbls(x))
}

#' @export
length.zoomed_dm <- function(x) {
  length(get_zoomed_tbl(x))
}

#' @export
`length<-.dm` <- function(x, value) {
  abort_update_not_supported()
}

#' @export
str.dm <- function(object, ...) { # for both dm and zoomed_dm
  object <- dm_get_def(object) %>%
    select(table, pks, fks, filters)
  str(object)
}

#' @export
str.zoomed_dm <- function(object, ...) {
  object <- dm_get_def(object) %>%
    mutate(zoom = if_else(map_lgl(zoom, is_null), NA_character_, table)) %>%
    select(zoom, table, pks, fks, filters)
  str(object)
}

#' \pkg{dplyr} table retrieval, table info and DB interaction methods
#'
#' Use these methods without the '.dm' or '.zoomed_dm' suffix (see examples).
#' @param src A `dm` object.
#' @param from A length one character variable containing the name of the requested table
#' @param ... See original function documentation
#' @rdname dplyr_db
#' @export
tbl.dm <- function(src, from, ...) {
  check_not_zoomed(src)

  # The src argument here is a dm object
  dm <- src
  from <- dm_tbl_name(dm, !!from)

  dm_get_tables_impl(dm)[[from]]
}

#' @param x Either a `dm` or a `zoomed_dm`; the latter leads to an error for `src_tbls.dm()`
#' @rdname dplyr_db
#' @export
compute.dm <- function(x, ...) { # for both dm and zoomed_dm
  dm_apply_filters(x) %>%
    dm_get_def() %>%
    mutate(data = map(data, compute, ...)) %>%
    new_dm3()
}

#' @rdname dplyr_db
#' @export
compute.zoomed_dm <- function(x, ...) {
  zoomed_df <-
    get_zoomed_tbl(x) %>%
    compute(...)
  replace_zoomed_tbl(x, zoomed_df)
}

#' @rdname dplyr_db
#' @export
src_tbls.dm <- function(x, ...) {
  check_not_zoomed(x)
  src_tbls_impl(x)
}

src_tbls_impl <- function(dm) {
  dm_get_def(dm)$table
}

#' @rdname dplyr_db
#' @param dest For `copy_to.dm()`: The `dm` object to which a table should be copied.
#' @param df For `copy_to.dm()`: A table (can be on a different `src`)
#' @param name For `copy_to.dm()`: See [`dplyr::copy_to`]
#' @param overwrite For `copy_to.dm()`: See [`dplyr::copy_to`]; `TRUE` leads to an error
#' @param temporary For `copy_to.dm()`: If the `dm` is on a DB, the copied version of `df` will only be written temporarily to the DB.
#' After the connection is reset it will no longer be available.
#' @param repair,quiet Name repair options; cf. [`vctrs::vec_as_names`]
#' @export
copy_to.dm <- function(dest, df, name = deparse(substitute(df)), overwrite = FALSE, temporary = TRUE, repair = "unique", quiet = FALSE, ...) {
  check_not_zoomed(dest)

  if (!(inherits(df, "data.frame") || inherits(df, "tbl_dbi"))) abort_only_data_frames_supported()
  if (overwrite) abort_no_overwrite()
  if (length(name) != 1) abort_one_name_for_copy_to(name)
  # src: if `df` on a different src:
  # if `df_list` is on DB and `dest` is local, collect `df_list`
  # if `df_list` is local and `dest` is on DB, copy `df_list` to respective DB
  dest_src <- dm_get_src(dest)
  if (is.null(dest_src)) {
    df <- as_tibble(collect(df))
  } else {
    # FIXME: should we allow `overwrite` argument?
    df <- copy_to(dest_src, df, unique_db_table_name(name), temporary = temporary, ...)
  }
  names_list <- repair_table_names(src_tbls(dest), name, repair, quiet)
  # rename old tables with potentially new names
  dest <- dm_rename_tbl(dest, !!!names_list$new_old_names)
  # `repair` argument is `unique` by default
  dm_add_tbl_impl(dest, list(df), names_list$new_names)
}

#' @rdname dplyr_db
#' @export
collect.dm <- function(x, ...) { # for both dm and zoomed_dm
  x <- dm_apply_filters(x)

  def <- dm_get_def(x)
  def$data <- map(def$data, collect, ...)
  new_dm3(def, zoomed = is_zoomed(x))
}

#' @export
collect.zoomed_dm <- function(x, ...) {
  message("Detaching table from dm, use `collect(pull_tbl())` instead to silence this message.")

  collect(pull_tbl(x))
}


# FIXME: what about 'dim.dm()'?
#' @export
dim.zoomed_dm <- function(x) { # dm method provided by base
  dim(get_zoomed_tbl(x))
}

#' @export
dimnames.zoomed_dm <- function(x) { # dm method provided by base
  dimnames(get_zoomed_tbl(x))
}

#' @export
tbl_vars.dm <- function(x) {
  check_zoomed(x)
}

#' @export
tbl_vars.zoomed_dm <- function(x) {
  tbl_vars(get_zoomed_tbl(x))
}

dm_reset_all_filters <- function(dm) {
  def <- dm_get_def(dm)
  def$filters <- vctrs::list_of(new_filter())
  new_dm3(def)
}

all_same_source <- function(tables) {
  # Use `NULL` if `tables` is empty
  first_table <- tables[1][[1]]
  is.null(detect(tables[-1], ~ !same_src(., first_table)))
}

# creates an empty `dm`-object, `src` is defined by implementation of `dm_get_src()`.
empty_dm <- function() {
  new_dm3(
    tibble(
      table = character(),
      data = list(),
      segment = character(),
      display = character(),
      pks = vctrs::list_of(new_pk()),
      fks = vctrs::list_of(new_fk()),
      filters = vctrs::list_of(new_filter()),
      zoom = list(),
      col_tracker_zoom = list()
    )
  )
}

#' Retrieve a table
#'
#' This function has methods for both `dm` classes:
#' 1. With `pull_tbl.dm()` you can chose which table of the `dm` you want to retrieve.
#' 1. With `pull_tbl.zoomed_dm()` you will retrieve the zoomed table in the current state.
#'
#' @inheritParams dm_add_pk
#' @param table One unquoted table name for `pull_tbl.dm()`, ignored for `pull_tbl.zoomed_dm()`.
#'
#' @return The requested table
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' # For an unzoomed dm you need to specify the table to pull:
#' dm_nycflights13() %>%
#'   pull_tbl(airports)
#'
#' # If zoomed, pulling detaches the zoomed table from the dm:
#' dm_nycflights13() %>%
#'   dm_zoom_to(airports) %>%
#'   pull_tbl()
#' @export
pull_tbl <- function(dm, table) {
  UseMethod("pull_tbl")
}

#' @export
pull_tbl.dm <- function(dm, table) { # for both dm and zoomed_dm
  # FIXME: shall we issue a special error in case someone tries sth. like: `pull_tbl(dm_for_filter, c(t4, t3))`?
  table_name <- as_string(enexpr(table))
  if (table_name == "") abort_no_table_provided()
  tbl(dm, table_name)
}

#' @export
pull_tbl.zoomed_dm <- function(dm, table) {
  table_name <- as_string(enexpr(table))
  tbl_zoomed <- dm_get_zoomed_tbl(dm)
  if (table_name == "") {
    if (nrow(tbl_zoomed) == 1) {
      tbl_zoomed$zoom[[1]]
    } else {
      abort_not_pulling_multiple_zoomed()
    }
  } else if (!(table_name %in% tbl_zoomed$table)) {
    abort_table_not_zoomed(table_name, tbl_zoomed$table)
  } else {
    filter(tbl_zoomed, table == table_name) %>%
      pull(zoom) %>%
      pluck(1)
  }
}

#' @export
as.list.dm <- function(x, ...) { # for both dm and zoomed_dm
  dm_get_tables_impl(x)
}

#' @export
as.list.zoomed_dm <- function(x, ...) {
  as.list(get_zoomed_tbl(x))
}
