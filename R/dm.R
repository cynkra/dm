#' Data model class
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' The `dm` class holds a list of tables and their relationships.
#' It is inspired by [datamodelr](https://github.com/bergant/datamodelr),
#' and extends the idea by offering operations to access the data in the tables.
#'
#' `dm()` creates a `dm` object from [tbl] objects
#' (tibbles or lazy data objects).
#'
#' @param ... Tables or existing `dm` objects to add to the `dm` object.
#'   Unnamed tables are auto-named, `dm` objects must not be named.
#' @param .name_repair,.quiet Options for name repair.
#'   Forwarded as `repair` and `quiet` to [vctrs::vec_as_names()].
#'
#' @return For `dm()`, `new_dm()`, `as_dm()`: A `dm` object.
#'
#' @seealso
#'
#' - [dm_from_con()] for connecting to all tables in a database
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
#'
#' new_dm(list(trees = trees, mtcars = mtcars))
#'
#' as_dm(list(trees = trees, mtcars = mtcars))
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")
#'
#' is_dm(dm_nycflights13())
#'
#' dm_nycflights13()$airports
#'
#' dm_nycflights13()["airports"]
#'
#' dm_nycflights13()[["airports"]]
#'
#' dm_nycflights13() %>% names()
#'
#' dm_nycflights13() %>% dm_get_tables()
dm <- function(...,
               .name_repair = c("check_unique", "unique", "universal", "minimal"),
               .quiet = FALSE) {
  quos <- enquos(...)

  dots <- map(quos, eval_tidy)

  is_dm <- map_lgl(dots, is_dm)

  stopifnot(names2(quos)[is_dm] == "")

  def_dm <- dm_bind_impl(dots[is_dm], .name_repair, .quiet)
  def_tbl <- dm_impl(dots[!is_dm], names(quos_auto_name(quos[!is_dm])), .name_repair, .quiet)
  def <- vec_rbind(def_dm, def_tbl)

  dm <- new_dm3(def)
  dm_validate(dm)
  dm
}

