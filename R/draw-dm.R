#' Draw a diagram of the data model
#'
#' @description
#' `dm_draw()` draws a diagram, a visual representation of the data model.
#'
#' @details
#' Currently, \pkg{dm} uses \pkg{DiagrammeR} to draw diagrams.
#' Use [DiagrammeRsvg::export_svg()] to convert the diagram to an SVG file.
#'
#' The backend for drawing the diagrams might change in the future.
#' If you rely on DiagrammeR, pass an explicit value for the `backend` argument.
#'
#' @param dm A [`dm`] object.
#' @param rankdir Graph attribute for direction (e.g., 'BT' = bottom --> top).
#' @param col_attr Deprecated, use `colummn_types` instead.
#' @param view_type Can be "keys_only" (default), "all" or "title_only".
#'   It defines the level of details for rendering tables
#'   (only primary and foreign keys, all columns, or no columns).
#' @inheritParams rlang::args_dots_empty
#' @param column_types Set to `TRUE` to show column types.
#' @param backend Currently, only the default `"DiagrammeR"` is accepted.
#'   Pass this value explicitly if your code relies on the type of the return value.
#' @param backend_opts A named list of backend-specific options.
#'   For the `"DiagrammeR"` backend, supported options are:
#'   - `graph_attrs`: Additional graph attributes (default `""`).
#'   - `node_attrs`: Additional node attributes (default `""`).
#'   - `edge_attrs`: Additional edge attributes (default `""`).
#'   - `focus`: A list of parameters for rendering (table filter).
#'   - `graph_name`: The name of the graph (default `"Data Model"`).
#'   - `column_arrow`: Edges from columns to columns (default `TRUE`).
#'   - `font_size`: `r lifecycle::badge("experimental")`
#'     Font size for `header` (default `16`), `column` (default `16`),
#'     and `table_description` (default `8`).
#'     Can be set as a named integer vector, e.g.
#'     `c(table_headers = 18L, table_description = 6L)`.
#' @param columnArrows `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(column_arrow = ...)` instead.
#' @param graph_attrs `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(graph_attrs = ...)` instead.
#' @param node_attrs `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(node_attrs = ...)` instead.
#' @param edge_attrs `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(edge_attrs = ...)` instead.
#' @param focus `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(focus = ...)` instead.
#' @param graph_name `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(graph_name = ...)` instead.
#' @param font_size `r lifecycle::badge("deprecated")` Use
#'   `backend_opts = list(font_size = ...)` instead.
#'
#' @seealso [dm_set_colors()] for defining the table colors.
#' @seealso [dm_set_table_description()] for adding details to one or more tables in the diagram
#'
#' @export
#'
#' @return An object with a [print()] method, which,
#' when printed, produces the output seen in the viewer as a side effect.
#' Currently, this is an object of class `grViz` (see also
#' [DiagrammeR::grViz()]), but this is subject to change.
#'
#' @examplesIf rlang::is_installed(c("nycflights13", "DiagrammeR"))
#' dm_nycflights13() %>%
#'   dm_draw()
#'
#' dm_nycflights13(cycle = TRUE) %>%
#'   dm_draw(view_type = "title_only")
#'
#' head(dm_get_available_colors())
#' length(dm_get_available_colors())
#'
#' dm_nycflights13() %>%
#'   dm_get_colors()
dm_draw <- function(
  dm,
  rankdir = "LR",
  ...,
  col_attr = NULL,
  view_type = c("keys_only", "all", "title_only"),
  column_types = NULL,
  backend = c("DiagrammeR"),
  backend_opts = list(),
  columnArrows = lifecycle::deprecated(),
  graph_attrs = lifecycle::deprecated(),
  node_attrs = lifecycle::deprecated(),
  edge_attrs = lifecycle::deprecated(),
  focus = lifecycle::deprecated(),
  graph_name = lifecycle::deprecated(),
  font_size = lifecycle::deprecated()
) {
  dm_local_error_call()
  check_not_zoomed(dm)
  check_dots_empty()

  # Handle deprecated DiagrammeR-specific arguments
  if (lifecycle::is_present(columnArrows)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(columnArrows = )",
      details = "Use `backend_opts = list(column_arrow = ...)` instead."
    )
    backend_opts[["column_arrow"]] <- backend_opts[["column_arrow"]] %||% columnArrows
  }
  if (lifecycle::is_present(graph_attrs)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(graph_attrs = )",
      details = "Use `backend_opts = list(graph_attrs = ...)` instead."
    )
    backend_opts[["graph_attrs"]] <- backend_opts[["graph_attrs"]] %||% graph_attrs
  }
  if (lifecycle::is_present(node_attrs)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(node_attrs = )",
      details = "Use `backend_opts = list(node_attrs = ...)` instead."
    )
    backend_opts[["node_attrs"]] <- backend_opts[["node_attrs"]] %||% node_attrs
  }
  if (lifecycle::is_present(edge_attrs)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(edge_attrs = )",
      details = "Use `backend_opts = list(edge_attrs = ...)` instead."
    )
    backend_opts[["edge_attrs"]] <- backend_opts[["edge_attrs"]] %||% edge_attrs
  }
  if (lifecycle::is_present(focus)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(focus = )",
      details = "Use `backend_opts = list(focus = ...)` instead."
    )
    backend_opts[["focus"]] <- backend_opts[["focus"]] %||% focus
  }
  if (lifecycle::is_present(graph_name)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(graph_name = )",
      details = "Use `backend_opts = list(graph_name = ...)` instead."
    )
    backend_opts[["graph_name"]] <- backend_opts[["graph_name"]] %||% graph_name
  }
  if (lifecycle::is_present(font_size)) {
    lifecycle::deprecate_soft(
      "1.1.0",
      "dm_draw(font_size = )",
      details = "Use `backend_opts = list(font_size = ...)` instead."
    )
    backend_opts[["font_size"]] <- backend_opts[["font_size"]] %||% font_size
  }

  tbl_names <- src_tbls_impl(dm, quiet = TRUE)
  table_description <- dm_get_table_description_impl(
    dm,
    set_names(seq_along(tbl_names), tbl_names)
  ) %>%
    prep_recode()

  view_type <- arg_match(view_type)

  if (!is.null(col_attr)) {
    deprecate_warn("0.1.13", "dm::dm_draw(col_attr = )", "dm::dm_draw(column_types = )")
    if (is.null(column_types) && "type" %in% col_attr) {
      column_types <- TRUE
    }
  }

  backend <- arg_match(backend)

  supported_backend_opts <- c(
    "graph_attrs",
    "node_attrs",
    "edge_attrs",
    "focus",
    "graph_name",
    "column_arrow",
    "font_size"
  )
  unsupported <- setdiff(names(backend_opts), supported_backend_opts)
  if (length(unsupported) > 0) {
    cli::cli_abort(
      c(
        "Unsupported {.arg backend_opts} for backend {.val {backend}}: {.field {unsupported}}.",
        i = "Supported options are: {.field {supported_backend_opts}}."
      ),
      class = dm_error_full("unsupported_backend_opts"),
      call = dm_error_call()
    )
  }

  if (is_empty(dm)) {
    message("The dm cannot be drawn because it is empty.")
    return(invisible(NULL))
  }

  column_types <- isTRUE(column_types)

  data_model <- dm_get_data_model(dm, column_types)

  # DiagrammeR backend (default)
  graph <- bdm_create_graph(
    data_model,
    rankdir = rankdir,
    col_attr = c("column", if (column_types) "type"),
    view_type = view_type,
    columnArrows = backend_opts[["column_arrow"]] %||% TRUE,
    graph_attrs = backend_opts[["graph_attrs"]] %||% "",
    node_attrs = backend_opts[["node_attrs"]] %||% "",
    edge_attrs = backend_opts[["edge_attrs"]] %||% "",
    focus = backend_opts[["focus"]],
    graph_name = backend_opts[["graph_name"]] %||% "Data Model",
    table_description = as.list(table_description),
    font_size = as.list(backend_opts[["font_size"]])
  )
  bdm_render_graph(graph, top_level_fun = "dm_draw")
}