dm_impl <- function(tbls, names, repair, quiet, call = caller_env()) {
  names(tbls) <- vec_as_names(names, repair = repair, quiet = quiet, call = call)

  new_dm_def(tbls)
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
#'   use [dm_validate()] to double-check the returned object.
#'
#' @param tables A named list of the tables (tibble-objects, not names),
#'   to be included in the `dm` object.
#'
#' @rdname dm
#' @export
new_dm <- function(tables = list()) {
  def <- new_dm_def(tables)
  new_dm3(def)
}

new_dm_def <- function(tables = list(),
                       pks_df = tibble(table = character(), pks = list()),
                       fks_df = tibble(table = character(), fks = list()),
                       validate = TRUE) {
  # Legacy
  data <- unname(tables)
  table <- names2(tables)

  stopifnot(all(pks_df$table %in% table))
  stopifnot(all(fks_df$table %in% table))

  zoom <- new_zoom()
  col_tracker_zoom <- new_col_tracker_zoom()

  filters <-
    tibble(
      table = table,
      filters = list_of(new_filter())
    )

  def <-
    tibble(table, data, segment = NA_character_, display = NA_character_) %>%
    left_join(pks_df, by = "table") %>%
    mutate(pks = as_list_of(map(pks, `%||%`, new_pk()), .ptype = new_pk())) %>%
    left_join(fks_df, by = "table") %>%
    mutate(fks = as_list_of(map(fks, `%||%`, new_fk()), .ptype = new_fk())) %>%
    mutate(filters = list_of(new_filter())) %>%
    left_join(zoom, by = "table") %>%
    left_join(col_tracker_zoom, by = "table")

  def
}

new_dm3 <- function(def, zoomed = FALSE, validate = TRUE) {
  class <- c(
    if (zoomed) "zoomed_dm",
    "dm"
  )
  out <- structure(list(def = def), class = class, version = 2L)

  # Enable for strict tests (search for INSTRUMENT in .github/workflows):
  # if (validate) { dm_validate(out) } # INSTRUMENT: validate

  out
}

dm_get_def <- function(x, quiet = FALSE) {
  # FIXME: Move that check to callers, for speed
  # Most callers already call it, but not all
  check_dm(x)

  if (!identical(attr(x, "version"), 2L)) {
    x <- dm_upgrade(x, quiet)
  }
  unclass(x)$def
}

new_pk <- function(column = list()) {
  stopifnot(is.list(column))
  tibble(column = column)
}

new_fk <- function(ref_column = list(), table = character(), column = list(), on_delete = character()) {
  stopifnot(is.list(column), is.list(ref_column), length(table) == length(column), length(table) == length(ref_column), length(on_delete) %in% c(1L, length(table)))
  tibble(ref_column, table, column, on_delete)
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

#' Get tables
#'
#' `dm_get_tables()` returns a named list of \pkg{dplyr} [tbl] objects
#' of a `dm` object.
#' Filtering expressions defined by [dm_filter()] are NOT evaluated at this stage.
#' To get a filtered table, use [dm_apply_filters_to_tbl()], to apply filters to all tables use [dm_apply_filters()].
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

dm_get_tables_impl <- function(x, quiet = FALSE) {
  def <- dm_get_def(x, quiet)
  set_names(def$data, def$table)
}

unnest_pks <- function(def) {
  # Optimized
  pk_df <- tibble(
    table = rep(def$table, map_int(def$pks, nrow))
  )

  pk_df <- vec_cbind(pk_df, vec_rbind(!!!def$pks))

  # FIXME: Should work better with dplyr 0.9.0
  if (!("column" %in% names(pk_df))) {
    pk_df$column <- character()
  }

  pk_df
}

dm_get_zoom <- function(x, cols = c("table", "zoom"), quiet = FALSE) {
  # Performance
  def <- dm_get_def(x, quiet)
  zoom <- def$zoom
  where <- which(!map_lgl(zoom, is.null))
  if (length(where) != 1) {
    # FIXME: Better error message?
    abort_not_pulling_multiple_zoomed()
  }
  def[where, cols]
}

#' Check class
#'
#' `is_dm()` returns `TRUE` if the input is of class `dm`.
#'
#' @param x An object.
#'
#' @rdname dm
#'
#' @return For `is_dm()`: A scalar logical, `TRUE` if is this object is a `dm`.
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
  names(x) <- vec_as_names(names2(x), repair = "unique")
  dm <- new_dm(x)
  dm_validate(dm)
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
  dm_from_con(con = con_from_src_or_con(x), table_names = NULL)
}

#' @export
as_dm.DBIConnection <- function(x) {
  dm_from_con(con = x, table_names = NULL)
}

#' @export
print.dm <- function(x, ...) {
  # for both dm and zoomed_dm
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

  src <- dm_get_src_impl(x)
  if (!is.null(src)) {
    cat_rule("Table source", col = "green")
    db_info <- NULL

    tbl_str <- pillar::tbl_sum(def$data[[1]])
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
format.dm <- function(x, ...) {
  # for both dm and zoomed_dm
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
  sum(map_int(def$pks, vec_size))
}

def_get_n_fks <- function(def) {
  sum(map_int(def$fks, vec_size))
}

as_zoomed_df <- function(x) {
  zoomed <- dm_get_zoom(x)

  # for tests
  new_zoomed_df(
    zoomed$zoom[[1]],
    name_df = zoomed$table
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
    class = c("zoomed_df", class(x), c("tbl_df", "tbl", "data.frame")),
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
`$.dm` <- function(x, name) {
  # for both dm and zoomed_dm
  table <- dm_tbl_name(x, {{ name }})
  tbl_impl(x, table)
}

#' @export
`$.zoomed_dm` <- function(x, name) {
  name <- ensym(name)
  eval_tidy(quo(`$`(tbl_zoomed(x), !!name)))
}

#' @export
`$<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}

#' @export
`[[.dm` <- function(x, id) {
  # for both dm and zoomed_dm
  if (is.numeric(id)) id <- src_tbls_impl(x)[id] else id <- as_string(id)
  tbl_impl(x, id, quiet = TRUE)
}

#' @export
`[[.zoomed_dm` <- function(x, id) {
  `[[`(tbl_zoomed(x, quiet = TRUE), id)
}

#' @export
`[[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}

#' @export
`[.dm` <- function(x, id) {
  if (is.numeric(id)) id <- src_tbls_impl(x)[id]
  id <- as.character(id)
  dm_select_tbl(x, !!!id)
}

#' @export
`[.zoomed_dm` <- function(x, id) {
  # for both dm and zoomed_dm
  `[`(tbl_zoomed(x), id)
}


#' @export
`[<-.dm` <- function(x, name, value) {
  abort_update_not_supported()
}

#' @export
names.dm <- function(x) {
  # for both dm and zoomed_dm
  src_tbls_impl(x, quiet = TRUE)
}

#' @export
names.zoomed_dm <- function(x) {
  names(tbl_zoomed(x, quiet = TRUE))
}


#' @export
`names<-.dm` <- function(x, value) {
  abort_update_not_supported()
}

#' @export
length.dm <- function(x) {
  # for both dm and zoomed_dm
  length(src_tbls_impl(x, quiet = TRUE))
}

#' @export
length.zoomed_dm <- function(x) {
  length(tbl_zoomed(x, quiet = TRUE))
}

#' @export
`length<-.dm` <- function(x, value) {
  abort_update_not_supported()
}

#' @export
str.dm <- function(object, ...) {
  # for both dm and zoomed_dm
  object <-
    dm_get_def(object, quiet = TRUE) %>%
    select(table, pks, fks, filters)
  str(object)
}

#' @export
str.zoomed_dm <- function(object, ...) {
  object <-
    dm_get_def(object, quiet = TRUE) %>%
    mutate(zoom = if_else(map_lgl(zoom, is_null), NA_character_, table)) %>%
    select(zoom, table, pks, fks, filters)
  str(object)
}

tbl_impl <- function(dm, from, quiet = FALSE) {
  out <- dm_get_tables_impl(dm, quiet)[[from]]

  if (is.null(out)) {
    abort_table_not_in_dm(from, src_tbls_impl(dm))
  }

  out
}

src_tbls_impl <- function(dm, quiet = FALSE) {
  dm_get_def(dm, quiet)$table
}

#' Materialize
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' `compute()` materializes all tables in a `dm` to new (temporary or permanent)
#' tables on the database.
#'
#' @details
#' Called on a `dm` object, these methods create a copy of all tables in the `dm`.
#' Depending on the size of your data this may take a long time.
#'
#' @param x A `dm`.
#' @param ... Passed on to [compute()].
#' @return A `dm` object of the same structure as the input.
#' @name materialize
#' @export
#' @examplesIf dm:::dm_has_financial()
#' financial <- dm_financial_sqlite()
#'
#' financial %>%
#'   pull_tbl(districts) %>%
#'   dbplyr::remote_name()
#'
#' # compute() copies the data to new tables:
#' financial %>%
#'   compute() %>%
#'   pull_tbl(districts) %>%
#'   dbplyr::remote_name()
#'
#' # collect() returns a local dm:
#' financial %>%
#'   collect() %>%
#'   pull_tbl(districts) %>%
#'   class()
compute.dm <- function(x, ...) {
  # for both dm and zoomed_dm
  x %>%
    dm_apply_filters() %>%
    dm_get_def() %>%
    mutate(data = map(data, compute, ...)) %>%
    new_dm3()
}

#' Materialize
#'
#' `collect()` downloads the tables in a `dm` object as local [tibble]s.
#'
#' @inheritParams dm_examine_constraints
#'
#' @rdname materialize
#' @export
collect.dm <- function(x, ..., progress = NA) {
  # for both dm and zoomed_dm
  x <- dm_apply_filters(x)

  def <- dm_get_def(x)

  ticker <- new_ticker("downloading data", nrow(def), progress = progress)
  def$data <- map(def$data, ticker(collect), ...)
  new_dm3(def, zoomed = is_zoomed(x))
}

#' @export
collect.zoomed_dm <- function(x, ...) {
  message("Detaching table from dm, use `collect(pull_tbl())` instead to silence this message.")

  collect(pull_tbl(x))
}


# FIXME: what about 'dim.dm()'?
#' @export
dim.zoomed_dm <- function(x) {
  # dm method provided by base
  dim(tbl_zoomed(x, quiet = TRUE))
}

#' @export
dimnames.zoomed_dm <- function(x) {
  # dm method provided by base
  dimnames(tbl_zoomed(x))
}

#' @export
tbl_vars.dm <- function(x) {
  check_zoomed(x)
}

#' @export
tbl_vars.zoomed_dm <- function(x) {
  tbl_vars(tbl_zoomed(x))
}

dm_reset_all_filters <- function(dm) {
  def <- dm_get_def(dm)
  def$filters <- list_of(new_filter())
  new_dm3(def)
}

all_same_source <- function(tables) {
  # Use `NULL` if `tables` is empty
  first_table <- tables[1][[1]]
  is.null(detect(tables[-1], ~ !same_src(., first_table)))
}

# creates an empty `dm`-object, `src` is defined by implementation of `dm_get_src_impl()`.
empty_dm <- function() {
  new_dm3(
    tibble(
      table = character(),
      data = list(),
      segment = character(),
      display = character(),
      pks = list_of(new_pk()),
      fks = list_of(new_fk()),
      filters = list_of(new_filter()),
      zoom = list(),
      col_tracker_zoom = list()
    )
  )
}

#' Retrieve a table
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' This generic has methods for both `dm` classes:
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
pull_tbl.dm <- function(dm, table) {
  # for both dm and zoomed_dm
  # FIXME: shall we issue a special error in case someone tries sth. like: `pull_tbl(dm_for_filter, c(t4, t3))`?
  table_name <- as_string(enexpr(table))
  if (table_name == "") abort_no_table_provided()
  tbl_impl(dm, table_name)
}

#' @export
pull_tbl.zoomed_dm <- function(dm, table) {
  table_name <- as_string(enexpr(table))
  zoomed <- dm_get_zoom(dm)
  if (table_name == "") {
    if (nrow(zoomed) == 1) {
      zoomed$zoom[[1]]
    } else {
      abort_not_pulling_multiple_zoomed()
    }
  } else if (!(table_name %in% zoomed$table)) {
    abort_table_not_zoomed(table_name, zoomed$table)
  } else {
    zoomed$zoom[[1]]
  }
}

#' @export
as.list.dm <- function(x, ...) {
  # for both dm and zoomed_dm
  dm_get_tables_impl(x)
}

#' @export
as.list.zoomed_dm <- function(x, ...) {
  as.list(tbl_zoomed(x))
}

#' Get a glimpse of your `dm` object
#'
#' @param x A `dm` object.
#' @param width Controls the maximum number of columns on a line used in
#'   printing. If `NULL`, `getOption("width")` will be consulted.
#' @param ... Passed to [pillar::glimpse()].
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' `glimpse()` provides an overview (dimensions, column data types, primary
#' keys, etc.) of all tables included in the `dm` object. It will additionally
#' print details about outgoing foreign keys for the child table.
#'
#' `glimpse()` is provided by the pillar package, and re-exported by {dm}.
#'  See [pillar::glimpse()] for more details.
#'
#' @examples
#'
#' dm_nycflights13() %>% glimpse()
#'
#' dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   glimpse()
#'
#' @export
glimpse.dm <- function(x, width = NULL, ...) {
  glimpse_width <- width %||% getOption("width")
  table_names_list <- names(dm_get_tables_impl(x))

  print_glimpse_table_meta(x, glimpse_width)
  if (!is_empty(table_names_list)) {
    print_rule_between_tables()
  }
  walk(table_names_list, ~ print_glimpse_table(x, .x, glimpse_width, ...))

  invisible(x)
}

#' @rdname glimpse.dm
#' @export
glimpse.zoomed_dm <- function(x, width = NULL, ...) {
  glimpse_width <- width %||% getOption("width")

  table_name <- dm_get_zoom(x)$table[[1]]

  print_glimpse_table_meta(x, glimpse_width)
  print_glimpse_table(x, table_name, glimpse_width, ...)

  invisible(x)
}

#' Print details about all tables included in the `dm` object (zoomed or not)
#' @keywords internal
#' @noRd
print_glimpse_table_meta <- function(x, width) {
  table_list <- dm_get_tables_impl(x)

  if (length(table_list) == 0) {
    cat_line(trim_width("dm of 0 tables", width))
    return(invisible(x))
  }

  cat_line(
    trim_width(
      paste0("dm of ", length(table_list), " tables: ", toString(tick(names(table_list)))),
      width
    )
  )
}

#' @keywords internal
#' @noRd
print_rule_between_tables <- function() {
  cat("\n")
  cat_rule()
}


#' Print glimpse for a single table included in the `dm` object (zoomed or not)
#' @keywords internal
#' @noRd
print_glimpse_table <- function(x, table_name, width, ...) {
  if (is_zoomed(x)) {
    table <- dm_get_zoom(x)$zoom[[1]]
  } else {
    table <- x[[table_name]]
  }

  # `print_glimpse_table_meta()` is not part of this because it needs to be
  # printed only once for the entire object
  print_glimpse_table_name(x, table_name, width)
  print_glimpse_table_pk(x, table_name, width)
  print_glimpse_table_fk(x, table_name, width)
  # emtpy line to demarcate clearly information about keys and the glimpse info
  cat("\n")
  glimpse(table, width = width, ...)
  # in case the object is not zoomed, the following will help visually
  # distinguish between glimpse outputs for individual tables
  if (!is_zoomed(x)) print_rule_between_tables()
}

#' Print table name for a given table in the `dm` object (zoomed or not)
#' @keywords internal
#' @noRd
print_glimpse_table_name <- function(x, table_name, width) {
  if (is_zoomed(x)) {
    cat_line("\n", trim_width(paste0("Zoomed table: ", tick(table_name)), width))
  } else {
    cat_line("\n", trim_width(paste0("Table: ", tick(table_name)), width))
  }
}

#' Print details about primary key for a given table in the `dm` object (zoomed or not)
#' @keywords internal
#' @noRd
print_glimpse_table_pk <- function(x, table_name, width) {
  pk <- dm_get_pk_impl(x, table_name)

  # anticipate that some key columns could have been removed by the user
  if (is_zoomed(x)) {
    pk <-
      update_zoomed_pk(x) %>%
      pull(column)
  }

  pk <- pk %>%
    map_chr(~ collapse_key_names(.x))

  if (!is_empty(pk)) {
    # FIXME: needs to change if #622 is solved
    cat_line(trim_width(paste0("Primary key: ", pk), width))
  }
}

collapse_key_names <- function(keys, tab = FALSE) {
  tab <- ifelse(tab, "  ", "")
  if (length(keys) > 1L) {
    paste0(tab, "(", paste0(tick(keys), collapse = ", "), ")")
  } else {
    paste0(tab, tick(keys), collapse = ", ")
  }
}

#' Print details about foreign keys for a given table in the `dm` object (zoomed or not)
#' @keywords internal
#' @noRd
print_glimpse_table_fk <- function(x, table_name, width) {
  all_fks <- if (is_zoomed(x)) {
    # anticipate that some key columns could have been removed/renamed by the user
    update_zoomed_fks(x, table_name, col_tracker_zoomed(x))
  } else {
    dm_get_all_fks_impl(x)
  }

  fk <- all_fks %>%
    filter(child_table == !!table_name) %>%
    select(-child_table) %>%
    pmap_chr(
      function(child_fk_cols, parent_table, parent_key_cols, on_delete) {
        trim_width(
          paste0(
            collapse_key_names(child_fk_cols, tab = TRUE),
            " -> ",
            collapse_key_names(paste0(parent_table, "$", parent_key_cols)),
            " ",
            on_delete
          ),
          width
        )
      }
    )

  if (!is_empty(fk)) {
    cat_line(length(fk), " outgoing foreign key(s):")
    cat_line(fk)
  }
}