#' Get data_model
#'
#' `dm_get_data_model()` converts a `dm` to a \pkg{datamodelr}
#' data model object for drawing.
#'
#' @noRd
#' @autoglobal
dm_get_data_model <- function(x, column_types = FALSE) {
  def <- dm_get_def(x)

  tables <- data.frame(
    table = def$table,
    segment = def$segment,
    display = def$display,
    stringsAsFactors = FALSE
  )

  all_uks <- dm_get_all_uks_impl(x)
  references_for_columns <- dm_get_all_fks_impl(x, id = TRUE) %>%
    left_join(all_uks, by = c("parent_table" = "table", "parent_key_cols" = "uk_col")) %>%
    rename(uk_col = kind) %>%
    transmute(
      table = child_table,
      column = format(child_fk_cols),
      ref = parent_table,
      ref_col = format(parent_key_cols),
      keyId = id,
      uk_col = if_else(uk_col != "PK", ", style=\"dashed\"", "")
    )

  references <-
    references_for_columns %>%
    mutate(ref_id = row_number(), ref_col_num = 1L)

  keys_pk <-
    all_uks %>%
    mutate(column = format(uk_col)) %>%
    select(table, column, kind) %>%
    mutate(key = 1L)

  keys_fk <-
    dm_get_all_fks_impl(x) %>%
    mutate(column = format(parent_key_cols)) %>%
    select(table = parent_table, column) %>%
    mutate(key_fk = 2L) %>%
    # `parent_table` and `column` can be referenced by multiple child tables
    distinct()

  if (column_types) {
    types <- dm_get_all_column_types(x)
  } else {
    types <- dm_get_all_columns(x)
  }

  columns <-
    types %>%
    full_join(keys_pk, by = c("table", "column")) %>%
    full_join(keys_fk, by = c("table", "column")) %>%
    # there is a legitimate interest to have duplicates in `table` and `column`
    # in table `references_for_columns`.
    # When using a dplyr version >= 1.1.0, we get a warning in that case, thus
    # we need `multiple = "all"`.
    # FIXME: is there another way? like this we need a min dplyr version 1.1.0.
    full_join(references_for_columns, by = c("table", "column"), multiple = "all") %>%
    # Order matters: key == 2 if foreign key points to non-default primary key
    mutate(key = coalesce(key, key_fk, 0L)) %>%
    select(-key_fk) %>%
    # I don't understand why this is necessary
    distinct() %>%
    # for compatibility with print method from {datamodelr}
    as.data.frame()

  new_data_model(
    tables,
    columns,
    references
  )
}

dm_get_all_columns <- function(x) {
  x %>%
    dm_get_tables_impl() %>%
    map(colnames) %>%
    map(~ enframe(., "id", "column")) %>%
    enframe("table") %>%
    unnest_df("value", tibble(id = integer(), column = character())) %>%
    select(table, column, id)
}

#' @autoglobal
dm_get_all_column_types <- function(x) {
  x %>%
    dm_get_tables_impl() %>%
    map(
      ~ mutate(
        enframe(as.list(collect(head(.x, 0))), "column"),
        id = row_number()
      )
    ) %>%
    enframe("table") %>%
    unnest_df("value", tibble(column = character(), value = list(), id = integer())) %>%
    mutate(type = map_chr(value, vec_ptype_abbr), .keep = "unused")
}

#' Color in database diagrams
#'
#' @description
#' `dm_set_colors()` allows to define the colors that will be used to display the tables of the data model with [dm_draw()].
#' The colors can either be specified with hex color codes or using the names of the built-in R colors.
#' An overview of the colors corresponding to the standard color names can be found at
#' the bottom of
#' [https://rpubs.com/krlmlr/colors](https://rpubs.com/krlmlr/colors).
#'
#' @inheritParams dm_draw
#' @param ... Colors to set in the form `color = table`.
#' Allowed colors are all hex coded colors (quoted) and the color names from `dm_get_available_colors()`.
#' `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#' @return For `dm_set_colors()`: the updated data model.
#'
#' @export
#' @examplesIf rlang::is_installed(c("nycflights13", "DiagrammeR"))
#' dm_nycflights13(color = FALSE) %>%
#'   dm_set_colors(
#'     darkblue = starts_with("air"),
#'     "#5986C4" = flights
#'   ) %>%
#'   dm_draw()
#'
#' # Splicing is supported:
#' nyc_cols <-
#'   dm_nycflights13() %>%
#'   dm_get_colors()
#' nyc_cols
#'
#' dm_nycflights13(color = FALSE) %>%
#'   dm_set_colors(!!!nyc_cols) %>%
#'   dm_draw()
#' @autoglobal
dm_set_colors <- function(dm, ...) {
  dm_local_error_call()
  quos <- enquos(...)
  if (any(names(quos) == "")) {
    abort_only_named_args("dm_set_colors", "the colors")
  }
  cols <- names(quos)
  if (
    !all(cols[!is_hex_color(cols)] %in% dm_get_available_colors()) &&
      all(cols %in% src_tbls_impl(dm))
  ) {
    abort_wrong_syntax_set_cols()
  }

  # get table names for each color (name_spec argument is not needed)
  selected_tables <- eval_select_table(quo(c(...)), src_tbls_impl(dm), unique = FALSE)

  # convert color names to hex color codes (if already hex code this is a no-op)
  # avoid error from mutate()
  names(selected_tables) <- col_to_hex(names(selected_tables))

  display_df <-
    selected_tables %>%
    enframe(name = "new_display", value = "table") %>%
    # needs to be done like this, `distinct()` would keep the first one
    filter(!duplicated(table, fromLast = TRUE))

  def <-
    dm_get_def(dm) %>%
    left_join(display_df, by = "table") %>%
    mutate(display = coalesce(new_display, display)) %>%
    select(-new_display)

  dm_from_def(def)
}

color_quos_to_display <- function(...) {
  quos <- enquos(..., .named = TRUE, .ignore_empty = "none", .homonyms = "error")
  missing <- map_lgl(quos, quo_is_missing)
  if (has_length(missing) && missing[[length(missing)]]) {
    abort_last_col_missing()
  }
  avail <- !missing
  idx <- rev(cumsum(rev(avail)))
  values <- map_chr(quos[avail], eval_tidy)

  set_names(names(quos), rev(values)[idx])
}

#' dm_get_colors()
#'
#' `dm_get_colors()` returns the colors defined for a data model.
#'
#' @return For `dm_get_colors()`, a named character vector of table names
#'   with the colors in the names.
#'   This allows calling `dm_set_colors(!!!dm_get_colors(...))`.
#'   Use [tibble::enframe()] to convert this to a tibble.
#'
#' @rdname dm_set_colors
#' @export
dm_get_colors <- function(dm) {
  dm %>%
    dm_get_def() %>%
    select(table, display) %>%
    select(display, table) %>%
    mutate(display = coalesce(display, "default")) %>%
    deframe()
}

#' dm_get_available_colors()
#'
#' `dm_get_available_colors()` returns an overview of the names of the available colors
#' These are the standard colors also returned by [grDevices::colors()] plus a default
#' table color with the name "default".
#'
#' @return For `dm_get_available_colors()`, a vector with the available colors.
#'
#' @rdname dm_set_colors
#' @export
dm_get_available_colors <- function() {
  c("default", colors())
}
